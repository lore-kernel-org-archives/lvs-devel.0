Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADFFE50297;
	Tue, 28 May 2024 08:03:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716883417; cv=none; b=NzU+FXEt54Ly1ogKjFMtgzwUA3dhT5N3lCx3bb2FNago994P+es8qyfZcBWidEABXZn5zqxXanAuxHCdvB7AtFVTmyxuxzeY0l7isrKw4kv29KcxjmMQntO2r3UAgw22iqH0EmgSbIBz2esDU3tPcSPbgsJ1GUS9lMv4vbV8qZo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716883417; c=relaxed/simple;
	bh=nh/oUlSx3he3ql9COZxfd5A88pZPVABEqrSxH2APpf8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YM6id2bF5vwaDZqDqEcrQut0C/GLw39PQ2Te75qnmEzYPFcQacMK7b8o/vpo4l7HqA5RXJOHhzuDKU61YWIwEqbklId7cDJ8/rCUOcE50C99mLn3hocAZeVnFPt1ayT6uCyMmkWwTFxqFT9fxsg1VEdPktBz4vblHXwhJ3ICQAU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Dq/epIeq; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Dq/epIeq"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 220F4845F;
	Tue, 28 May 2024 11:03:34 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Tue, 28 May 2024 11:03:33 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 0870E90089B;
	Tue, 28 May 2024 11:02:56 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1716883376; bh=nh/oUlSx3he3ql9COZxfd5A88pZPVABEqrSxH2APpf8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Dq/epIequxvOQjUCggDQlvKKN+tsxgkzzkXRf9Tc1UkmAxlqp/FOuS175BHJVcf+t
	 nIhZcwzMC2xXC3svdAqTTLzpcBXHIdrfAL2Dt9QESk0+i5EibiDqH/Ubz/5Untdw1w
	 gbCa+ezCmDNrc9bFcrEpIAPQygEvJJc1beorMaqA=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 44S82tQF010237;
	Tue, 28 May 2024 11:02:55 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 44S82tOU010236;
	Tue, 28 May 2024 11:02:55 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv4 net-next 14/14] ipvs: add conn_lfactor and svc_lfactor sysctl vars
Date: Tue, 28 May 2024 11:02:34 +0300
Message-ID: <20240528080234.10148-15-ja@ssi.bg>
X-Mailer: git-send-email 2.45.1
In-Reply-To: <20240528080234.10148-1-ja@ssi.bg>
References: <20240528080234.10148-1-ja@ssi.bg>
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
 Documentation/networking/ipvs-sysctl.rst | 33 ++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c           | 76 ++++++++++++++++++++++++
 2 files changed, 109 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 3fb5fa142eef..ee9f70f446b4 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -29,6 +29,30 @@ backup_only - BOOLEAN
 	If set, disable the director function while the server is
 	in backup mode to avoid packet loops for DR/TUN methods.
 
+conn_lfactor - INTEGER
+	-4 - default
+	Valid range: -8 (larger table) .. 8 (smaller table)
+
+	Controls the sizing of the connection hash table based on the
+	load factor (number of connections per table buckets):
+		2^conn_lfactor = nodes / buckets
+	As result, the table grows if load increases and shrinks when
+	load decreases in the range of 2^8 - 2^conn_tab_bits (module
+	parameter).
+	The value is a shift count where negative values select
+	buckets = (connection hash nodes << -value) while positive
+	values select buckets = (connection hash nodes >> value). The
+	negative values reduce the collisions and reduce the time for
+	lookups but increase the table size. Positive values will
+	tolerate load above 100% when using smaller table is
+	preferred with the cost of more collisions. If using NAT
+	connections consider decreasing the value with one because
+	they add two nodes in the hash table.
+
+	Example:
+	-4: grow if load goes above 6% (buckets = nodes * 16)
+	2: grow if load goes above 400% (buckets = nodes / 4)
+
 conn_reuse_mode - INTEGER
 	1 - default
 
@@ -219,6 +243,15 @@ secure_tcp - INTEGER
 	The value definition is the same as that of drop_entry and
 	drop_packet.
 
+svc_lfactor - INTEGER
+	-3 - default
+	Valid range: -8 (larger table) .. 8 (smaller table)
+
+	Controls the sizing of the service hash table based on the
+	load factor (number of services per table buckets). The table
+	will grow and shrink in the range of 2^4 - 2^20.
+	See conn_lfactor for explanation.
+
 sync_threshold - vector of 2 INTEGERs: sync_threshold, sync_period
 	default 3 50
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6b84b6f17a32..aea53ee13316 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2431,6 +2431,60 @@ static int ipvs_proc_run_estimation(struct ctl_table *table, int write,
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
@@ -2619,6 +2673,18 @@ static struct ctl_table vs_vars[] = {
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
@@ -4864,6 +4930,16 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_est_nice;
 
+	if (unpriv)
+		tbl[idx].mode = 0444;
+	tbl[idx].extra2 = ipvs;
+	tbl[idx++].data = &ipvs->sysctl_conn_lfactor;
+
+	if (unpriv)
+		tbl[idx].mode = 0444;
+	tbl[idx].extra2 = ipvs;
+	tbl[idx++].data = &ipvs->sysctl_svc_lfactor;
+
 #ifdef CONFIG_IP_VS_DEBUG
 	/* Global sysctls must be ro in non-init netns */
 	if (!net_eq(net, &init_net))
-- 
2.44.0


