Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBBCB26A0A7;
	Mon, 23 Mar 2026 16:31:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774283494; cv=none; b=D93gjjMYlNn/mkMPojd0LXN3QpLLO4YcCpB/LQsAij6ir96smxIwLNcLaMJTjnoxkI6SbdYeUWlYJ6j8t9He7FmTt4R2U0MNZ68+oys5XxmBLVF8EQY+r8edTIHYYZ5uOCQU1gB0///eSqWY1ztOJAThub2m/uf+83bkkN9MkOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774283494; c=relaxed/simple;
	bh=x44BRjzQGNAYwPbQxrLYFOHS1XnY7WmoYsoke5VXAb8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bKstdupXHLYshXRjBtcseZqB9LcEWIzHnIwGzNt5iPQKK41XUjv5IJrVux4nzjhPqUz5uIVDDPx6MutmOzkgYtg6cMkYSjHaPlWUYZTj1TiUZaESEc+/bKLD2n1Xq1CFr7LseiNRg+bOLK9fioaDhiDvycnOhPDktGi7B3I4BYo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=nxLTfm87; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="nxLTfm87"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CF03321850;
	Mon, 23 Mar 2026 18:31:20 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=fwpWlYQ4SiFTqS1rvN/XlU8rTyCrz1M+rcmOL6knyFU=; b=nxLTfm87DLKq
	pYmKCY+B44L0IocBGckExJ6PjB1c0CCCUXVjuvqi8HKObXseXZu8cq/xxvAQKeRY
	ZiPVll81swrFch5IokqiZJZlwu7U8y0y+QgImVl43BG2KqZX6Py3thQbngLeR3NK
	I34b2rDmWpk6NGJmDk/Lpb0C8Co+TEDiwlQcYtIoBktcGLyAl5/H14jJrGZPNd8q
	Q5HZJfCNt6S6UQwtJ+Ulqc8cN34WEM5tTVlwk59oYbBZCcrLR7LOTktzqX6fVpiN
	UUPXBwXGspVB1u22NIOE9jsPa4rzklnrFD3LZZJgqfHE7ViJ5cPGnawalmcs4UyM
	mih6gUT95SPZNsEAC/61M/yzxZQ+eWKRXcs/tccWRD8WMIXKcIils1/xhCQyFgNy
	CvI51hImjFUkosFgFzXqp+uJLD3T9pW+UTVgM9jjNDFDr66DNbifSYaOBtXO0A5x
	7639N6LnihFU28wISCg/QOX9yCG64BE6Knxi/6LXJTG44YuDxa1xU1BwEnA8eK1G
	IxazPtzXwrxg+OZ+7IpoAZd0x8mT8YcHOE0F81bpty6sL9Pyvd9afslGpim2ctY8
	tzyfLZ4yT5j9vuQDGsVxXvjQ4LFRXCJAHXgMONSrZLkAMzLl+iNvO++Pqx0/xS4c
	weObAw8YM2GL6y1fnuXAKbebQP3INCo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 23 Mar 2026 18:31:19 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0E44660D1F;
	Mon, 23 Mar 2026 18:31:20 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 62NGQX0Q045013;
	Mon, 23 Mar 2026 18:26:33 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 62NGQXwf045012;
	Mon, 23 Mar 2026 18:26:33 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 3/3] ipvs: add conn_lfactor and svc_lfactor sysctl vars
Date: Mon, 23 Mar 2026 18:25:23 +0200
Message-ID: <20260323162523.44964-4-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260323162523.44964-1-ja@ssi.bg>
References: <20260323162523.44964-1-ja@ssi.bg>
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
index 88c3f145fa4a..df7430639e79 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2439,6 +2439,60 @@ static int ipvs_proc_run_estimation(const struct ctl_table *table, int write,
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
@@ -2627,6 +2681,18 @@ static struct ctl_table vs_vars[] = {
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


