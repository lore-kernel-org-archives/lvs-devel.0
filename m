From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v3 10/14] netfilter: Update to
	register_net_sysctl_sz
Date: Wed,  9 Aug 2023 12:50:02 +0200
Message-ID: <20230809105006.1198165-11-j.granados@samsung.com>
References: <20230809105006.1198165-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 90C27830C5
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 6F873830E3
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 083EB41877
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 8971041893
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1691578229; x=1692183029;
 h=content-transfer-encoding:mime-version:references:in-reply-to
 :message-id:date:subject:cc:to:from:from:to:cc:subject:date
 :message-id:reply-to;
 bh=96SMSIXLVkZfqbaV9batFLU523UsmZ99h7lWRpVXrNI=;
 b=VEpYGGIQtxCIc/hqI59n7RIzgYZEXsBVDIEFWGLTkNIMchoJzdF7jCzqz8pJ6FaEMi
 ZO3eTu4w/wKhi80SSxicLz2KHZR1EjJZ25jkriimySUMX4OpWJLk/WfZAVRwdFF78k1Q
 fBld8iyWk2HDPheDhHNixKQ06Q6WFU+8GrhkYKdFQedcPSWtTtZ0ykM1e1tBGkjaFu3h
 Tj874b/JgSQ6/tG1t59vneijYp2wvWMHbiy/dd3OdVuKaDhndRPCBZuT5KK4Suyx/iaA
 CRijwNZNjW8vRuYiKN0JpHQtLj5tYLz8Qu0XbMgOUT6GLANkyMOR+WqzGuJJ0Mnjioo6
 yz0g==
In-Reply-To: <20230809105006.1198165-1-j.granados@samsung.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Joel Granados <j.granados@samsung.com>, Alexander Aring <alex.aring@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, core

Move from register_net_sysctl to register_net_sysctl_sz for all the
netfilter related files. Do this while making sure to mirror the NULL
assignments with a table_size of zero for the unprivileged users.

We need to move to the new function in preparation for when we change
SIZE_MAX to ARRAY_SIZE() in the register_net_sysctl macro. Failing to do
so would erroneously allow ARRAY_SIZE() to be called on a pointer. We
hold off the SIZE_MAX to ARRAY_SIZE change until we have migrated all
the relevant net sysctl registering functions to register_net_sysctl_sz
in subsequent commits.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Joel Granados <j.granados@samsung.com>
---
 net/bridge/br_netfilter_hooks.c         |  3 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c          |  8 ++++++--
 net/netfilter/ipvs/ip_vs_lblc.c         | 10 +++++++---
 net/netfilter/ipvs/ip_vs_lblcr.c        | 10 +++++++---
 net/netfilter/nf_conntrack_standalone.c |  4 +++-
 net/netfilter/nf_log.c                  |  7 ++++---
 7 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 1a801fab9543..15186247b59a 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1135,7 +1135,8 @@ static int br_netfilter_sysctl_init_net(struct net *net)
 
 	br_netfilter_sysctl_default(brnet);
 
-	brnet->ctl_hdr = register_net_sysctl(net, "net/bridge", table);
+	brnet->ctl_hdr = register_net_sysctl_sz(net, "net/bridge", table,
+						ARRAY_SIZE(brnf_table));
 	if (!brnet->ctl_hdr) {
 		if (!net_eq(net, &init_net))
 			kfree(table);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index d13240f13607..b2dd48911c8d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -87,7 +87,8 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	table[2].data	= &nf_frag->fqdir->high_thresh;
 	table[2].extra1	= &nf_frag->fqdir->low_thresh;
 
-	hdr = register_net_sysctl(net, "net/netfilter", table);
+	hdr = register_net_sysctl_sz(net, "net/netfilter", table,
+				     ARRAY_SIZE(nf_ct_frag6_sysctl_table));
 	if (hdr == NULL)
 		goto err_reg;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 62606fb44d02..8d69e4c2d822 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4266,6 +4266,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	struct net *net = ipvs->net;
 	struct ctl_table *tbl;
 	int idx, ret;
+	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
 
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
@@ -4282,8 +4283,10 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 			return -ENOMEM;
 
 		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
+		if (net->user_ns != &init_user_ns) {
 			tbl[0].procname = NULL;
+			ctl_table_size = 0;
+		}
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
@@ -4353,7 +4356,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 #endif
 
 	ret = -ENOMEM;
-	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
+	ipvs->sysctl_hdr = register_net_sysctl_sz(net, "net/ipv4/vs", tbl,
+						  ctl_table_size);
 	if (!ipvs->sysctl_hdr)
 		goto err;
 	ipvs->sysctl_tbl = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 1b87214d385e..cf78ba4ce5ff 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -550,6 +550,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler = {
 static int __net_init __ip_vs_lblc_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	size_t vars_table_size = ARRAY_SIZE(vs_vars_table);
 
 	if (!ipvs)
 		return -ENOENT;
@@ -562,16 +563,19 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 			return -ENOMEM;
 
 		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
+		if (net->user_ns != &init_user_ns) {
 			ipvs->lblc_ctl_table[0].procname = NULL;
+			vars_table_size = 0;
+		}
 
 	} else
 		ipvs->lblc_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblc_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
-	ipvs->lblc_ctl_header =
-		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblc_ctl_table);
+	ipvs->lblc_ctl_header = register_net_sysctl_sz(net, "net/ipv4/vs",
+						       ipvs->lblc_ctl_table,
+						       vars_table_size);
 	if (!ipvs->lblc_ctl_header) {
 		if (!net_eq(net, &init_net))
 			kfree(ipvs->lblc_ctl_table);
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index ad8f5fea6d3a..9eddf118b40e 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -736,6 +736,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 static int __net_init __ip_vs_lblcr_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	size_t vars_table_size = ARRAY_SIZE(vs_vars_table);
 
 	if (!ipvs)
 		return -ENOENT;
@@ -748,15 +749,18 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 			return -ENOMEM;
 
 		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
+		if (net->user_ns != &init_user_ns) {
 			ipvs->lblcr_ctl_table[0].procname = NULL;
+			vars_table_size = 0;
+		}
 	} else
 		ipvs->lblcr_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblcr_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
-	ipvs->lblcr_ctl_header =
-		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblcr_ctl_table);
+	ipvs->lblcr_ctl_header = register_net_sysctl_sz(net, "net/ipv4/vs",
+							ipvs->lblcr_ctl_table,
+							vars_table_size);
 	if (!ipvs->lblcr_ctl_header) {
 		if (!net_eq(net, &init_net))
 			kfree(ipvs->lblcr_ctl_table);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 169e16fc2bce..0ee98ce5b816 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -1106,7 +1106,9 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		table[NF_SYSCTL_CT_BUCKETS].mode = 0444;
 	}
 
-	cnet->sysctl_header = register_net_sysctl(net, "net/netfilter", table);
+	cnet->sysctl_header = register_net_sysctl_sz(net, "net/netfilter",
+						     table,
+						     ARRAY_SIZE(nf_ct_sysctl_table));
 	if (!cnet->sysctl_header)
 		goto out_unregister_netfilter;
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8a29290149bd..8cc52d2bd31b 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -487,9 +487,10 @@ static int netfilter_log_sysctl_init(struct net *net)
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 		table[i].extra2 = net;
 
-	net->nf.nf_log_dir_header = register_net_sysctl(net,
-						"net/netfilter/nf_log",
-						table);
+	net->nf.nf_log_dir_header = register_net_sysctl_sz(net,
+							   "net/netfilter/nf_log",
+							   table,
+							   ARRAY_SIZE(nf_log_sysctl_table));
 	if (!net->nf.nf_log_dir_header)
 		goto err_reg;
 
-- 
2.30.2

