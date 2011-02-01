From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/4] IPVS: use z modifier for sizeof() argument
Date: Tue,  1 Feb 2011 11:14:12 +1100
Message-ID: <1296519255-10602-2-git-send-email-horms@verge.net.au>
References: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Cc: Hans Schillstrom <hans@schillstrom.com>
Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d889f4f..4d06617 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1887,7 +1887,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
-	printk(KERN_INFO "IPVS: Creating netns size=%lu id=%d\n",
+	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
 			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
 }
-- 
1.7.2.3
