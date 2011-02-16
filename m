From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/3] ipvs: fix timer in get_curr_sync_buff
Date: Wed, 16 Feb 2011 15:04:51 +0900
Message-ID: <1297836293-5942-2-git-send-email-horms@verge.net.au>
References: <1297836293-5942-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1297836293-5942-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Patrick Schaaf <netdev@bof.de>, Patrick McHardy <kaber@trash.net>, Tinggong Wang <wangtinggong@gmail.com>, Simon Horman <horms@verge.net.au>

From: Tinggong Wang <wangtinggong@gmail.com>

 	Fix get_curr_sync_buff to keep buffer for 2 seconds
as intended, not just for the current jiffie. By this way
we will sync more connection structures with single packet.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d1b7298..fecf24d 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -374,8 +374,8 @@ get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff && (time == 0 ||
-	    time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+	if (ipvs->sync_buff &&
+	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
 		sb = ipvs->sync_buff;
 		ipvs->sync_buff = NULL;
 	} else
-- 
1.7.2.3

