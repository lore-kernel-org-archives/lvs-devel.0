From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Least Connection Scheduler
Date: Tue, 1 Apr 2008 13:36:08 +0900
Message-ID: <200804011336.08118.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4ub8H5ZrsciMX17"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

--Boundary-00=_4ub8H5ZrsciMX17
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

This mail half belongs on -user, but there's a patch attached so I'm sendin=
g=20
it here instead.

I'm wanting to use the LC scheduler with servers of different specs but the=
=20
docs say that it doesn't perform well in this case due to TIME_WAIT=20
connections. According to the HOWTO, everything that is not an ESTABLISHED=
=20
connection is counted as inactive.  The current LC scheduler calculates eac=
h=20
server with the formula of (activeconns<<8) + inactconns.

Now, the only reason I can see for activeconns to be offset by inactconns a=
t=20
all is so that round-robining happens when activeconns is equal among sever=
al=20
servers. If that is in fact the only reason, how does the attached patch=20
look? The resulting request distribution should match server resources fair=
ly=20
closely with sufficient load. The only downside that I can see is that slow=
er=20
servers would get priority when activeconns are equal, but is that really a=
=20
problem?

=2D-=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=E4=
=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_4ub8H5ZrsciMX17
Content-Type: text/x-diff;
  charset="utf-8";
  name="ip_vs_lc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="ip_vs_lc.patch"

--- ip_vs_lc.c.orig	2008-04-01 11:35:37.518877853 +0900
+++ ip_vs_lc.c	2008-04-01 12:04:23.769147323 +0900
@@ -40,21 +40,6 @@
 }
 
 
-static inline unsigned int
-ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
-{
-	/*
-	 * We think the overhead of processing active connections is 256
-	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
-	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
-	 */
-	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
-}
-
-
 /*
  *	Least Connection scheduling
  */
@@ -62,14 +47,16 @@
 ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest, *least = NULL;
-	unsigned int loh = 0, doh;
+	unsigned int least_activeconns = 0, least_inactconns = 0;
+	unsigned int dest_activeconns = 0, dest_inactconns = 0;
 
 	IP_VS_DBG(6, "ip_vs_lc_schedule(): Scheduling...\n");
 
 	/*
-	 * Simply select the server with the least number of
-	 *        (activeconns<<5) + inactconns
-	 * Except whose weight is equal to zero.
+	 * Simply select the server with the least number of active
+	 * connections, or the least number of inactive connections
+	 * where the number of active connections is equal, excluding
+	 * servers whose weight is equal to zero.
 	 * If the weight is equal to zero, it means that the server is
 	 * quiesced, the existing connections to the server still get
 	 * served, but no new connection is assigned to the server.
@@ -79,18 +66,23 @@
 		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
-		doh = ip_vs_lc_dest_overhead(dest);
-		if (!least || doh < loh) {
+		dest_activeconns = atomic_read(&dest->activeconns);
+		dest_inactconns = atomic_read(&dest->inactconns);
+		if (!least || dest_activeconns < least_activeconns) {
+			least = dest;
+			least_activeconns = dest_activeconns;
+			least_inactconns = dest_inactconns;
+		} else if (dest_activeconns == least_activeconns &&
+			dest_inactconns < least_inactconns) {
 			least = dest;
-			loh = doh;
+			least_inactconns = dest_inactconns;
 		}
 	}
 
 	if (least)
 	IP_VS_DBG(6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
 		  NIPQUAD(least->addr), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->inactconns));
+		  least_activeconns, least_inactconns);
 
 	return least;
 }

--Boundary-00=_4ub8H5ZrsciMX17--
