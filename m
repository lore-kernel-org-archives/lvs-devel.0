From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: freeing uninitialized pointer on error
Date: Mon, 28 Jan 2013 10:18:34 +0900
Message-ID: <1359335914-27325-2-git-send-email-horms@verge.net.au>
References: <1359335914-27325-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359335914-27325-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

From: Dan Carpenter <dan.carpenter@oracle.com>

If state != IP_VS_STATE_BACKUP then tinfo->buf is uninitialized.  If
kthread_run() fails then it means we free random memory resulting in an
oops.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index effa10c..44fd10c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1795,6 +1795,8 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 					     GFP_KERNEL);
 			if (!tinfo->buf)
 				goto outtinfo;
+		} else {
+			tinfo->buf = NULL;
 		}
 		tinfo->id = id;
 
-- 
1.7.10.4

