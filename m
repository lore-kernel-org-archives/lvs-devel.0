From: Simon Horman <horms@verge.net.au>
Subject: [patch] IPVS: Make "no destination available" message more
	consistent between schedulers
Date: Tue, 30 Dec 2008 11:46:44 +1100
Message-ID: <20081230004644.GA18464@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Joseph Mack <jmack@wm7d.net>, Graeme Fowler <graeme@graemef.net>, Siim =?iso-8859-1?Q?P=F5der?= <windo@p6drad-teel.net>

Cc: Joseph Mack <jmack@wm7d.net>
Cc: Siim P=F5der <windo@p6drad-teel.net>
Acked-by: Graeme Fowler <graeme@graemef.net>
Signed-off-by: Simon Horman <horms@verge.net.au>

---=20

 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_lc.c    |   14 +++++++++-----
 net/netfilter/ipvs/ip_vs_nq.c    |    4 +++-
 net/netfilter/ipvs/ip_vs_rr.c    |    1 +
 net/netfilter/ipvs/ip_vs_sed.c   |    1 +
 net/netfilter/ipvs/ip_vs_sh.c    |    1 +
 net/netfilter/ipvs/ip_vs_wlc.c   |    1 +
 net/netfilter/ipvs/ip_vs_wrr.c   |    8 ++++++--
 9 files changed, 24 insertions(+), 10 deletions(-)

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_lblc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_lblc.c	2008-12-30 11:21:=
16.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_lblc.c	2008-12-30 11:30:05.00=
0000000 +1100
@@ -507,7 +507,7 @@ ip_vs_lblc_schedule(struct ip_vs_service
 	/* No cache entry or it is invalid, time to schedule */
 	dest =3D __ip_vs_lblc_schedule(svc);
 	if (!dest) {
-		IP_VS_DBG(1, "no destination available\n");
+		IP_VS_ERR_RL("LBLC: no destination available\n");
 		return NULL;
 	}
=20
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_lblcr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_lblcr.c	2008-12-30 11:21=
:16.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_lblcr.c	2008-12-30 11:30:05.0=
00000000 +1100
@@ -690,7 +690,7 @@ ip_vs_lblcr_schedule(struct ip_vs_servic
 		/* The cache entry is invalid, time to schedule */
 		dest =3D __ip_vs_lblcr_schedule(svc);
 		if (!dest) {
-			IP_VS_DBG(1, "no destination available\n");
+			IP_VS_ERR_RL("LBLCR: no destination available\n");
 			read_unlock(&svc->sched_lock);
 			return NULL;
 		}
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_lc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_lc.c	2008-12-30 11:21:16=
=2E000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_lc.c	2008-12-30 11:30:05.0000=
00000 +1100
@@ -66,11 +66,15 @@ ip_vs_lc_schedule(struct ip_vs_service *
 		}
 	}
=20
-	if (least)
-	IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d inactconns %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
-		      atomic_read(&least->activeconns),
-		      atomic_read(&least->inactconns));
+	if (!least)
+		IP_VS_ERR_RL("LC: no destination available\n");
+	else
+		IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d "
+			      "inactconns %d\n",
+			      IP_VS_DBG_ADDR(svc->af, &least->addr),
+			      ntohs(least->port),
+			      atomic_read(&least->activeconns),
+			      atomic_read(&least->inactconns));
=20
 	return least;
 }
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_nq.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_nq.c	2008-12-30 11:21:16=
=2E000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_nq.c	2008-12-30 11:30:05.0000=
00000 +1100
@@ -95,8 +95,10 @@ ip_vs_nq_schedule(struct ip_vs_service *
 		}
 	}
=20
-	if (!least)
+	if (!least) {
+		IP_VS_ERR_RL("NQ: no destination available\n");
 		return NULL;
+	}
=20
   out:
 	IP_VS_DBG_BUF(6, "NQ: server %s:%u "
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_rr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_rr.c	2008-12-30 11:21:16=
=2E000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_rr.c	2008-12-30 11:30:05.0000=
00000 +1100
@@ -69,6 +69,7 @@ ip_vs_rr_schedule(struct ip_vs_service *
 		q =3D q->next;
 	} while (q !=3D p);
 	write_unlock(&svc->sched_lock);
+	IP_VS_ERR_RL("RR: no destination available\n");
 	return NULL;
=20
   out:
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_sed.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_sed.c	2008-12-30 11:21:1=
6.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_sed.c	2008-12-30 11:30:05.000=
000000 +1100
@@ -84,6 +84,7 @@ ip_vs_sed_schedule(struct ip_vs_service=20
 			goto nextstage;
 		}
 	}
+	IP_VS_ERR_RL("SED: no destination available\n");
 	return NULL;
=20
 	/*
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_sh.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_sh.c	2008-12-30 11:21:16=
=2E000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_sh.c	2008-12-30 11:30:05.0000=
00000 +1100
@@ -219,6 +219,7 @@ ip_vs_sh_schedule(struct ip_vs_service *
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <=3D 0
 	    || is_overloaded(dest)) {
+		IP_VS_ERR_RL("SH: no destination available\n");
 		return NULL;
 	}
=20
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_wlc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_wlc.c	2008-12-30 11:21:1=
6.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_wlc.c	2008-12-30 11:30:05.000=
000000 +1100
@@ -72,6 +72,7 @@ ip_vs_wlc_schedule(struct ip_vs_service=20
 			goto nextstage;
 		}
 	}
+	IP_VS_ERR_RL("WLC: no destination available\n");
 	return NULL;
=20
 	/*
Index: net-next-2.6/net/netfilter/ipvs/ip_vs_wrr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_wrr.c	2008-12-30 11:21:1=
6.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_wrr.c	2008-12-30 11:30:05.000=
000000 +1100
@@ -155,6 +155,8 @@ ip_vs_wrr_schedule(struct ip_vs_service=20
=20
 			if (mark->cl =3D=3D mark->cl->next) {
 				/* no dest entry */
+				IP_VS_ERR_RL("WRR: no destination available: "
+					     "no destinations present\n");
 				dest =3D NULL;
 				goto out;
 			}
@@ -168,8 +170,8 @@ ip_vs_wrr_schedule(struct ip_vs_service=20
 				 */
 				if (mark->cw =3D=3D 0) {
 					mark->cl =3D &svc->destinations;
-					IP_VS_ERR_RL("ip_vs_wrr_schedule(): "
-						   "no available servers\n");
+					IP_VS_ERR_RL("WRR: no destination "
+						     "available\n");
 					dest =3D NULL;
 					goto out;
 				}
@@ -191,6 +193,8 @@ ip_vs_wrr_schedule(struct ip_vs_service=20
 			/* back to the start, and no dest is found.
 			   It is only possible when all dests are OVERLOADED */
 			dest =3D NULL;
+			IP_VS_ERR_RL("WRR: no destination available: "
+				     "all destinations are overloaded\n");
 			goto out;
 		}
 	}
