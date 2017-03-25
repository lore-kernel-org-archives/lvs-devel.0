From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilters: Remove extra parenthesis
Date: Sat, 25 Mar 2017 19:23:13 +0530
Message-ID: <20170325135313.GA10861@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=MHF6uHrpFWNCdlun22Si0VxTxc6VTQh6tEU2PB2tmC4=;
        b=X8+ONJg0a9DHfrtUG0WOwYXgM4/ZRMm65wIxAp+ovtwH9AaYYbXPA/Xk4tt85AO5M9
         MH7N/DYp0nje90ReDn4ow2b1zLFSNMuXy0o8ZXa1KhxOoCNC2RoIVLdv4igHg2HVnxsW
         RlPOl22av1zbW4Ye43eHXMufBqcHVaCJxa0AJKZLc1HpX9y+AJBrFLqxxEWqnIvSoVI/
         sw3EaaoUeZFPVQo5059qMc9DnPLc9kjsnP9x1GBo2qwCQzDE7JT5Nc4bB0WZ4JDQzpGo
         AhOAeJ6fKbr7XdXwv8MuaG9wiDmkq/FooyZR9cTTkmz9lXc42mDzFB/0cYc8geQ442kv
         yRBw==
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

Rmoved parentheses on the right hand side of assignment, as they are
not required. The following coccinelle script was used to fix this
issue:

@@
local idexpression id;
expression e;
@@

id =
-(
e
-)

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c   | 2 +-
 net/netfilter/nf_conntrack_netlink.c   | 8 ++++----
 net/netfilter/nf_conntrack_proto_tcp.c | 2 +-
 net/netfilter/nft_fib.c                | 2 +-
 net/netfilter/nft_set_bitmap.c         | 2 +-
 net/netfilter/x_tables.c               | 2 +-
 net/netfilter/xt_socket.c              | 8 ++++----
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 5117bcb7d2f0..9f2abda017c4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -487,7 +487,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 
 static void tcp_timeout_change(struct ip_vs_proto_data *pd, int flags)
 {
-	int on = (flags & 1);		/* secure_tcp */
+	int on = flags & 1;		/* secure_tcp */
 
 	/*
 	** FIXME: change secure_tcp to independent sysctl var
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6806b5e73567..aa344c5868c5 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -467,7 +467,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nlattr *nest_parms;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW);
+	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -1983,7 +1983,7 @@ ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU);
+	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2066,7 +2066,7 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS);
+	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -3223,7 +3223,7 @@ ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, int cpu,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU);
+	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b122e9dacfed..2e5e4a4d4778 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -789,7 +789,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* Check TCP flags. */
-	tcpflags = (tcp_flag_byte(th) & ~(TCPHDR_ECE|TCPHDR_CWR|TCPHDR_PSH));
+	tcpflags = tcp_flag_byte(th) & ~(TCPHDR_ECE|TCPHDR_CWR|TCPHDR_PSH);
 	if (!tcp_valid_flags[tcpflags]) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
index 29a4906adc27..c907c27b0374 100644
--- a/net/netfilter/nft_fib.c
+++ b/net/netfilter/nft_fib.c
@@ -35,7 +35,7 @@ int nft_fib_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	switch (priv->result) {
 	case NFT_FIB_RESULT_OIF: /* fallthrough */
 	case NFT_FIB_RESULT_OIFNAME:
-		hooks = (1 << NF_INET_PRE_ROUTING);
+		hooks = 1 << NF_INET_PRE_ROUTING;
 		break;
 	case NFT_FIB_RESULT_ADDRTYPE:
 		if (priv->flags & NFTA_FIB_F_IIF)
diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
index 152d226552c1..09867146539e 100644
--- a/net/netfilter/nft_set_bitmap.c
+++ b/net/netfilter/nft_set_bitmap.c
@@ -47,7 +47,7 @@ struct nft_bitmap {
 
 static inline void nft_bitmap_location(u32 key, u32 *idx, u32 *off)
 {
-	u32 k = (key << 1);
+	u32 k = key << 1;
 
 	*idx = k / BITS_PER_BYTE;
 	*off = k % BITS_PER_BYTE;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 14857afc9937..7a4a9beadedb 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -506,7 +506,7 @@ static int xt_check_entry_match(const char *match, const char *target,
 			return -EINVAL;
 
 		length -= pos->u.match_size;
-		pos = ((void *)((char *)(pos) + (pos)->u.match_size));
+		pos = (void *)((char *)(pos) + (pos)->u.match_size);
 	} while (length > 0);
 
 	return 0;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 770bbec878f1..bf86e12808bd 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -65,9 +65,9 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		/* Ignore sockets listening on INADDR_ANY,
 		 * unless XT_SOCKET_NOWILDCARD is set
 		 */
-		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
+		wildcard = !(info->flags & XT_SOCKET_NOWILDCARD) &&
 			    sk_fullsock(sk) &&
-			    inet_sk(sk)->inet_rcv_saddr == 0);
+			    inet_sk(sk)->inet_rcv_saddr == 0;
 
 		/* Ignore non-transparent sockets,
 		 * if XT_SOCKET_TRANSPARENT is used
@@ -122,9 +122,9 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 		/* Ignore sockets listening on INADDR_ANY
 		 * unless XT_SOCKET_NOWILDCARD is set
 		 */
-		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
+		wildcard = !(info->flags & XT_SOCKET_NOWILDCARD) &&
 			    sk_fullsock(sk) &&
-			    ipv6_addr_any(&sk->sk_v6_rcv_saddr));
+			    ipv6_addr_any(&sk->sk_v6_rcv_saddr);
 
 		/* Ignore non-transparent sockets,
 		 * if XT_SOCKET_TRANSPARENT is used
-- 
2.11.0

