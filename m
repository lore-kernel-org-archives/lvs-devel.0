From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/4] IPVS: Remove unused return value of protocol state transitions
Date: Mon, 26 Sep 2011 10:23:52 +0900
Message-ID: <1317000233-11169-4-git-send-email-horms@verge.net.au>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |    6 +++---
 net/netfilter/ipvs/ip_vs_core.c       |   13 ++++++-------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   14 ++++----------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    6 ++----
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 ++---
 5 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5207248..ec70a0d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -428,9 +428,9 @@ struct ip_vs_protocol {
 
 	const char *(*state_name)(int state);
 
-	int (*state_transition)(struct ip_vs_conn *cp, int direction,
-				const struct sk_buff *skb,
-				struct ip_vs_proto_data *pd);
+	void (*state_transition)(struct ip_vs_conn *cp, int direction,
+				 const struct sk_buff *skb,
+				 struct ip_vs_proto_data *pd);
 
 	int (*register_app)(struct net *net, struct ip_vs_app *inc);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0e4422b..c1ec85d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -188,14 +188,13 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 }
 
 
-static inline int
+static inline void
 ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 		const struct sk_buff *skb,
 		struct ip_vs_proto_data *pd)
 {
-	if (unlikely(!pd->pp->state_transition))
-		return 0;
-	return pd->pp->state_transition(cp, direction, skb, pd);
+	if (likely(pd->pp->state_transition))
+		pd->pp->state_transition(cp, direction, skb, pd);
 }
 
 static inline int
@@ -557,7 +556,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_in_stats(cp, skb);
 
 		/* set state */
-		cs = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
+		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 
 		/* transmit the first SYN packet */
 		ret = cp->packet_xmit(skb, cp, pd->pp);
@@ -1507,7 +1506,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
-	int ret, restart, pkts;
+	int ret, pkts;
 	struct netns_ipvs *ipvs;
 
 	/* Already marked as IPVS request or reply? */
@@ -1605,7 +1604,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	ip_vs_in_stats(cp, skb);
-	restart = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
+	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
 		ret = cp->packet_xmit(skb, cp, pp);
 		/* do not touch skb anymore */
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index b027ccc..df9f13b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -906,7 +906,7 @@ static const char *sctp_state_name(int state)
 	return "?";
 }
 
-static inline int
+static inline void
 set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
 {
@@ -924,7 +924,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	sch = skb_header_pointer(skb, ihl + sizeof(sctp_sctphdr_t),
 				sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
-		return 0;
+		return;
 
 	chunk_type = sch->type;
 	/*
@@ -993,21 +993,15 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		cp->timeout = pd->timeout_table[cp->state = next_state];
 	else	/* What to do ? */
 		cp->timeout = sctp_timeouts[cp->state = next_state];
-
-	return 1;
 }
 
-static int
+static void
 sctp_state_transition(struct ip_vs_conn *cp, int direction,
 		const struct sk_buff *skb, struct ip_vs_proto_data *pd)
 {
-	int ret = 0;
-
 	spin_lock(&cp->lock);
-	ret = set_sctp_state(pd, cp, direction, skb);
+	set_sctp_state(pd, cp, direction, skb);
 	spin_unlock(&cp->lock);
-
-	return ret;
 }
 
 static inline __u16 sctp_app_hashkey(__be16 port)
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index c0cc341..ef8641f 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -546,7 +546,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 /*
  *	Handle state transitions
  */
-static int
+static void
 tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_proto_data *pd)
@@ -561,13 +561,11 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 
 	th = skb_header_pointer(skb, ihl, sizeof(_tcph), &_tcph);
 	if (th == NULL)
-		return 0;
+		return;
 
 	spin_lock(&cp->lock);
 	set_tcp_state(pd, cp, direction, th);
 	spin_unlock(&cp->lock);
-
-	return 1;
 }
 
 static inline __u16 tcp_app_hashkey(__be16 port)
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f1282cb..f4b7262 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -454,18 +454,17 @@ static const char * udp_state_name(int state)
 	return udp_state_name_table[state] ? udp_state_name_table[state] : "?";
 }
 
-static int
+static void
 udp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_proto_data *pd)
 {
 	if (unlikely(!pd)) {
 		pr_err("UDP no ns data\n");
-		return 0;
+		return;
 	}
 
 	cp->timeout = pd->timeout_table[IP_VS_UDP_S_NORMAL];
-	return 1;
 }
 
 static void __udp_init(struct net *net, struct ip_vs_proto_data *pd)
-- 
1.7.5.4
