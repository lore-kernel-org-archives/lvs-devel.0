From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 02/84] ipvs: Don't use current in proc_do_defense_mode
Date: Thu, 24 Sep 2015 09:51:47 +0900
Message-ID: <1443055989-1306-3-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Instead store ipvs in extra2 so that proc_do_defense_mode can easily
find the ipvs that it's value is associated with.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7338827ee5e9..6162ae56e47a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1615,7 +1615,7 @@ static int
 proc_do_defense_mode(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct net *net = current->nsproxy->net_ns;
+	struct netns_ipvs *ipvs = table->extra2;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
@@ -1626,7 +1626,7 @@ proc_do_defense_mode(struct ctl_table *table, int write,
 			/* Restore the correct value */
 			*valp = val;
 		} else {
-			update_defense_level(net_ipvs(net));
+			update_defense_level(ipvs);
 		}
 	}
 	return rc;
@@ -3866,6 +3866,10 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
+	for (idx = 0; idx < ARRAY_SIZE(vs_vars); idx++) {
+		if (tbl[idx].proc_handler == proc_do_defense_mode)
+			tbl[idx].extra2 = ipvs;
+	}
 	idx = 0;
 	ipvs->sysctl_amemthresh = 1024;
 	tbl[idx++].data = &ipvs->sysctl_amemthresh;
-- 
2.1.4
