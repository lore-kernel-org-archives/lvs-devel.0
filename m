From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 2/2] ipvs: only perform slow checksum on NF_INET_LOCAL_OUT
Date: Tue, 22 Jul 2014 23:37:45 -0700
Message-ID: <1406097465-8180-2-git-send-email-agartrell@fb.com>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QtS1HqO63+FzT8PxhxqvKFq7GT8IG5JitT8IsJG7mVQ=;
 b=K7lff3BK9PG/xEjx3YW1ioFZmL9l/zKK116xvUYzsRVESL+KIM3x0JdJk2wXsWMz5Y+J
 Lu6xQcEd+3AGmKL4w8AoIamglHfAIY8UrYody1GJQWFpROa5vJGlJCu7jvPt3wRPs8Z/
 b08x3/IVkB+xw3NZwFMJsJ56e2vS7ercg/k= 
In-Reply-To: <1406097465-8180-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

In order to know when we may need to tcp checksum, we need to propagate the
hooknum through packet_xmit as well as through conn_schedule (as it may
call ip_vs_leave, which itself invokes packet_xmit).

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h                     | 36 ++++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_core.c         | 10 +++++----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  5 +++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  5 +++--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  5 +++--
 net/netfilter/ipvs/ip_vs_xmit.c         | 35 ++++++++++++++++++++------------
 7 files changed, 62 insertions(+), 36 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 624a8a5..a31b435 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -448,7 +448,8 @@ struct ip_vs_protocol {
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp,
-			     struct ip_vs_iphdr *iph);
+			     struct ip_vs_iphdr *iph,
+			     int hooknum);
 
 	struct ip_vs_conn *
 	(*conn_in_get)(int af,
@@ -566,7 +567,8 @@ struct ip_vs_conn {
 	   NF_ACCEPT can be returned when destination is local.
 	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			   int hooknum);
 
 	/* Note: we can group the following members into a structure,
 	   in order to save more space, and the following members are
@@ -1371,7 +1373,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
 	       struct ip_vs_iphdr *iph);
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		int hooknum);
 
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
@@ -1439,15 +1442,20 @@ void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
  *	Various IPVS packet transmitters (from ip_vs_xmit.c)
  */
 int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		    int hooknum);
 int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      int hooknum);
 int ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		   int hooknum);
 int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      int hooknum);
 int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		  int hooknum);
 int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		    struct ip_vs_protocol *pp, int offset,
 		    unsigned int hooknum, struct ip_vs_iphdr *iph);
@@ -1455,13 +1463,17 @@ void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
 
 #ifdef CONFIG_IP_VS_IPV6
 int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			 int hooknum);
 int ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      int hooknum);
 int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			 int hooknum);
 int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		     int hooknum);
 int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		       struct ip_vs_protocol *pp, int offset,
 		       unsigned int hooknum, struct ip_vs_iphdr *iph);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e683675..613a125 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -507,7 +507,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
  *  no destination is available for a new connection.
  */
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		int hooknum)
 {
 	__be16 _ports[2], *pptr;
 #ifdef CONFIG_SYSCTL
@@ -564,7 +565,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
+		ret = cp->packet_xmit(skb, cp, pd->pp, iph, hooknum);
 		/* do not touch skb anymore */
 
 		atomic_inc(&cp->in_pkts);
@@ -1635,6 +1636,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	pd = ip_vs_proto_data_get(net, iph.protocol);
 	if (unlikely(!pd))
 		return NF_ACCEPT;
+
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
@@ -1656,7 +1658,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		int v;
 
 		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph, hooknum))
 			return v;
 	}
 
@@ -1692,7 +1694,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp, &iph);
+		ret = cp->packet_xmit(skb, cp, pp, &iph, hooknum);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5de3dd3..169eaa3 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -109,7 +109,7 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 static int
 ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp,
-		     struct ip_vs_iphdr *iph)
+		     struct ip_vs_iphdr *iph, int hooknum)
 {
 	/*
 	 * AH/ESP is only related traffic. Pass the packet to IP stack.
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 2f7ea75..aec76c9 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -11,7 +11,7 @@
 static int
 sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
-		   struct ip_vs_iphdr *iph)
+		   struct ip_vs_iphdr *iph, int hooknum)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
@@ -56,7 +56,8 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       hooknum);
 			else
 				*verdict = NF_DROP;
 			rcu_read_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index e3a6972..1baf90d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -34,7 +34,7 @@
 static int
 tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, int hooknum)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
@@ -72,7 +72,8 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       hooknum);
 			else
 				*verdict = NF_DROP;
 			rcu_read_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index b62a3c0..9eeb752 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -31,7 +31,7 @@
 static int
 udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, int hooknum)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
@@ -67,7 +67,8 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       hooknum);
 			else
 				*verdict = NF_DROP;
 			rcu_read_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e9b5e6e..91bf1d5 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -535,7 +535,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
  */
 int
 ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		int hooknum)
 {
 	/* we do not touch skb and do not need pskb ptr */
 	return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
@@ -549,7 +550,8 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  int hooknum)
 {
 	struct iphdr  *iph = ip_hdr(skb);
 
@@ -581,7 +583,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     int hooknum)
 {
 	EnterFunction(10);
 
@@ -613,7 +616,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	       int hooknum)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int local, rc, was_input;
@@ -703,7 +707,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  int hooknum)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int local, rc;
@@ -813,7 +818,8 @@ tx_error:
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  int hooknum)
 {
 	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct rtable *rt;			/* Route to the other host */
@@ -864,7 +870,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
-	{
+	if (hooknum == NF_INET_LOCAL_OUT) {
 		/* ipip breaks layer 4 checksumming on many (all?) NICs, so
 		 * we must do it ourselves instead of relying upon checksum
 		 * offload */
@@ -934,7 +940,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     int hooknum)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	struct in6_addr saddr;		/* Source for tunnel */
@@ -979,7 +986,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
-	{
+	if (hooknum == NF_INET_LOCAL_OUT) {
 		/* ipip breaks layer 4 checksumming on many (all?) NICs, so
 		 * we must do it ourselves instead of relying upon checksum
 		 * offload */
@@ -1051,7 +1058,8 @@ tx_error:
  */
 int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	      int hooknum)
 {
 	int local;
 
@@ -1090,7 +1098,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		 int hooknum)
 {
 	int local;
 
@@ -1147,7 +1156,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, iph);
+			rc = cp->packet_xmit(skb, cp, pp, iph, hooknum);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1239,7 +1248,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ipvsh);
+			rc = cp->packet_xmit(skb, cp, pp, ipvsh, hooknum);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
-- 
1.8.1

