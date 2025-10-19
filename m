Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B8781A316E;
	Sun, 19 Oct 2025 16:01:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760889690; cv=none; b=FtkL4Dc5LC3Ilv3HPkkeeuxQslpj14ouV6yDHscG/mT5z5FahOYgqY5xkep3cmu5ypxFZAjt5S+MY5dP/66AwYyj9n7otDR8OROwPoJjH+hOVhSD6OYRiwt6MRJrcenCraa3/CuBneV2N9tj9DPTE3U22WjYYmEW6KXqJokZCWI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760889690; c=relaxed/simple;
	bh=56RCEDR23qNRC22FbXya0KUfo/PM5Nz94TSkfJqqgf0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Jj5I4D3M0RRD50/bRBnOkptlHvpcNUTf1/qovqrlDB8Sq/xohA8lQvtBwiRTRduvWMq5umKk2OH2kjln9834tBhvjUD81UUDgVj1dR8qQVV63BohKSdQSTOxAziQf4/cYD0Z8EOu1XDw2Os+ROo8iWrlBL28pGLbjiJdouw3QdE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=wrm0c2Im; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="wrm0c2Im"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 4C0AD21EF2;
	Sun, 19 Oct 2025 19:01:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=GgDUTIoyEE129o/76K9UcxSK9J6ndvVOWmnhagO/6wM=; b=wrm0c2ImXeUv
	mGLZNvSWZ2JHNuN7GnYvkQWUiSX31NmR+ilqp4DKY5G5h9zDoFPdOeMg10IYIMgn
	KPnypmlTlyYTeYH5/L7p8Zf9GV0nzPb9FRIRDA5Nrxx7NbP7bOYbaAvKcPQCVT3T
	L3aisdHTrosfFChS712s5ukFAbzhn+0SgHq+9AzrO/kwIawS2F8zbn3FNn36iowj
	PAZjGuM/IZQd4lPvwn35muWypCREUT4Dv/nJ+kEy9Xug967h4sL5SUDin+A/7rL+
	MUceStnmv0MeMXkEjAUNywYpZ6OSvRgSWa2zoqPOsIOW+t6Uxax4QFFQkVGVhAon
	s/sqXETt7S+iFWV4m0AjwShFGviJTqNycFstx3Yh3z2XS4ywq+Fjp7exWSHa/C9b
	EhAhac3YnhrDTudQ7/sbDGekljjIwd7kpiZAnDYn5t1h5QnS+jxW8xE2VgAPpCZH
	RC5wWTv4e4MBf0Krm5rI5wE2bn3U5YEnKtQDbML+JWDudEuZhyzJj6rtvN7E5aHx
	FMQF/iWK5Jweb+6tiDaZjcseKfmmxsoIDEdtD/RJ94A7aAXEqBTpjpzbKkE2XoTa
	ugSkGNvngXOgO9elbij+g2oVrsOmV7xWpT97xVA75GPX2j4dRSP6U7POtWtA7SMs
	if5ODl6VlCWwdk0mvi7cF/HRzFuMEj8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 19 Oct 2025 19:01:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id EBAE364EA9;
	Sun, 19 Oct 2025 19:01:08 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 59JFvgHb067709;
	Sun, 19 Oct 2025 18:57:42 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 59JFvgsW067708;
	Sun, 19 Oct 2025 18:57:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv6 net-next 14/14] ipvs: add conn_lfactor and svc_lfactor sysctl vars
Date: Sun, 19 Oct 2025 18:57:11 +0300
Message-ID: <20251019155711.67609-15-ja@ssi.bg>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20251019155711.67609-1-ja@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg>
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
index a508e9bdde73..086aaf13c8db 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2433,6 +2433,60 @@ static int ipvs_proc_run_estimation(const struct ctl_table *table, int write,
 	return ret;
 }
 
+static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
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
+static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
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
@@ -2621,6 +2675,18 @@ static struct ctl_table vs_vars[] = {
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
@@ -4863,6 +4929,16 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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
2.51.0


