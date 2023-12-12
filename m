Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Gev/0u/s"
Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8279711B
	for <lvs-devel@vger.kernel.org>; Tue, 12 Dec 2023 08:30:22 -0800 (PST)
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id 1C3811E11F;
	Tue, 12 Dec 2023 18:30:21 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id 028871DE4D;
	Tue, 12 Dec 2023 18:30:21 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 34B173C07D1;
	Tue, 12 Dec 2023 18:30:12 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1702398612; bh=mUCkdfyyh2jiVCW0T3nBduEaNuO4SA1RzVDx0bZ7GEs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Gev/0u/sjiVVASoIADjHiSx1L3LnO8CFBYfqnRSN7wxvqtxJfEbneKp2O9RRMpHRd
	 MXKVbtTciqOMZzJ0rl9D7NgkMiw5VsxB4uMrUC1QxWgGMyPZJpCUiQMbzgl2EZs4W3
	 11XLUGj5ISVFZ5ZohwkosZGO2tW37SzkXEcsy+yk=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 3BCGQWrL094107;
	Tue, 12 Dec 2023 18:26:32 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 3BCGQW0o094106;
	Tue, 12 Dec 2023 18:26:32 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>,
        Jiri Wiesner <jwiesner@suse.de>
Subject: [PATCHv2 RFC net-next 14/14] ipvs: add conn_lfactor and svc_lfactor sysctl vars
Date: Tue, 12 Dec 2023 18:24:44 +0200
Message-ID: <20231212162444.93801-15-ja@ssi.bg>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20231212162444.93801-1-ja@ssi.bg>
References: <20231212162444.93801-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Allow the default load factor for the connection and service tables
to be configured.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Documentation/networking/ipvs-sysctl.rst | 31 ++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c           | 72 ++++++++++++++++++++++++
 2 files changed, 103 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 3fb5fa142eef..61fdc0ec4c39 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -29,6 +29,28 @@ backup_only - BOOLEAN
 	If set, disable the director function while the server is
 	in backup mode to avoid packet loops for DR/TUN methods.
 
+conn_lfactor - INTEGER
+	4 - default
+	Valid range: -8 (smaller table) .. 8 (larger table)
+
+	Controls the sizing of the connection hash table based on the
+	load factor (number of connections per table buckets).
+	As result, the table grows if load increases and shrinks when
+	load decreases in the range of 2^8 - 2^conn_tab_bits (module
+	parameter).
+	The value is a shift count where positive values select
+	buckets = (connection hash nodes << value) while negative
+	values select buckets = (connection hash nodes >> value). The
+	positive values reduce the collisions and reduce the time for
+	lookups but increase the table size. Negative values will
+	tolerate load above 100% when using smaller table is
+	preferred. If using NAT connections consider increasing the
+	value with one because they add two nodes in the hash table.
+
+	Example:
+	4: grow if load goes above 6% (buckets = nodes * 16)
+	-2: grow if load goes above 400% (buckets = nodes / 4)
+
 conn_reuse_mode - INTEGER
 	1 - default
 
@@ -219,6 +241,15 @@ secure_tcp - INTEGER
 	The value definition is the same as that of drop_entry and
 	drop_packet.
 
+svc_lfactor - INTEGER
+	3 - default
+	Valid range: -8 (smaller table) .. 8 (larger table)
+
+	Controls the sizing of the service hash table based on the
+	load factor (number of services per table buckets). The table
+	will grow and shrink in the range of 2^4 - 2^20.
+	See conn_lfactor for explanation.
+
 sync_threshold - vector of 2 INTEGERs: sync_threshold, sync_period
 	default 3 50
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 802447106959..e717c1cdf59c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2430,6 +2430,60 @@ static int ipvs_proc_run_estimation(struct ctl_table *table, int write,
 	return ret;
 }
 
+static int ipvs_proc_conn_lfactor(struct ctl_table *table, int write,
+				  void *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct netns_ipvs *ipvs = table->extra2;
+	int *valp = table->data;
+	int val = *valp;
+	int ret;
+
+	struct ctl_table tmp_table = {
+		.data = &val,
+		.maxlen = sizeof(int),
+	};
+
+	ret = proc_dointvec(&tmp_table, write, buffer, lenp, ppos);
+	if (write && ret >= 0) {
+		if (val < -8 || val > 8) {
+			ret = -EINVAL;
+		} else {
+			*valp = val;
+			if (rcu_dereference_protected(ipvs->conn_tab, 1))
+				mod_delayed_work(system_unbound_wq,
+						 &ipvs->conn_resize_work, 0);
+		}
+	}
+	return ret;
+}
+
+static int ipvs_proc_svc_lfactor(struct ctl_table *table, int write,
+				 void *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct netns_ipvs *ipvs = table->extra2;
+	int *valp = table->data;
+	int val = *valp;
+	int ret;
+
+	struct ctl_table tmp_table = {
+		.data = &val,
+		.maxlen = sizeof(int),
+	};
+
+	ret = proc_dointvec(&tmp_table, write, buffer, lenp, ppos);
+	if (write && ret >= 0) {
+		if (val < -8 || val > 8) {
+			ret = -EINVAL;
+		} else {
+			*valp = val;
+			if (rcu_dereference_protected(ipvs->svc_table, 1))
+				mod_delayed_work(system_unbound_wq,
+						 &ipvs->svc_resize_work, 0);
+		}
+	}
+	return ret;
+}
+
 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
  *	Do not change order or insert new entries without
@@ -2618,6 +2672,18 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= ipvs_proc_est_nice,
 	},
+	{
+		.procname	= "conn_lfactor",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= ipvs_proc_conn_lfactor,
+	},
+	{
+		.procname	= "svc_lfactor",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= ipvs_proc_svc_lfactor,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -4855,6 +4921,12 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_est_nice;
 
+	tbl[idx].extra2 = ipvs;
+	tbl[idx++].data = &ipvs->sysctl_conn_lfactor;
+
+	tbl[idx].extra2 = ipvs;
+	tbl[idx++].data = &ipvs->sysctl_svc_lfactor;
+
 #ifdef CONFIG_IP_VS_DEBUG
 	/* Global sysctls must be ro in non-init netns */
 	if (!net_eq(net, &init_net))
-- 
2.43.0


