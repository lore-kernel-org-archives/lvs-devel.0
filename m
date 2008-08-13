From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: rename __ip_vs_wlc_schedule in lblc and lblcr
	schedulers
Date: Wed, 13 Aug 2008 15:49:58 +1000
Message-ID: <20080813054956.GA30294@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Sven Wegener <sven.wegener@stealer.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

For the sake of clarity, rename __ip_vs_wlc_schedule() in lblc.c to
__ip_vs_lblc_schedule() and the version in lblcr.c to __ip_vs_lblc_schedule().

I guess the original name stuck from a copy and paste.

Cc: Sven Wegener <sven.wegener@stealer.net>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: stealer-2.6/net/ipv4/ipvs/ip_vs_lblc.c
===================================================================
--- stealer-2.6.orig/net/ipv4/ipvs/ip_vs_lblc.c	2008-08-13 15:44:01.000000000 +1000
+++ stealer-2.6/net/ipv4/ipvs/ip_vs_lblc.c	2008-08-13 15:44:31.000000000 +1000
@@ -395,7 +395,7 @@ static int ip_vs_lblc_update_svc(struct 
 
 
 static inline struct ip_vs_dest *
-__ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
+__ip_vs_lblc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
@@ -494,7 +494,7 @@ ip_vs_lblc_schedule(struct ip_vs_service
 	tbl = (struct ip_vs_lblc_table *)svc->sched_data;
 	en = ip_vs_lblc_get(tbl, iph->daddr);
 	if (en == NULL) {
-		dest = __ip_vs_wlc_schedule(svc, iph);
+		dest = __ip_vs_lblc_schedule(svc, iph);
 		if (dest == NULL) {
 			IP_VS_DBG(1, "no destination available\n");
 			return NULL;
@@ -509,7 +509,7 @@ ip_vs_lblc_schedule(struct ip_vs_service
 		if (!(dest->flags & IP_VS_DEST_F_AVAILABLE)
 		    || atomic_read(&dest->weight) <= 0
 		    || is_overloaded(dest, svc)) {
-			dest = __ip_vs_wlc_schedule(svc, iph);
+			dest = __ip_vs_lblc_schedule(svc, iph);
 			if (dest == NULL) {
 				IP_VS_DBG(1, "no destination available\n");
 				return NULL;
Index: stealer-2.6/net/ipv4/ipvs/ip_vs_lblcr.c
===================================================================
--- stealer-2.6.orig/net/ipv4/ipvs/ip_vs_lblcr.c	2008-08-13 15:44:01.000000000 +1000
+++ stealer-2.6/net/ipv4/ipvs/ip_vs_lblcr.c	2008-08-13 15:44:44.000000000 +1000
@@ -579,7 +579,7 @@ static int ip_vs_lblcr_update_svc(struct
 
 
 static inline struct ip_vs_dest *
-__ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
+__ip_vs_lblcr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
@@ -679,7 +679,7 @@ ip_vs_lblcr_schedule(struct ip_vs_servic
 	tbl = (struct ip_vs_lblcr_table *)svc->sched_data;
 	en = ip_vs_lblcr_get(tbl, iph->daddr);
 	if (en == NULL) {
-		dest = __ip_vs_wlc_schedule(svc, iph);
+		dest = __ip_vs_lblcr_schedule(svc, iph);
 		if (dest == NULL) {
 			IP_VS_DBG(1, "no destination available\n");
 			return NULL;
@@ -693,7 +693,7 @@ ip_vs_lblcr_schedule(struct ip_vs_servic
 	} else {
 		dest = ip_vs_dest_set_min(&en->set);
 		if (!dest || is_overloaded(dest, svc)) {
-			dest = __ip_vs_wlc_schedule(svc, iph);
+			dest = __ip_vs_lblcr_schedule(svc, iph);
 			if (dest == NULL) {
 				IP_VS_DBG(1, "no destination available\n");
 				return NULL;
