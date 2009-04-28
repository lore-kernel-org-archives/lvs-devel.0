From: Simon Horman <horms@verge.net.au>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 20:59:41 +1000
Message-ID: <20090428105941.GA20907@verge.net.au>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr> <20090428092351.GC8165@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090428092351.GC8165@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

On Tue, Apr 28, 2009 at 07:23:55PM +1000, Simon Horman wrote:
> On Tue, Apr 28, 2009 at 11:07:40AM +0200, Jan Engelhardt wrote:
> > 
> > On Tuesday 2009-04-28 10:15, Simon Horman wrote:
> > >
> > >It seems to me that it should be easy enough to fix by changing
> > >fwmark in ip_vs_sched_persist() from:
> > >
> > >union nf_inet_addr fwmark = {
> > >	.all = { 0, 0, 0, htonl(svc->fwmark) }
> > >};
> > >
> > >to:
> > >
> > >union nf_inet_addr fwmark = {
> > >	.all = { htonl(svc->fwmark), 0, 0, 0 }
> > >};
> > >
> > >Assuming that this would result in fwmark->ip being set to
> > >htonl(svc->fwmark), which is relevant if svc->af is AF_INET - that is,
> > >for IPv4.[...]
> > >An alternate idea would be to change the af value used for fwmarks,
> > >but this seems to be even less clean than the current (slightly broken)
> > >technique of using nf_inet_addr for IPv4 or IPv6 addresses, or fwmarks.
> > 
> > If you use ->all, then using NFPROTO_UNSPEC as af
> > seems to me like a good match.

I am guessing that AF_UNSPEC is more appropriate than NFPROTO_UNSPEC.
Please correct me if I am wrong.

> That seems reasonable, though ip_vs_ct_in_get() would still
> need to use the real af for the cp->af == af and
> ip_vs_addr_equal(af, s_addr, &cp->caddr) portinos of the check.

It looks like checking for proto == IPPROTO_IP can tell us if
the destination is a fwmark. This is based on the assumption that
iph.protocol can never be IPPROTO_IP in ip_vs_sched_persist().

The following patch expresses these ideas as they crrently stand.
Fabien, is it possible for you to test this?

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:48.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.000000000 +1000
@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    /* protocol should only be IPPROTO_IP if
+		     * d_addr is a fwmark */
+		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
+		                     d_addr, &cp->vaddr) &&
 		    s_port == cp->cport && d_port == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    protocol == cp->protocol) {
@@ -698,7 +701,9 @@ ip_vs_conn_new(int af, int proto, const 
 	cp->cport	   = cport;
 	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
 	cp->vport	   = vport;
-	ip_vs_addr_copy(af, &cp->daddr, daddr);
+	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
+	ip_vs_addr_copy(proto == IPPROTO_IP ? AF_UNSPEC : af,
+			&cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	spin_lock_init(&cp->lock);
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:37:48.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:37:51.000000000 +1000
@@ -278,7 +278,7 @@ ip_vs_sched_persist(struct ip_vs_service
 		 */
 		if (svc->fwmark) {
 			union nf_inet_addr fwmark = {
-				.all = { 0, 0, 0, htonl(svc->fwmark) }
+				.ip = htonl(svc->fwmark)
 			};
 
 			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
@@ -306,7 +306,7 @@ ip_vs_sched_persist(struct ip_vs_service
 			 */
 			if (svc->fwmark) {
 				union nf_inet_addr fwmark = {
-					.all = { 0, 0, 0, htonl(svc->fwmark) }
+					.ip = htonl(svc->fwmark)
 				};
 
 				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,


-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

