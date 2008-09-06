From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local
	process
Date: Sat, 6 Sep 2008 17:43:54 +1000
Message-ID: <20080906074352.GA22998@verge.net.au>
References: <20080905013609.GD14128@verge.net.au> <Pine.LNX.4.58.0809050750550.2831@u.domain.uli> <60dee71e238f7fa03da7bc5338ec4bf5.squirrel@p6drad-teel.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <60dee71e238f7fa03da7bc5338ec4bf5.squirrel@p6drad-teel.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

On Fri, Sep 05, 2008 at 08:49:52AM +0300, Siim P=F5der wrote:
> Hi
>=20
> > 	TCP checksum is not optional, why this change appeared?
>=20
> The new packets that we handle are on the loopback device and no chec=
ksums
> appear to be generated there. I initially changed the condition to ch=
eck
> for loopback device (which we could do), but checking udp code found =
that
> it already handled it by checking zero checksum, hence the same
> implementation in tcp code.

I checked with Herbert Xu and its not legal for the checksum to be miss=
ing
for TCP. However it is possible for there to be a partial checksum for
loopback traffic. That is, only the pseudo-header is summed.

The patch outlines a fix for this problem using the existing
structure of ip_vs_proto_tcp.c. I believe that a similar fix
is also required for UDP. I am posting it now so people can comment
on its correctness.


Moving forward tcp_partial_csum_update() and tcp_fast_csum_update()
could be implemented in terms of inet_proto_csum_replace* if
inet_proto_csum_replace16 was added. I will work on coding this up.


diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_prot=
o_tcp.c
index 808e8be..537f616 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -134,12 +134,34 @@ tcp_fast_csum_update(int af, struct tcphdr *tcph,
 }
=20
=20
+static inline void
+tcp_partial_csum_update(int af, struct tcphdr *tcph,
+		     const union nf_inet_addr *oldip,
+		     const union nf_inet_addr *newip,
+		     __be16 oldlen, __be16 newlen)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af =3D=3D AF_INET6)
+		tcph->check =3D
+			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+					 ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(tcph->check))));
+	else
+#endif
+	tcph->check =3D
+		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+				ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(tcph->check))));
+}
+
+
 static int
 tcp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
 	unsigned int tcphoff;
+	int oldlen;
=20
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af =3D=3D AF_INET6)
@@ -147,6 +169,7 @@ tcp_snat_handler(struct sk_buff *skb,
 	else
 #endif
 		tcphoff =3D ip_hdrlen(skb);
+	oldlen =3D skb->len - tcphoff;
=20
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -166,7 +189,11 @@ tcp_snat_handler(struct sk_buff *skb,
 	tcph->source =3D cp->vport;
=20
 	/* Adjust TCP checksums */
-	if (!cp->app && (tcph->check !=3D 0)) {
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
+		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - tcphoff));
+	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
@@ -204,6 +231,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 {
 	struct tcphdr *tcph;
 	unsigned int tcphoff;
+	int oldlen;
=20
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af =3D=3D AF_INET6)
@@ -211,6 +239,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	else
 #endif
 		tcphoff =3D ip_hdrlen(skb);
+	oldlen =3D skb->len - tcphoff;
=20
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -235,7 +264,11 @@ tcp_dnat_handler(struct sk_buff *skb,
 	/*
 	 *	Adjust TCP checksums
 	 */
-	if (!cp->app && (tcph->check !=3D 0)) {
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
+		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - tcphoff));
+	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
