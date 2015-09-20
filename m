From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 02/84] ipvs: Don't use current in proc_do_defense_mode
Date: Sun, 20 Sep 2015 01:22:18 -0500
Message-ID: <1442730220-32458-2-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Instead store ipvs in extra2 so that proc_do_defense_mode can easily
find the ipvs that it's value is associated with.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7338827ee5e9..b88a1daeb78e 100644
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
+	for (idx = 0; idx < sizeof(vs_vars)/sizeof(vs_vars[0]); idx++) {
+		if (tbl[idx].proc_handler == proc_do_defense_mode)
+			tbl[idx].extra2 = ipvs;
+	}
 	idx = 0;
 	ipvs->sysctl_amemthresh = 1024;
 	tbl[idx++].data = &ipvs->sysctl_amemthresh;
-- 
2.2.1

