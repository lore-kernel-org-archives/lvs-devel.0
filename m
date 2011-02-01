From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/4] IPVS: Remove unused variables
Date: Tue,  1 Feb 2011 11:14:14 +1100
Message-ID: <1296519255-10602-4-git-send-email-horms@verge.net.au>
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

These variables are unused as a result of the recent netns work.

Cc: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b23bea6..5d75fea 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1109,8 +1109,6 @@ extern int ip_vs_icmp_xmit_v6
  *	we are loaded. Just set ip_vs_drop_rate to 'n' and
  *	we start to drop 1/rate of the packets
  */
-extern int ip_vs_drop_rate;
-extern int ip_vs_drop_counter;
 
 static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 {
-- 
1.7.2.3
