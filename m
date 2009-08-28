From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: Use atomic operations atomicly
Date: Fri, 28 Aug 2009 12:37:22 +1000
Message-ID: <20090828023722.GA12136@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: =?utf-8?B?7ZmN7Iug?= shin hong <hongshin@gmail.com>, David Miller <davem@davemloft.net>

A pointed out by Shin Hong, IPVS doesn't always use atomic operations
in an atomic manner. While this seems unlikely to be manifest in
strange behaviour, it seems appropriate to clean this up.

Cc: =ED=99=8D=EC=8B=A0 shin hong <hongshin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_core.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2009-08-28 12:07:=
49.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2009-08-28 12:33:18.00=
0000000 +1000
@@ -1259,7 +1259,7 @@ ip_vs_in(unsigned int hooknum, struct sk
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ret, restart, af;
+	int ret, restart, af, pkts;
=20
 	af =3D (skb->protocol =3D=3D htons(ETH_P_IP)) ? AF_INET : AF_INET6;
=20
@@ -1346,12 +1346,12 @@ ip_vs_in(unsigned int hooknum, struct sk
 	 * Sync connection if it is about to close to
 	 * encorage the standby servers to update the connections timeout
 	 */
-	atomic_inc(&cp->in_pkts);
+	pkts =3D atomic_add_return(1, &cp->in_pkts);
 	if (af =3D=3D AF_INET &&
 	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol !=3D IPPROTO_TCP ||
 	       cp->state =3D=3D IP_VS_TCP_S_ESTABLISHED) &&
-	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
+	      (pkts % sysctl_ip_vs_sync_threshold[1]
 	       =3D=3D sysctl_ip_vs_sync_threshold[0])) ||
 	     ((cp->protocol =3D=3D IPPROTO_TCP) && (cp->old_state !=3D cp->st=
ate) &&
 	      ((cp->state =3D=3D IP_VS_TCP_S_FIN_WAIT) ||
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_wrr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_wrr.c	2009-08-28 12:07:4=
9.000000000 +1000
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_wrr.c	2009-08-28 12:33:18.000=
000000 +1000
@@ -77,11 +77,12 @@ static int ip_vs_wrr_gcd_weight(struct i
 static int ip_vs_wrr_max_weight(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest;
-	int weight =3D 0;
+	int new_weight, weight =3D 0;
=20
 	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if (atomic_read(&dest->weight) > weight)
-			weight =3D atomic_read(&dest->weight);
+		new_weight =3D atomic_read(&dest->weight);
+		if (new_weight > weight)
+			weight =3D new_weight;
 	}
=20
 	return weight;
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
