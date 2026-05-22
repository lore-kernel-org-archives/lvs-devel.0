Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 854583CC9FF;
	Fri, 22 May 2026 10:56:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779447385; cv=none; b=tDvHeXKFNq/YK5kz6dO4CcyOyrOvoOUt2zG5NtAl6VzwU3mzTYyHKxyO+Z3PaYzf5gUR3Ix+mvOeLMbAmfbqkVK402uxQmPcauj9I6AQzsPJGbQvbn66PgsDMN1+ok9hIQ9gWewQku6HzJHHpT20Uq9W95cT0/HyPxyTGUs5T8w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779447385; c=relaxed/simple;
	bh=H1NHdBiovjydmqp0KZ+5/23qjRnoAHkFGd7cdupcXX8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eQFiavGoADPPAco/NjSO0Faaq37Z/SB3WuWbHnJaAmBFZHNxG3lo6Dl5SHpWEWCbvuje6/ZqmepIBmWdQF74G+ewiOQSebzSBGCtOFAiPIz/iQv4rBXgTf4Ldn4Zvc3zH2h+ONetuuiRljujC634zUc2j7GaBxUQjrFW84KM7D8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ncnRaY+Y; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ncnRaY+Y"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 680D220FC2;
	Fri, 22 May 2026 13:56:11 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=oWFMGIAK
	5HEeHQf4FQt5J7q1SiArG/MAItcCUdvXXQw=; b=ncnRaY+YyMIJOh+6gRfVnSgj
	/0n/38jti9A/mgdXmw8vYOxQe4hZ3uKtCn7ba1uv6JafmZNtDIDRCDWCWxbnkJ1+
	McKkjwvydW+IfRVwKQz2yvykzz3IuddwzvfNuuZiDXTwjs2D3gUylREflCvMMyf6
	QG775esDmWdAbLrWTbVqc3bciBAd7F4HbyAdwTiX45dSHPL1n5Pp3ixtOdR8kR2W
	yAPCO6QSbT9uHPsKXncYs4V/VsoFi1Sd0CFSBnk0ZCg19mj/hkXL95DOIt0idLX8
	PZUMoP7/llMQmYcDw/ibpX+VzIUcT55izla0/72qGfXJhr2PwCn3Xs/73PG7LonM
	6So+D+YSATiUL1d2b5tb3BICrklBq5dezNJBtENwEFzCkt84rpJxEAQDCS5LyEjn
	oDVUVNCIFQnuGOS3NVByWEUc6l5pk0xkZctG7B17y18/cmHQ53jnHxd+e2mw9xYq
	kZREhQAQFyn1rIha7gTa6xAe7/gejbU8W6KuwCTWPEN9vdvkvnJ9nJgYUuME0500
	Zy5A/H1zMdbOmlOltd2Pgf04ghh4+oQa7AuXcXBrJVrw0phl3FhqiJCDehAN4LEA
	UZwgfcWi1oybrouGsbm/EQD/CIIQ81pfF/BaEcQGlmEOI+yo2v1dMoTje8pswWdd
	fz4EjxIEv3i3xJFzJVs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 22 May 2026 13:56:11 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7CCC0609B3;
	Fri, 22 May 2026 13:56:10 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64MAu2Sg013746;
	Fri, 22 May 2026 13:56:02 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 64MAu2hX013745;
	Fri, 22 May 2026 13:56:02 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf-next] ipvs: add conn_max sysctl to limit connections
Date: Fri, 22 May 2026 13:55:45 +0300
Message-ID: <20260522105546.13732-1-ja@ssi.bg>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Currently, we are using atomic_t to track the number of
connections. On 64-bit setups with large memory there is
a risk this counter to overflow. Also, setups with many
containers may need to tune the limit for connections.

Add sysctl control to limit the number of connections to
1,073,741,824 (64-bit) and 16,777,216 (32-bit).
Depending on the admin's privilege, the value is
used to change a soft or hard limit allowing
unprivileged admins to change the soft limit in
range determined by privileged admins.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Documentation/networking/ipvs-sysctl.rst | 35 ++++++++++++++++++
 include/net/ip_vs.h                      | 22 +++++++++++
 net/netfilter/ipvs/ip_vs_conn.c          | 10 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c           | 47 ++++++++++++++++++++++++
 4 files changed, 113 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index a556439f8be7..b6bac2612420 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -56,6 +56,41 @@ conn_lfactor - INTEGER
 	-4: grow if load goes above 6% (buckets = nodes * 16)
 	2: grow if load goes above 400% (buckets = nodes / 4)
 
+conn_max - INTEGER
+	Limit for number of connections, per netns.
+
+	Controls the soft and hard limit for number of connections.
+	Initially, the platform specific limit is assigned for init_net.
+	The value can be changed and later the soft limit propagated
+	to other networking namespaces.
+
+	Privileged admin can change both limits up to the value of the
+	platform limit while the unprivileged admin can change only the
+	soft limit up to the value of the hard limit.
+
+	For setups using conntrack=1 (CONFIG_IP_VS_NFCT for
+	Netfilter connection tracking) the connections can be
+	limited also by nf_conntrack_max.
+
+				soft limit	hard limit
+	=====================================================
+	init_net:
+	create netns		platform	platform
+	priv admin		0 .. platform	0 .. platform
+	=====================================================
+	new netns:
+	create netns		init_net:soft	init_net:soft
+	priv admin		0 .. platform	0 .. platform
+	unpriv admin		0 .. hard	N/A
+
+	Limits per platform:
+	1,073,741,824 (2^30 for 64-bit)
+	   16,777,216 (2^24 for 32-bit)
+
+	Possible values: 0 .. platform limit
+
+	Default: platform limit
+
 conn_reuse_mode - INTEGER
 	1 - default
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a02e569813d2..5b3d1c681231 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -44,6 +44,14 @@
 #define IP_VS_CONN_TAB_MAX_BITS	20
 #endif
 
+/* conn_max limits */
+#if BITS_PER_LONG > 32
+/* Limit of atomic_t but restricted by roundup_pow_of_two() in ip_vs_core.c */
+#define IP_VS_CONN_MAX	(1 << 30)
+#else
+#define IP_VS_CONN_MAX	(1 << 24)
+#endif
+
 /* svc_table limits */
 #define IP_VS_SVC_TAB_MIN_BITS	4
 #define IP_VS_SVC_TAB_MAX_BITS	20
@@ -1220,6 +1228,10 @@ struct netns_ipvs {
 	/* sysctl variables */
 	int			sysctl_amemthresh;
 	int			sysctl_am_droprate;
+#ifdef CONFIG_SYSCTL
+	int			sysctl_conn_max;/* soft limit for conns */
+	int			conn_max_limit;	/* hard limit for conn_max */
+#endif
 	int			sysctl_drop_entry;
 	int			sysctl_drop_packet;
 	int			sysctl_secure_tcp;
@@ -1317,6 +1329,11 @@ struct netns_ipvs {
 
 #ifdef CONFIG_SYSCTL
 
+static inline int sysctl_conn_max(struct netns_ipvs *ipvs)
+{
+	return READ_ONCE(ipvs->sysctl_conn_max);
+}
+
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_threshold[0];
@@ -1436,6 +1453,11 @@ static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
 
 #else
 
+static inline int sysctl_conn_max(struct netns_ipvs *ipvs)
+{
+	return IP_VS_CONN_MAX;
+}
+
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
 {
 	return DEFAULT_SYNC_THRESHOLD;
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 9ea6b4fa78bf..e76a73d183d5 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1358,9 +1358,18 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	struct netns_ipvs *ipvs = p->ipvs;
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->ipvs,
 							   p->protocol);
+	/* Increment conn_count up to conn_max */
+	int count = atomic_read(&ipvs->conn_count);
+	int max = sysctl_conn_max(ipvs);
+
+	do {
+		if (count >= max)
+			return NULL;
+	} while (!atomic_try_cmpxchg(&ipvs->conn_count, &count, count + 1));
 
 	cp = kmem_cache_alloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
+		atomic_dec(&ipvs->conn_count);
 		IP_VS_ERR_RL("%s(): no memory\n", __func__);
 		return NULL;
 	}
@@ -1414,7 +1423,6 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	cp->in_seq.delta = 0;
 	cp->out_seq.delta = 0;
 
-	atomic_inc(&ipvs->conn_count);
 	if (unlikely(flags & IP_VS_CONN_F_NO_CPORT)) {
 		int af_id = ip_vs_af_index(cp->af);
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bd9cae44d214..bd9d494b208a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2319,6 +2319,39 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 
 #ifdef CONFIG_SYSCTL
 
+static int
+proc_do_conn_max(const struct ctl_table *table, int write,
+		 void *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = table->data;
+	int val = *valp;
+	int rc;
+
+	const struct ctl_table tmp = {
+		.data = &val,
+		.maxlen = sizeof(int),
+		.mode = table->mode,
+	};
+
+	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
+	if (write && (*valp != val)) {
+		struct netns_ipvs *ipvs = table->extra2;
+		bool priv = capable(CAP_NET_ADMIN);
+		/* Unprivileged admins can not go above the hard limit */
+		int max = priv ? IP_VS_CONN_MAX : ipvs->conn_max_limit;
+
+		if (val < 0 || val > max) {
+			rc = -EINVAL;
+		} else {
+			/* Privileged admin changes both limits */
+			if (priv)
+				ipvs->conn_max_limit = val;
+			WRITE_ONCE(*valp, val);
+		}
+	}
+	return rc;
+}
+
 static int
 proc_do_defense_mode(const struct ctl_table *table, int write,
 		     void *buffer, size_t *lenp, loff_t *ppos)
@@ -2623,6 +2656,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "conn_max",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_do_conn_max,
+	},
 	{
 		.procname	= "drop_entry",
 		.maxlen		= sizeof(int),
@@ -4977,6 +5016,14 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_amemthresh;
 	ipvs->sysctl_am_droprate = 10;
 	tbl[idx++].data = &ipvs->sysctl_am_droprate;
+
+	/* Inherit both limits from init_net:conn_max */
+	ipvs->conn_max_limit = net_eq(net, &init_net) ? IP_VS_CONN_MAX :
+			       READ_ONCE(*(int *)vs_vars[idx].data);
+	ipvs->sysctl_conn_max = ipvs->conn_max_limit;
+	tbl[idx].extra2 = ipvs;
+	tbl[idx++].data = &ipvs->sysctl_conn_max;
+
 	tbl[idx++].data = &ipvs->sysctl_drop_entry;
 	tbl[idx++].data = &ipvs->sysctl_drop_packet;
 #ifdef CONFIG_IP_VS_NFCT
-- 
2.54.0


