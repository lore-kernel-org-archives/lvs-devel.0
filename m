From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 2/2] netfilter: ipvs: avoid unused variable warnings
Date: Thu, 18 Feb 2016 09:28:42 +0900
Message-ID: <1455755322-19972-3-git-send-email-horms@verge.net.au>
References: <1455755322-19972-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1455755340; bh=R2UssbcmlHDG5xmBwD4IftK8doaKnrPTFMkC3nWKu6A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=FlwMjZ8hCwDYJ7mGn9zPtwlR4dwVTs3xgRGweM8dpLSYIzUXirduqNXCnpddDoxa9
	 T4RmykKsyUM4h73Ure7JgHpNC0/JJn6vj5Bm2nX6nqZFZVRWS5sWC5Sojxj/6UMYo6
	 /xQllwJwZkrgn3etCngfyA+g9pLmSH3N/O7aR460=
In-Reply-To: <1455755322-19972-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Arnd Bergmann <arnd@arndb.de>, Simon Horman <horms@verge.net.au>

From: Arnd Bergmann <arnd@arndb.de>

The proc_create() and remove_proc_entry() functions do not reference
their arguments when CONFIG_PROC_FS is disabled, so we get a couple
of warnings about unused variables in IPVS:

ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3950:14: warning: unused variable 'net' [-Wunused-variable]
ipvs/ip_vs_ctl.c:3994:14: warning: unused variable 'net' [-Wunused-variable]

This removes the local variables and instead looks them up separately
for each use, which obviously avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 4c50a8ce2b63 ("netfilter: ipvs: avoid unused variable warning")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_app.c |  8 ++------
 net/netfilter/ipvs/ip_vs_ctl.c | 15 ++++++---------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0328f7250693..299edc6add5a 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -605,17 +605,13 @@ static const struct file_operations ip_vs_app_fops = {
 
 int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
+	proc_create("ip_vs_app", 0, ipvs->net->proc_net, &ip_vs_app_fops);
 	return 0;
 }
 
 void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
-
 	unregister_ip_vs_app(ipvs, NULL /* all */);
-	remove_proc_entry("ip_vs_app", net->proc_net);
+	remove_proc_entry("ip_vs_app", ipvs->net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index daf4cb746974..404b2a4f4b5b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3945,7 +3945,6 @@ static struct notifier_block ip_vs_dst_notifier = {
 
 int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
 	int i, idx;
 
 	/* Initialize rs_table */
@@ -3972,9 +3971,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 	spin_lock_init(&ipvs->tot_stats.lock);
 
-	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
-	proc_create("ip_vs_stats", 0, net->proc_net, &ip_vs_stats_fops);
-	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
+	proc_create("ip_vs", 0, ipvs->net->proc_net, &ip_vs_info_fops);
+	proc_create("ip_vs_stats", 0, ipvs->net->proc_net, &ip_vs_stats_fops);
+	proc_create("ip_vs_stats_percpu", 0, ipvs->net->proc_net,
 		    &ip_vs_stats_percpu_fops);
 
 	if (ip_vs_control_net_init_sysctl(ipvs))
@@ -3989,13 +3988,11 @@ err:
 
 void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
