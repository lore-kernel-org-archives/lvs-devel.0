From: Simon Horman <horms@verge.net.au>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 3 Dec 2010 21:42:14 +0900
Message-ID: <20101203124214.GB6993@verge.net.au>
References: <20101203103447.GA29714@hostway.ca>
 <1291375743.2897.141.camel@edumazet-laptop>
 <20101203123617.GA6993@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101203123617.GA6993@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Herbert Xu <herbert@gondor.apana.org.au>

[ CCed lvs-devel, Julian Anastasov and Herbert Xu ]

On Fri, Dec 03, 2010 at 09:36:19PM +0900, Simon Horman wrote:
> On Fri, Dec 03, 2010 at 12:29:03PM +0100, Eric Dumazet wrote:
> > Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 02:34 -0800, Simon Kirby a=
 =C3=A9crit :
> > > Hello!
> > >=20
> > > We upgraded some LVS (DR) servers from 2.6.35 to 2.6.36 on tg3 ca=
rds
> > > (partno(BCM95721) rev 4201) with VLAN tags in use, to think that
> > > everything looked great, but in fact...
> > >=20
> > > LVS was receiving magically-merged TCP packets which it tried to =
forward
> > > on to the real server, only to get annoyed at itself for trying t=
o
> > > forward a packet bigger than the device MTU:
> > >=20
> > > IP A.47376 > B.529: . 175488:176936(1448) ack 1 win 92 <nop,nop,t=
imestamp 52737308 29656081>
> > > IP A.47376 > B.529: . 176936:179832(2896) ack 1 win 92 <nop,nop,t=
imestamp 52737325 29656098>
> > > IP B > A: ICMP B unreachable - need to frag (mtu 1500), length 55=
6
> > >=20
> >=20
> > Hi Simon
> >=20
> > This is a tcpdump on A ?
> > Could you take it also on B ?
> >=20
> > tcpdump displays large buffers, but they should be split (of course=
)
> > when sent on wire.
> >=20
> > > This caused packet loss for any merged frames, which caused abysm=
al
> > > performance for uploads via the LVS server.  Local performance to=
 or
> > > from the box is still fine, because the stack doesn't care, only =
the
> > > forwarding part of LVS is running into the problem.
> > >=20
> > > Furthermore, disabling _everything_ reported by ethtool -k doesn'=
t seem
> > > to change the result, even if I down/up the interface after, and =
even if
> > > I try on every single interface including the VLANned ones.  This=
 seems
> > > to be another bug.  Reverting to 2.6.35 makes it all work again.
> > >=20
> > > Possibly related to commit 7fe876af921d1d2bc8353e0062c10ff35e9026=
53
> > >=20
> > > So how should this be fixed?  Should LVS be taught to fragment, o=
r must
> > > we disable the merging in this case?  It seems like it would work=
 well if
> > > the sending side could do the same offload in reverse, but I'm no=
t sure
> > > if that would be possible.
> > >=20
> > > Simon-
> >=20
> >=20
> > I believe Simon Horman has some patches for GRO and LVS.
> >=20
> > Please send the results of "ethtool -k eth0" on all your nics / vla=
ns ?
> >=20
> > For TSO, I am not sure why and where it could matter...
>=20
> There is a patch to teach LVS how to cope with GRO in nf-next-2.6
> and I expect it to be included in 2.6.38. The patch is "ipvs: allow
> transmit of GRO aggregated skbs" and perhaps it should be considered
> for 2.6.37 and stable. In general the work around is to disable GRO.
>=20
> The patch does not resolve the incompatibility of LVS with LRO.
> The work around there is to disable LRO. I'm not entirely sure
> how to teach LVS to disable LRO automatically, or if its desirable.
>=20
> Simon, you mention that you disabled everything with ethtool, but the
> tcpdump above shows a 2896 byte packet, which seems that GRO (or LRO?=
) is
> active. So perhaps as you speculate that is a bug
>=20
> I will prepare a backport of the "ipvs: allow transmit of GRO aggrega=
ted
> skbs" patch to v2.6.36 and post it shortly.  Testing to see if that
> resolves the problem that you are seeing would probably be a good sta=
rt.

Here is the patch for v2.6.36.

=46rom: Simon Horman <horms@verge.net.au>

ipvs: allow transmit of GRO aggregated skbs

Attempt at allowing LVS to transmit skbs of greater than MTU length tha=
t
have been aggregated by GRO and can thus be deaggregated by GSO.

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
 net/netfilter/ipvs/ip_vs_xmit.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs=
_xmit.c
index 49df6be..577f502 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -247,7 +247,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -311,7 +312,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -408,7 +409,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_co=
nn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for")=
;
@@ -486,7 +488,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs=
_conn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
@@ -597,8 +599,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
=20
 	df |=3D (old_iph->frag_off & htons(IP_DF));
=20
-	if ((old_iph->frag_off & htons(IP_DF))
-	    && mtu < ntohs(old_iph->tot_len)) {
+	if ((old_iph->frag_off & htons(IP_DF) &&
+	    mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb))) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -707,7 +709,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
=20
-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
+	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
+	    !skb_is_gso(skb)) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -796,7 +799,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_con=
n *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
+	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
+	    !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -924,7 +928,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_c=
onn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -999,7 +1004,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_=
vs_conn *cp,
=20
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		dst_release(&rt->dst);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
--=20
1.7.2.3

