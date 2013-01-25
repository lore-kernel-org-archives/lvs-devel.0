From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ipvs: freeing uninitialized pointer on error
Date: Fri, 25 Jan 2013 18:44:57 +0300
Message-ID: <20130125154456.GB5908@elgon.mountain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

If state != IP_VS_STATE_BACKUP then tinfo->buf is uninitialized.  If
kthread_run() fails then it means we free random memory resulting in an
oops.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

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
 
