Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE8532765D7;
	Sat,  4 Apr 2026 15:37:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775317051; cv=none; b=QpvQCjujcMuRj9fc+t++iI/CS6+PTyPzcq64fe2FVEYZQswscpTDpQPkXLmjnWt6E8MdrA/3ujueE63diDOMa4V2s18jSimFp2ewLL+ucBjkn1bBIcjiVzBiHKXNrEQJOjHZiGLqEW3OdqApX0atNApdvLiJm2AevsdIPcEq5JM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775317051; c=relaxed/simple;
	bh=0AcHdYKpyk/ve/9v5b85h8vnpiXNF3Q9qnlCZnmbjkw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nWpC6L+y+vQN/RvjaxOg0gIhh1LaA2OUr7wFXea+2f4hKKEv9ToIKW6eeyB1HJJJ60M3Uo24LHRMUi/zj9JxeqqSYnn4kRVQ+xlF8A2zMSdjsPbwxFV5wA4zGDBr+nsx6AaXOWZCris3JgN/MMn0k5vsf4/TIVPG00ByFSVD2wQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Fj5SuTR2; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Fj5SuTR2"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2F8A521C5D;
	Sat, 04 Apr 2026 18:37:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IKNtC3sWk8fs5vW+4pGmB7vsVE293oMtstHYJtbH/vQ=; b=Fj5SuTR25w/N
	kV55J/OGidU6pSKF0mRyaEuRkNaoYUSk0rhyh3UrRQANFYd6FVJzCnSkXDno1VI7
	XIlLte5eHI0ErwyLRXaECGJdb634s91fCU09x5arUrc8QyLvVbo3cO15eFtGrkYT
	KeaCGCXkJIMHAljKN3HEHDwvrNHkvX4LGtAJnM2oLj5QCHGJgb1OtRzqvZAwk9Xa
	N7m3xQG7iOflL4Awn6augE2kuN9DoJK4eLmf8C19QXrKdVjs+kPhvFhyMEPvCQEc
	/YgOUweTxAU1xMpmPu9e4B+yQtG8lqmHOck1lGiMg3uVsC01wtYw16fpjHKdBDMf
	bqNeAEhB8JRjzVeAYrYK7XLczbax1WAbvUHL6xUWpvc4Su9v3UAPAc8whwyVXxTd
	jS+u24jd+1N/yICxpM04SIcQuaRfWmSW2Fw7KNqnCRifZHszN5TtdVdJ/K/+/Zb8
	4qdGxHKDBIDel2zt0KAdImtBHseYHvrw/6QY+v5NDfMr0lQP4jC87dPIOfF1K32C
	xRR4oa/Vlb4Xtrq5nDB+qESjeOHSjuVJfmBSau7OZNDXVoQKwNwT4qFIw/Mc8YPN
	w28hl8JGvUpr/QbHKIBYl783PpzqeJa05kRfj0ZjDD5+fXc6Lu6jDgqCAGa7COGN
	rSAZ6ctU5+Otx6tKIbt+fsXMpr+Apqg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 04 Apr 2026 18:37:19 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3866D60F6C;
	Sat,  4 Apr 2026 18:37:20 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 634FZD3p030111;
	Sat, 4 Apr 2026 18:35:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 634FZDmJ030110;
	Sat, 4 Apr 2026 18:35:13 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCHv2 nf-next 3/3] ipvs: add conn_lfactor and svc_lfactor sysctl vars
Date: Sat,  4 Apr 2026 18:34:39 +0300
Message-ID: <20260404153439.30077-4-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260404153439.30077-1-ja@ssi.bg>
References: <20260404153439.30077-1-ja@ssi.bg>
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
 Documentation/networking/ipvs-sysctl.rst | 35 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c           | 76 ++++++++++++++++++++++++
 2 files changed, 111 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 3fb5fa142eef..3c43857d7dbd 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -29,6 +29,31 @@ backup_only - BOOLEAN
 	If set, disable the director function while the server is
 	in backup mode to avoid packet loops for DR/TUN methods.
 
+conn_lfactor - INTEGER
+	Possible values: -8 (larger table) .. 8 (smaller table)
+
+	Default: -4
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
 
@@ -219,6 +244,16 @@ secure_tcp - INTEGER
 	The value definition is the same as that of drop_entry and
 	drop_packet.
 
+svc_lfactor - INTEGER
+	Possible values: -8 (larger table) .. 8 (smaller table)
+
+	Default: -3
+
+	Controls the sizing of the service hash table based on the
+	load factor (number of services per table buckets). The table
+	will grow and shrink in the range of 2^4 - 2^20.
+	See conn_lfactor for explanation.
+
 sync_threshold - vector of 2 INTEGERs: sync_threshold, sync_period
 	default 3 50
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b536799a725f..bc351e57a30c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2446,6 +2446,60 @@ static int ipvs_proc_run_estimation(const struct ctl_table *table, int write,
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
+			if (rcu_access_pointer(ipvs->conn_tab))
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
+			if (rcu_access_pointer(ipvs->svc_table))
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
@@ -2634,6 +2688,18 @@ static struct ctl_table vs_vars[] = {
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
@@ -4854,6 +4920,16 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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
2.53.0


