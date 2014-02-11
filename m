From: Tingwei Liu <tingw.liu@gmail.com>
Subject: [PATCH ipvs-next] ipvs: Reduce checkpatch noise in ip_vs_lblc.c
Date: Tue, 11 Feb 2014 17:31:25 +0800
Message-ID: <1392111085-14551-1-git-send-email-tingw.liu@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id;
        bh=E71jngG63OJNgCawYKSt//JeWAU8VXs999eQ5el53/o=;
        b=Z7nlFNsJkPX4i/fPOjt7CqTmq01aV5LmDAFanM3126WDdw2jR+QYDpy7xHCiQ+owsd
         q2ujQgcSZMfvzw9ixSvizOusDLkMLkSPmCRiRD1pWgUkAxc/64SXuVz2RLPhkznMY08P
         lZW5J0rwl+07EiAzw1m5ozu7B8I7CE+zBLZ4pWwVBaPe4OpJpU1XhZ7vhB5/n0+/ijHv
         AzeaBVrHy+CsvSYVEftvUNGN7wd7CQlM1Eg8UeE705Zek0yzvo/hOQAVRhSBY72Zm30e
         GnPJdz7nxAYzkZjuZkL/x5O0mA/XjXPomLU8wRK8y/9CBbIAZhoQkSbxaI4zljZmSPiF
         eD5g==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Tingwei Liu <tingw.liu@gmail.com>, Tingwei Liu <liutingwei@hisense.com>, lvs-devel@vger.kernel.org

Add whitespace after operator and put open brace { on the previous line

Cc: Tingwei Liu <liutingwei@hisense.com>
Cc: lvs-devel@vger.kernel.org
Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index ca056a3..547ff33 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -238,7 +238,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 
 	spin_lock_bh(&svc->sched_lock);
 	tbl->dead = 1;
-	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblc_del(en);
 			atomic_dec(&tbl->entries);
@@ -265,7 +265,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 	unsigned long now = jiffies;
 	int i, j;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -321,7 +321,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	if (goal > tbl->max_size/2)
 		goal = tbl->max_size/2;
 
-	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		spin_lock(&svc->sched_lock);
@@ -340,7 +340,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	tbl->rover = j;
 
   out:
-	mod_timer(&tbl->periodic_timer, jiffies+CHECK_EXPIRE_INTERVAL);
+	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
 }
 
 
@@ -363,7 +363,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Initialize the hash buckets
 	 */
-	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		INIT_HLIST_HEAD(&tbl->bucket[i]);
 	}
 	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
@@ -536,8 +536,7 @@ out:
 /*
  *      IPVS LBLC Scheduler structure
  */
-static struct ip_vs_scheduler ip_vs_lblc_scheduler =
-{
+static struct ip_vs_scheduler ip_vs_lblc_scheduler = {
 	.name =			"lblc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-- 
1.6.0.2

