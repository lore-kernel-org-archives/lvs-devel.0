From: YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH net-next] ipvs: Remove unused macros
Date: Fri, 18 Sep 2020 21:16:56 +0800
Message-ID: <20200918131656.46260-1-yuehaibing@huawei.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>

They are not used since commit e4ff67513096 ("ipvs: add
sync_maxlen parameter for the sync daemon")

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2b8abbfe018c..16b48064f715 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -242,9 +242,6 @@ struct ip_vs_sync_thread_data {
       |                    IPVS Sync Connection (1)                   |
 */
 
-#define SYNC_MESG_HEADER_LEN	4
-#define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
