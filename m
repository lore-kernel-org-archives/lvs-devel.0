Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BB24354ACB;
	Sun, 19 Oct 2025 16:01:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760889675; cv=none; b=CANWwbBd01Hd5ynCFVaH9waEwDMYftXC3ENIk+rPABdaQLiGqPWtmapYuAA3houM/D/tKNt03IHaZ3cXnyk86ZcHScmcevfEI1i65UHgwUTsSb56WxWB04xOCMY3FrlXGETNFJ0jyD1XOv3fR1q92CL5FhRuta73Ou6467Z7ntQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760889675; c=relaxed/simple;
	bh=JSx9Iv0GIraFWcPaw9qvUQK9IckpGLYSmUMUKJ5kXjQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RHi0nKaggCzl2TJiaOuHB4ncKfVJmcqbnd3Z2PyJfithkKZaEuXCDMnNrdmEd4eK2hwAwEa966w5LqPZzBsiRgzsNCiZmOfGgglqrX/BGPayiOZltxrS9JhNeR2Skrecp7z4ugNJCtq6fLXe7JXAErN9KbgPbhePKac+nLBacC0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=CoSPHXri; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="CoSPHXri"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B917C21EEC;
	Sun, 19 Oct 2025 19:01:08 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=PsMew39h8llX7Nl3IiKjca+Nzp6QLOcuH6sKOZ20ys8=; b=CoSPHXriVqrU
	HQT5AjPT6erOSY/rkGpsQUPtmBHv5u+PnuUwh8KsgQprvE08V3mg5D7RndgJqskk
	4eupII2A+QpZ7lcQJLtEzyyindnWDVxq1EAHGHNl3t5NjVAqhOcL/XvtU6sfNsuZ
	B1+beRbdnlcHZp/NZ5nVDqqxcY7t/LBTXgmY3DG2XRMBXfMDoWsAT3F1FxNh0QQR
	SYjENDdFEV+2esxGX3mgqO6FS9tKazNFiabKu7vS/Ry/4CVC2lN6mP3G+wnNjLF6
	xq3LAdHiz54IUCGEifFManGjbZUYwOdAU5NjABaw2NkMEUbtX+Du8c7eHcFFKxnk
	bpnQYzcFQGKQGkEnAEajOanB9Jb0WJa1oku7TtZGRuQYBRvRO+Vt5Rl9y1hObV8i
	/ySNEZ/8T5LDcgPX7lXk6EK+aNjoWEh9r7mfECWwLaRZjNRKsdddVvm96OohY1Nx
	GhfFtMvPF6pASXJp3jZg94QDFE8vl5m9T4QQOr+v+R3ddTc25m0nNYoMX1J8aeld
	jQZr712Co1u9hg2jJthZemKGv6otyo9FOMGW5708Tfrrj71LyrXF0vAmTkNiVpzB
	UjAbv24sAezuBq0A64wr4l4g5vxrNXTBYgEWqPlQIWQgCh+AhkCMFsZDHINu02JX
	3KUew9POH5ZVBrRe+C1E5Gx3MW37/+4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 19 Oct 2025 19:01:07 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id EE33A64EA9;
	Sun, 19 Oct 2025 19:01:06 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 59JFvflg067692;
	Sun, 19 Oct 2025 18:57:41 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 59JFvfJ6067691;
	Sun, 19 Oct 2025 18:57:41 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv6 net-next 10/14] ipvs: show the current conn_tab size to users
Date: Sun, 19 Oct 2025 18:57:07 +0300
Message-ID: <20251019155711.67609-11-ja@ssi.bg>
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

As conn_tab is per-net, better to show the current hash table size
to users instead of the ip_vs_conn_tab_size (max).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 36 +++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c7683a9241e5..3dfc01ef1890 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2743,10 +2743,16 @@ static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
 
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
@@ -3424,10 +3430,17 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
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
@@ -3439,8 +3452,16 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
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
@@ -4379,6 +4400,8 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	int ret, cmd, reply_cmd;
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_rht *t;
+	int csize;
 
 	cmd = info->genlhdr->cmd;
 
@@ -4446,10 +4469,13 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
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
2.51.0


