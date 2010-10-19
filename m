From: Eduardo Blanco <ejblanco@google.com>
Subject: [PATCH] Fixed race condition at ip_vs.ko module init.
Date: Tue, 19 Oct 2010 10:26:47 +0100
Message-ID: <AANLkTinVcSK0Dqx4Pkp1dZskR8YmkGYkkrSNgDqX6psW@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1287480429; bh=MruO1pmKNAGxqbm+v1NH9okogyw=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type;
	b=poBaWYENVX1AwveQQwBz/r2hEMOl5046lfnCRcG4uChdwept1M+m6uABoTeIDNR/W
	 bYmbhLXaoh8QnVS8VwG1A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=beta;
        h=domainkey-signature:received:mime-version:received:from:date
         :message-id:subject:to:cc:content-type;
        bh=xsQSqwsfMnm4prkCpnAwhCeTrR52crrwBFQ/UNipuEg=;
        b=Yhh3u7PTLqT7S1dDRuoznyE8+x+5FTzLfmEI05sBPqCuZukDYUv3l+c6V6P0QjrkYN
         Jlk49aphP9iI3eHkL59Q==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Lists were initialized after the module was registered.  Multiple ipvsadm
processes at module load triggered a race condition that resulted in a null
pointer dereference in do_ip_vs_get_ctl(). As a result, __ip_vs_mutex
was left locked preventing all further ipvsadm commands.

Signed-off-by: Eduardo J. Blanco <ejblanco@google.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0f0c079..68624dc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3385,6 +3385,16 @@ int __init ip_vs_control_init(void)

 	EnterFunction(2);

+	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
+	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
+		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
+	}
+	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
+	}
+	smp_wmb();
+
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
@@ -3403,15 +3413,6 @@ int __init ip_vs_control_init(void)

 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars);

-	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
-	}
-	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
-	}
