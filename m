From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/9] bridge: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:18 +0200
Message-ID: <1461572722-6029-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, johannes@sipsolutions.net, linux-wireless@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_link.h |  2 ++
 net/bridge/br_netlink.c      | 62 +++++++++++++++++++++++++-------------------
 2 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5fdd3a42e377..9300c08346c8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -271,6 +271,7 @@ enum {
 	IFLA_BR_NF_CALL_IP6TABLES,
 	IFLA_BR_NF_CALL_ARPTABLES,
 	IFLA_BR_VLAN_DEFAULT_PVID,
+	IFLA_BR_PAD,
 	__IFLA_BR_MAX,
 };
 
@@ -313,6 +314,7 @@ enum {
 	IFLA_BRPORT_HOLD_TIMER,
 	IFLA_BRPORT_FLUSH,
 	IFLA_BRPORT_MULTICAST_ROUTER,
+	IFLA_BRPORT_PAD,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e9c635eae24d..6bae1125e36d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -135,9 +135,9 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_NO */
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_TOPOLOGY_CHANGE_ACK */
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_CONFIG_PENDING */
-		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_MESSAGE_AGE_TIMER */
-		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_FORWARD_DELAY_TIMER */
-		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_HOLD_TIMER */
+		+ nla_total_size_64bit(sizeof(u64)) /* IFLA_BRPORT_MESSAGE_AGE_TIMER */
+		+ nla_total_size_64bit(sizeof(u64)) /* IFLA_BRPORT_FORWARD_DELAY_TIMER */
+		+ nla_total_size_64bit(sizeof(u64)) /* IFLA_BRPORT_HOLD_TIMER */
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_MULTICAST_ROUTER */
 #endif
@@ -190,13 +190,16 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	timerval = br_timer_value(&p->message_age_timer);
-	if (nla_put_u64(skb, IFLA_BRPORT_MESSAGE_AGE_TIMER, timerval))
+	if (nla_put_u64_64bit(skb, IFLA_BRPORT_MESSAGE_AGE_TIMER, timerval,
+			      IFLA_BRPORT_PAD))
 		return -EMSGSIZE;
 	timerval = br_timer_value(&p->forward_delay_timer);
-	if (nla_put_u64(skb, IFLA_BRPORT_FORWARD_DELAY_TIMER, timerval))
+	if (nla_put_u64_64bit(skb, IFLA_BRPORT_FORWARD_DELAY_TIMER, timerval,
+			      IFLA_BRPORT_PAD))
 		return -EMSGSIZE;
 	timerval = br_timer_value(&p->hold_timer);
-	if (nla_put_u64(skb, IFLA_BRPORT_HOLD_TIMER, timerval))
+	if (nla_put_u64_64bit(skb, IFLA_BRPORT_HOLD_TIMER, timerval,
+			      IFLA_BRPORT_PAD))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
@@ -1087,10 +1090,10 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_ROOT_PATH_COST */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_TOPOLOGY_CHANGE */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_TOPOLOGY_CHANGE_DETECTED */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_HELLO_TIMER */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TCN_TIMER */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TOPOLOGY_CHANGE_TIMER */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_GC_TIMER */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_HELLO_TIMER */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_TCN_TIMER */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_TOPOLOGY_CHANGE_TIMER */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_GC_TIMER */
 	       nla_total_size(ETH_ALEN) +       /* IFLA_BR_GROUP_ADDR */
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_ROUTER */
@@ -1101,12 +1104,12 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_MAX */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_LAST_MEMBER_CNT */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_CNT */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_LAST_MEMBER_INTVL */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_MEMBERSHIP_INTVL */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERIER_INTVL */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERY_INTVL */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERY_RESPONSE_INTVL */
-	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_LAST_MEMBER_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_MEMBERSHIP_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_QUERIER_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_QUERY_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_QUERY_RESPONSE_INTVL */
+	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_STARTUP_QUERY_INTVL */
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_IPTABLES */
@@ -1129,16 +1132,17 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u64 clockval;
 
 	clockval = br_timer_value(&br->hello_timer);
-	if (nla_put_u64(skb, IFLA_BR_HELLO_TIMER, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_HELLO_TIMER, clockval, IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = br_timer_value(&br->tcn_timer);
-	if (nla_put_u64(skb, IFLA_BR_TCN_TIMER, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_TCN_TIMER, clockval, IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = br_timer_value(&br->topology_change_timer);
-	if (nla_put_u64(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = br_timer_value(&br->gc_timer);
-	if (nla_put_u64(skb, IFLA_BR_GC_TIMER, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_GC_TIMER, clockval, IFLA_BR_PAD))
 		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
@@ -1182,22 +1186,28 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 		return -EMSGSIZE;
 
 	clockval = jiffies_to_clock_t(br->multicast_last_member_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_LAST_MEMBER_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_LAST_MEMBER_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = jiffies_to_clock_t(br->multicast_membership_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_MEMBERSHIP_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_MEMBERSHIP_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = jiffies_to_clock_t(br->multicast_querier_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERIER_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_QUERIER_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = jiffies_to_clock_t(br->multicast_query_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERY_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_QUERY_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = jiffies_to_clock_t(br->multicast_query_response_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_QUERY_RESPONSE_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_QUERY_RESPONSE_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 	clockval = jiffies_to_clock_t(br->multicast_startup_query_interval);
-	if (nla_put_u64(skb, IFLA_BR_MCAST_STARTUP_QUERY_INTVL, clockval))
+	if (nla_put_u64_64bit(skb, IFLA_BR_MCAST_STARTUP_QUERY_INTVL, clockval,
+			      IFLA_BR_PAD))
 		return -EMSGSIZE;
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-- 
2.8.1

