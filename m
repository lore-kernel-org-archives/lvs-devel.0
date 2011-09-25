From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: Removed unused conntrack sysctl entry
Date: Sun, 25 Sep 2011 09:49:03 +0900
Message-ID: <1316911743-28269-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>

This does not appear to be used anywhere.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

Julian, I cant see any users of this sysctl in the current code.
Am I missing something?

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 36f4495..49befca 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1605,14 +1605,6 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
-#ifdef CONFIG_IP_VS_NFCT
-	{
-		.procname	= "conntrack",
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-#endif
 	{
 		.procname	= "secure_tcp",
 		.maxlen		= sizeof(int),
@@ -3535,9 +3527,6 @@ int __net_init __ip_vs_control_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_am_droprate;
 	tbl[idx++].data = &ipvs->sysctl_drop_entry;
 	tbl[idx++].data = &ipvs->sysctl_drop_packet;
-#ifdef CONFIG_IP_VS_NFCT
-	tbl[idx++].data = &ipvs->sysctl_conntrack;
-#endif
 	tbl[idx++].data = &ipvs->sysctl_secure_tcp;
 	ipvs->sysctl_snat_reroute = 1;
 	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
-- 
1.7.5.4

