From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: IPv4 FWMARK virtual services
Date: Thu, 7 May 2009 11:02:29 +1000
Message-ID: <20090507010229.GD10063@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Jan Engelhardt <jengelh@medozas.de>, Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

This fixes the use of fwmarks to denote IPv4 virtual services
which was unfortunately broken as a result of the integration
of IPv6 support into IPVS, which was included in 2.6.28.

The problem arises because fwmarks are stored in the 4th octet
of a union nf_inet_addr .all, however in the case of IPv4 only
the first octet, corresponding to .ip, is assigned and compared.

In other words, using .all =3D { 0, 0, 0, htonl(svc->fwmark) always
results in a value of 0 (32bits) being stored for IPv4. This means
that one fwmark can be used, as it ends up being mapped to 0, but thing=
s
break down when multiple fwmarks are used, as they all end up being map=
ped
to 0.

As fwmarks are 32bits a reasonable fix seems to be to just store the fw=
mark
in .ip, and comparing and storing .ip when fwmarks are used.

This patch makes the assumption that in calls to ip_vs_ct_in_get()
and ip_vs_sched_persist() if the proto parameter is IPPROTO_IP then
we are dealing with an fwmark. I believe this is valid as ip_vs_in()
does fairly strict filtering on the protocol and IPPROTO_IP should
not be used in these calls unless explicitly passed when making
these calls for fwmarks in ip_vs_sched_persist().

Tested-by: Fabien Duch=EAne <fabien.duchene@student.uclouvain.be>
Cc: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Julius Volz <julius.volz@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--=20

This problem should probably be fixed in stable too.
Either using this patch, or a simpler though arguably less correct one =
that
uses:

	.all =3D { htonl(svc->fwmark), 0, 0, 0 }

That change doesn't require updating ip_vs_ct_in_get() or ip_vs_conn_ne=
w(),
nor any assumptions about the value of proto. Fabien Duch=EAne has test=
ed
this simpler change and found it to work.

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:=
48.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2009-04-28 20:37:51.00=
0000000 +1000
@@ -260,7 +260,10 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af =3D=3D af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    /* protocol should only be IPPROTO_IP if
+		     * d_addr is a fwmark */
+		    ip_vs_addr_equal(protocol =3D=3D IPPROTO_IP ? AF_UNSPEC : af,
+		                     d_addr, &cp->vaddr) &&
 		    s_port =3D=3D cp->cport && d_port =3D=3D cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    protocol =3D=3D cp->protocol) {
@@ -698,7 +701,9 @@ ip_vs_conn_new(int af, int proto, const=20
 	cp->cport	   =3D cport;
 	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
 	cp->vport	   =3D vport;
-	ip_vs_addr_copy(af, &cp->daddr, daddr);
+	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
+	ip_vs_addr_copy(proto =3D=3D IPPROTO_IP ? AF_UNSPEC : af,
+			&cp->daddr, daddr);
 	cp->dport          =3D dport;
 	cp->flags	   =3D flags;
 	spin_lock_init(&cp->lock);
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_core.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:37:=
48.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2009-04-28 20:37:51.00=
0000000 +1000
@@ -278,7 +278,7 @@ ip_vs_sched_persist(struct ip_vs_service
 		 */
 		if (svc->fwmark) {
 			union nf_inet_addr fwmark =3D {
-				.all =3D { 0, 0, 0, htonl(svc->fwmark) }
+				.ip =3D htonl(svc->fwmark)
 			};
=20
 			ct =3D ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
@@ -306,7 +306,7 @@ ip_vs_sched_persist(struct ip_vs_service
 			 */
 			if (svc->fwmark) {
 				union nf_inet_addr fwmark =3D {
-					.all =3D { 0, 0, 0, htonl(svc->fwmark) }
+					.ip =3D htonl(svc->fwmark)
 				};
=20
 				ct =3D ip_vs_conn_new(svc->af, IPPROTO_IP,


