From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: Use correct lock in SCTP module
Date: Thu,  3 Feb 2011 20:52:05 +0900
Message-ID: <1296733925-23131-2-git-send-email-horms@verge.net.au>
References: <1296733925-23131-1-git-send-email-horms@verge.net.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296733925-23131-1-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>

Use sctp_app_lock instead of tcp_app_lock in the SCTP protocol module.

This appears to be a typo introduced by the netns changes.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb2d04a..b027ccc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1101,7 +1101,7 @@ static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->tcp_app_lock);
+	spin_lock_init(&ipvs->sctp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
 }
-- 
1.7.2.3
