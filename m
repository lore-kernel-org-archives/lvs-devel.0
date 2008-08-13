From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Only call init_service, update_service and done_service
 for schedulers if defined
Date: Thu, 14 Aug 2008 00:42:55 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808140034210.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg

There are schedulers that only schedule based on data available in the service
or destination structures and they don't need any persistent storage or
initialization routine. These schedulers currently provide dummy functions for
the init_service, update_service and/or done_service functions. For the
init_service and done_service cases we already have code that only calls these
functions, if the scheduler provides them. Do the same for the update_service
case and remove the dummy functions from all schedulers.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_ctl.c   |   21 ++++++++++++---------
 net/ipv4/ipvs/ip_vs_lblc.c  |    7 -------
 net/ipv4/ipvs/ip_vs_lblcr.c |    7 -------
 net/ipv4/ipvs/ip_vs_lc.c    |   21 ---------------------
 net/ipv4/ipvs/ip_vs_nq.c    |   24 ------------------------
 net/ipv4/ipvs/ip_vs_rr.c    |    7 -------
 net/ipv4/ipvs/ip_vs_sed.c   |   24 ------------------------
 net/ipv4/ipvs/ip_vs_wlc.c   |   24 ------------------------
 8 files changed, 12 insertions(+), 123 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 9a5ace0..0074e25 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -855,7 +855,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 		svc->num_dests++;
 
 		/* call the update_service function of its scheduler */
-		svc->scheduler->update_service(svc);
+		if (svc->scheduler->update_service)
+			svc->scheduler->update_service(svc);
 
 		write_unlock_bh(&__ip_vs_svc_lock);
 		return 0;
@@ -885,7 +886,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	svc->num_dests++;
 
 	/* call the update_service function of its scheduler */
-	svc->scheduler->update_service(svc);
+	if (svc->scheduler->update_service)
+		svc->scheduler->update_service(svc);
 
 	write_unlock_bh(&__ip_vs_svc_lock);
 
@@ -935,7 +937,8 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
 
 	/* call the update_service, because server weight may be changed */
-	svc->scheduler->update_service(svc);
+	if (svc->scheduler->update_service)
+		svc->scheduler->update_service(svc);
 
 	write_unlock_bh(&__ip_vs_svc_lock);
 
@@ -998,12 +1001,12 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	 */
 	list_del(&dest->n_list);
 	svc->num_dests--;
-	if (svcupd) {
-		/*
-		 *  Call the update_service function of its scheduler
-		 */
-		svc->scheduler->update_service(svc);
-	}
+
+	/*
+	 *  Call the update_service function of its scheduler
+	 */
+	if (svcupd && svc->scheduler->update_service)
+			svc->scheduler->update_service(svc);
 }
 
 
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 0efa3db..887bf7e 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -388,12 +388,6 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_lblc_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline struct ip_vs_dest *
 __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
@@ -541,7 +535,6 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.module =		THIS_MODULE,
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
-	.update_service =	ip_vs_lblc_update_svc,
 	.schedule =		ip_vs_lblc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 8e3bbeb..47f4508 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -572,12 +572,6 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_lblcr_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline struct ip_vs_dest *
 __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
@@ -730,7 +724,6 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.module =		THIS_MODULE,
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
-	.update_service =	ip_vs_lblcr_update_svc,
 	.schedule =		ip_vs_lblcr_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index ac9f08e..0b34752 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -20,24 +20,6 @@
 #include <net/ip_vs.h>
 
 
-static int ip_vs_lc_init_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int ip_vs_lc_done_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int ip_vs_lc_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline unsigned int
 ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
 {
@@ -98,9 +80,6 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.name =			"lc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-	.init_service =		ip_vs_lc_init_svc,
-	.done_service =		ip_vs_lc_done_svc,
-	.update_service =	ip_vs_lc_update_svc,
 	.schedule =		ip_vs_lc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index a46bf25..a8958f7 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -37,27 +37,6 @@
 #include <net/ip_vs.h>
 
 
-static int
-ip_vs_nq_init_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_nq_done_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_nq_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline unsigned int
 ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
 {
@@ -136,9 +115,6 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.name =			"nq",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-	.init_service =		ip_vs_nq_init_svc,
-	.done_service =		ip_vs_nq_done_svc,
-	.update_service =	ip_vs_nq_update_svc,
 	.schedule =		ip_vs_nq_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index c8db12d..26451b5 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -32,12 +32,6 @@ static int ip_vs_rr_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_rr_done_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static int ip_vs_rr_update_svc(struct ip_vs_service *svc)
 {
 	svc->sched_data = &svc->destinations;
@@ -95,7 +89,6 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.init_service =		ip_vs_rr_init_svc,
-	.done_service =		ip_vs_rr_done_svc,
 	.update_service =	ip_vs_rr_update_svc,
 	.schedule =		ip_vs_rr_schedule,
 };
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 2a7d313..6ecc42a 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -41,27 +41,6 @@
 #include <net/ip_vs.h>
 
 
-static int
-ip_vs_sed_init_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_sed_done_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_sed_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline unsigned int
 ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
 {
@@ -138,9 +117,6 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.name =			"sed",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-	.init_service =		ip_vs_sed_init_svc,
-	.done_service =		ip_vs_sed_done_svc,
-	.update_service =	ip_vs_sed_update_svc,
 	.schedule =		ip_vs_sed_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 772c3cb..1d6c3e2 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -25,27 +25,6 @@
 #include <net/ip_vs.h>
 
 
-static int
-ip_vs_wlc_init_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_wlc_done_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
-static int
-ip_vs_wlc_update_svc(struct ip_vs_service *svc)
-{
-	return 0;
-}
-
-
 static inline unsigned int
 ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
 {
@@ -126,9 +105,6 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.name =			"wlc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-	.init_service =		ip_vs_wlc_init_svc,
-	.done_service =		ip_vs_wlc_done_svc,
-	.update_service =	ip_vs_wlc_update_svc,
 	.schedule =		ip_vs_wlc_schedule,
 };
 
