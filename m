Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="rQ8Jq1JQ"
Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 92036109
	for <lvs-devel@vger.kernel.org>; Tue, 12 Dec 2023 08:30:13 -0800 (PST)
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id 2545C1E110;
	Tue, 12 Dec 2023 18:30:12 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id 09CAC1E1BF;
	Tue, 12 Dec 2023 18:30:12 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id CC5EF3C07C9;
	Tue, 12 Dec 2023 18:30:11 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1702398611; bh=7vYJIEBYbXwNTowtsTf1SyuA7gNREGa0CNB2W84U2gg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=rQ8Jq1JQ+M4aAKHOVhfCkELkBqh2SA824k/YEStm2Yz3bMDsir6qixXqNYcDqTS3M
	 Zn+D3EUYtlOHqUYguFQ+hOJJjJzSqny4n/3hed+3cG+g9awRdAURducrGzWrlWcgZ2
	 rYUV7DazGrQAtmy2h3bMQrgeAVHxb3qk3BzwElow=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 3BCGQVAs094088;
	Tue, 12 Dec 2023 18:26:31 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 3BCGQVEq094087;
	Tue, 12 Dec 2023 18:26:31 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>,
        Jiri Wiesner <jwiesner@suse.de>
Subject: [PATCHv2 RFC net-next 10/14] ipvs: show the current conn_tab size to users
Date: Tue, 12 Dec 2023 18:24:40 +0200
Message-ID: <20231212162444.93801-11-ja@ssi.bg>
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

As conn_tab is per-net, better to show the current hash table size
to users instead of the ip_vs_conn_tab_size (max).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 36 +++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 72f39e3b4a7c..2cc51e1c6328 100644
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
2.43.0


