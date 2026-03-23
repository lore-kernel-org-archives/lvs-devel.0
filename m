Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 656AF3B2FDF;
	Mon, 23 Mar 2026 16:31:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774283487; cv=none; b=YjCbLYzk28VcPEjKVcp61L4/enfF2c9KCkTyrMxwJAwlVq+rjmp0yvVozGxlxM0htOiSlXIsoB3JTKFH04keCUe93/kDnWDFlH6AYn0jaNH3Ijs1H4ZESf1/hDoyIv3EBxRW5fdROXKkhZ5sC2Xin6lTLtPTKWTYMpylqpUpqSM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774283487; c=relaxed/simple;
	bh=50t7WZ0ceOFwIoRskZfQvuWU2rGk4ljSFgK/sfrNbr4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EV0Juv+lHXJ+SULmLWeTWlDiQK56kv6CcJy02cn93F+1TSI388t0gj8rB8HEvecwjCklmdEaIgYu4GL5y03AkPk38oNosBmmjwOcY3Ves0UM0BBNddo0xe2MNRhCxNx9eMZqXoVoxViQD6uKpipXCchI7lrruVJqFIP0i9YE33c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aptCwODm; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aptCwODm"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D680C21834;
	Mon, 23 Mar 2026 18:31:19 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=YGzvaAygqsreh0fVCganI86iTjrmERDlHPucQzqodVE=; b=aptCwODm9otG
	GFdSKMpJK6qKupZPP7N1DwdJ3YzFCwymZhsf3PZsLqSUOSKpxNm0vnUt6ni0AySB
	HdTP/3ZAURtZZZmnAkPYtUy0/fX7I3OLRZAb4uBDC3N9wqjZNfRlHZhJktHZUqjF
	QSe3+95mfsZMt/8LALV4UVFYLKyyZrkIuNnRQ8+eRfanw7OSk/8LNurudQLkEm6c
	UDkXuYg4Z4wcwW03G+CxrWcPwjD2+bH6X3CaB3fXjULaY8ywertZx/wF9imjCC7y
	RXiq/JBjtWQhryNOHRCy42jVtlBVkaZf0t1PcJqhbEATfUX8Lf0TgAgjL6lEQszG
	WLoMKj7FsRZGX//wPJoXlY9jyV0gSvCSaIKozYNkhiQUyifyVHSzeau+H3WWba+R
	mrxW8Hjr838ZYZXeT8SEk2B+TdaEHCz4HIQaoZdWPLVdwGdw8S6h1hIOipn8J+bS
	vk6lZTltaAFEN9B8/e3ndQPk7g4iEwQ4uO1Gxl/6299vptTczq+HR3/DZDlfSSTG
	4yMKQgVzl8pGZIuWuGDmt+R6ZC1L8ULjD7ak4umMJN3cWmTR8pFikOeqBo/bKd0d
	zkOs7EchOxMpArOAYd1nKcN0r+ULsVO9A+WuwcoaDI6yRf7DeEz4TqpbYj3yMRLa
	7pNSFxuMSzBVjU3mn3N7CVodaaqWBmE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 23 Mar 2026 18:31:18 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5460660AD5;
	Mon, 23 Mar 2026 18:31:19 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 62NGQWrt045005;
	Mon, 23 Mar 2026 18:26:32 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 62NGQWf4045004;
	Mon, 23 Mar 2026 18:26:32 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 1/3] ipvs: show the current conn_tab size to users
Date: Mon, 23 Mar 2026 18:25:21 +0200
Message-ID: <20260323162523.44964-2-ja@ssi.bg>
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

As conn_tab is per-net, better to show the current hash table size
to users instead of the ip_vs_conn_tab_size (max).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b472e564b769..3129b15dadc2 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -281,6 +281,13 @@ static void est_reload_work_handler(struct work_struct *work)
 	mutex_unlock(&ipvs->est_mutex);
 }
 
+static int get_conn_tab_size(struct netns_ipvs *ipvs)
+{
+	struct ip_vs_rht *t = rcu_dereference(ipvs->conn_tab);
+
+	return t? t->size : 0;
+}
+
 int
 ip_vs_use_count_inc(void)
 {
@@ -2742,10 +2749,14 @@ static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
 
 static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq,
 			"IP Virtual Server version %d.%d.%d (size=%d)\n",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE),
+			get_conn_tab_size(ipvs));
 		seq_puts(seq,
 			 "Prot LocalAddress:Port Scheduler Flags\n");
 		seq_puts(seq,
@@ -3424,9 +3435,13 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_VERSION:
 	{
 		char buf[64];
+		int csize;
 
+		rcu_read_lock();
+		csize = get_conn_tab_size(ipvs);
+		rcu_read_unlock();
 		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
-			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
+			NVERSION(IP_VS_VERSION_CODE), csize);
 		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
 			ret = -EFAULT;
 			goto out;
@@ -3438,8 +3453,11 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	case IP_VS_SO_GET_INFO:
 	{
 		struct ip_vs_getinfo info;
+
 		info.version = IP_VS_VERSION_CODE;
-		info.size = ip_vs_conn_tab_size;
+		rcu_read_lock();
+		info.size = get_conn_tab_size(ipvs);
+		rcu_read_unlock();
 		info.num_services =
 			atomic_read(&ipvs->num_services[IP_VS_AF_INET]);
 		if (copy_to_user(user, &info, sizeof(info)) != 0)
@@ -4448,7 +4466,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 		if (nla_put_u32(msg, IPVS_INFO_ATTR_VERSION,
 				IP_VS_VERSION_CODE) ||
 		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
-				ip_vs_conn_tab_size))
+				get_conn_tab_size(ipvs)))
 			goto nla_put_failure;
 		break;
 	}
-- 
2.53.0


