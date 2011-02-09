From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: fix timer in get_curr_sync_buff
Date: Wed, 9 Feb 2011 02:21:59 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1102090214460.3494@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Tinggong Wang <wangtinggong@gmail.com>


From: Tinggong Wang <wangtinggong@gmail.com>

 	Fix get_curr_sync_buff to keep buffer for 2 seconds
as intended, not just for the current jiffie. By this way
we will sync more connection structures with single packet.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 	Patch is against lvs-test-2.6 from 09-FEB-2011
but should apply cleanly to net-next.

--- lvs-test-2.6-7c9989a/net/netfilter/ipvs/ip_vs_sync.c	2011-02-07 13:40:00.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_sync.c	2011-02-09 01:59:46.771351460 +0200
@@ -374,8 +374,8 @@ get_curr_sync_buff(struct netns_ipvs *ip
  	struct ip_vs_sync_buff *sb;

  	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff && (time == 0 ||
-	    time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+	if (ipvs->sync_buff &&
+	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
  		sb = ipvs->sync_buff;
  		ipvs->sync_buff = NULL;
  	} else
