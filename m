Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 118937347C;
	Tue, 28 May 2024 08:03:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716883401; cv=none; b=ebpdVsCNLY5cGQvYAH/azeGMXILJJA5NHi30j0IZfnHp74CpzB8TnG06Fa7uj/TGVS7C1ei3i3YnBP9fq6tsO3+dZWnhB7ZgnnqTXQpPYVKePreist1o43QZQRznmBCnSJ0I+7lFoCbsEKuYSYivv6lTwN0fxuMRal3Zot7O/UU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716883401; c=relaxed/simple;
	bh=unVa1nW1p5IhAyPkT8CUh/veT+5/KRQxyOLJnl0NKF8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Cy0h3/dP/bxrW94NPe6fzfTuDuulaPfu8KYHz/ihW8GHghh8WTRvPEpFapiobNyU1SUx+FLKwkNG5abA/3A1BIADQfoWQwlRWVu0NNMNA6JJyngQMyLlq6oij9YCnsIiBW8YMW+PQdJ7wzK3ClNYq2GvM2rzOQcJN/Eez+JQ9uU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=HY21A7og; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="HY21A7og"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 42FC285A5;
	Tue, 28 May 2024 11:03:17 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Tue, 28 May 2024 11:03:16 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 4A374900899;
	Tue, 28 May 2024 11:02:55 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1716883375; bh=unVa1nW1p5IhAyPkT8CUh/veT+5/KRQxyOLJnl0NKF8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HY21A7ogK/5F3K2R8UfRdAvBZVp2x4XfQDjb5wD8383zHLfVYBOpD15a709klQgx7
	 Zpy42/VrTdYLg554jjbA5iXjTM+o232UbguAjjatpMNmgE5E3MyNL7cBzi/h94jLiI
	 3x7VLlFtwKN2n3PnXabZTmPC7NnRkiz3X0JByudQ=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 44S82suP010221;
	Tue, 28 May 2024 11:02:54 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 44S82s3b010220;
	Tue, 28 May 2024 11:02:54 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv4 net-next 10/14] ipvs: show the current conn_tab size to users
Date: Tue, 28 May 2024 11:02:30 +0300
Message-ID: <20240528080234.10148-11-ja@ssi.bg>
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

As conn_tab is per-net, better to show the current hash table size
to users instead of the ip_vs_conn_tab_size (max).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 36 +++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 3f21c59db614..187a5e238231 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2741,10 +2741,16 @@ static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
 
 static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (v == SEQ_START_TOKEN) {
+		struct ip_vs_rht *tc = rcu_dereference(ipvs->conn_tab);
+		int csize = tc ? tc->size : 0;
+
 		seq_printf(seq,
 			"IP Virtual Server version %d.%d.%d (size=%d)\n",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE), csize);
 		seq_puts(seq,
 			 "Prot LocalAddress:Port Scheduler Flags\n");
 		seq_puts(seq,
@@ -3422,10 +3428,17 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	switch (cmd) {
 	case IP_VS_SO_GET_VERSION:
 	{
+		struct ip_vs_rht *t;
+		int csize = 0;
 		char buf[64];
 
+		rcu_read_lock();
+		t = rcu_dereference(ipvs->conn_tab);
+		if (t)
+			csize = t->size;
+		rcu_read_unlock();
 		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE), csize);
 		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
 			ret = -EFAULT;
 			goto out;
@@ -3437,8 +3450,16 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_INFO:
 	{
 		struct ip_vs_getinfo info;
+		struct ip_vs_rht *t;
+		int csize = 0;
+
+		rcu_read_lock();
+		t = rcu_dereference(ipvs->conn_tab);
+		if (t)
+			csize = t->size;
+		rcu_read_unlock();
 		info.version = IP_VS_VERSION_CODE;
-		info.size = ip_vs_conn_tab_size;
+		info.size = csize;
 		info.num_services =
 			atomic_read(&ipvs->num_services[IP_VS_AF_INET]);
 		if (copy_to_user(user, &info, sizeof(info)) != 0)
@@ -4380,6 +4401,8 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	int ret, cmd, reply_cmd;
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_rht *t;
+	int csize;
 
 	cmd = info->genlhdr->cmd;
 
@@ -4447,10 +4470,13 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	case IPVS_CMD_GET_INFO:
+		csize = 0;
+		t = rcu_dereference(ipvs->conn_tab);
+		if (t)
+			csize = t->size;
 		if (nla_put_u32(msg, IPVS_INFO_ATTR_VERSION,
 				IP_VS_VERSION_CODE) ||
-		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
-				ip_vs_conn_tab_size))
+		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE, csize))
 			goto nla_put_failure;
 		break;
 	}
-- 
2.44.0


