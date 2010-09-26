From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: Keep track of backlog connections
Date: Sun, 26 Sep 2010 22:31:01 +0900
Message-ID: <20100926133101.GA9004@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>

From: Sven Wegener <sven.wegener@stealer.net>

A backlog connection is a connection that is on its way from inactive to
active. Speaking in TCP language, a connection from which we've seen the
initial SYN packet, but the three-way handshake hasn't finished yet.
These connections are expected to move to active soon. When a
destination is overloaded or isn't able to successfully establish
connections for various reasons, this count increases quickly and is an
indication for a problem.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
Signed-off-by: Julian Anastasov <ja@ssi.bg>

---

Hi Sven,

here is an updated though as yet untested version of your patch from Julian
to take into account recent changes. In particualr, the ip_vs_sync.c
portion is no longer needed as only the flags in the first 16 bits are
synced now. It applies against Patrick McHardy's nf-next-2.6 tree.

You mentioned in your original post that you would work on an ipvsadm
patch for this feature. Have you had time to do so?

Also, are you in a position to test this? If not I can do so.

Hi Mohan,

do you have any thoughts on an appropriate to add this feature to SCTP?

diff -urp net-next-2.6-e548833-nfct/linux/include/linux/ip_vs.h linux/include/linux/ip_vs.h
--- net-next-2.6-e548833-nfct/linux/include/linux/ip_vs.h	2010-09-15 11:28:02.000000000 +0300
+++ linux/include/linux/ip_vs.h	2010-09-26 15:21:53.507865229 +0300
@@ -91,6 +91,7 @@

 /* Flags that are not sent to backup server start from bit 16 */
 #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
+#define IP_VS_CONN_F_BACKLOG	(1 << 17)	/* backlog connection */

 /* Connection flags from destination that can be changed by user space */
 #define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
@@ -360,6 +361,7 @@ enum {
 	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */

 	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
+	IPVS_DEST_ATTR_BACKLOG_CONNS,	/* backlog connections */
 	__IPVS_DEST_ATTR_MAX,
 };

diff -urp net-next-2.6-e548833-nfct/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-e548833-nfct/linux/include/net/ip_vs.h	2010-09-16 08:53:04.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-09-26 15:31:27.369865994 +0300
@@ -501,6 +501,7 @@ struct ip_vs_dest {
 	/* connection counters and thresholds */
 	atomic_t		activeconns;	/* active connections */
 	atomic_t		inactconns;	/* inactive connections */
+	atomic_t		backlogconns;	/* backlog connections */
 	atomic_t		persistconns;	/* persistent connections */
 	__u32			u_threshold;	/* upper threshold */
 	__u32			l_threshold;	/* lower threshold */
diff -urp net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
--- net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-15 11:14:13.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-26 15:24:48.292865793 +0300
@@ -611,6 +611,8 @@ static inline void ip_vs_unbind_dest(str
 		} else {
 			atomic_dec(&dest->activeconns);
 		}
+		if (cp->flags & IP_VS_CONN_F_BACKLOG)
+			atomic_dec(&dest->backlogconns);
 	} else {
 		/* It is a persistent connection/template, so decrease
 		   the peristent connection counter */
diff -urp net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-16 08:56:34.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-26 15:26:45.407867200 +0300
@@ -2593,6 +2593,7 @@ static const struct nla_policy ip_vs_des
 	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
+	[IPVS_DEST_ATTR_BACKLOG_CONNS]	= { .type = NLA_U32 },
 };

 static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
@@ -2840,6 +2841,8 @@ static int ip_vs_genl_fill_dest(struct s
 		    atomic_read(&dest->activeconns));
 	NLA_PUT_U32(skb, IPVS_DEST_ATTR_INACT_CONNS,
 		    atomic_read(&dest->inactconns));
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_BACKLOG_CONNS,
+		    atomic_read(&dest->backlogconns));
 	NLA_PUT_U32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
 		    atomic_read(&dest->persistconns));

diff -urp net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-09-26 15:29:18.425865407 +0300
@@ -510,6 +510,15 @@ set_tcp_state(struct ip_vs_protocol *pp,
 				atomic_dec(&dest->inactconns);
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
+			if (new_state == IP_VS_TCP_S_SYN_RECV &&
+					!(cp->flags & IP_VS_CONN_F_BACKLOG)) {
+				atomic_inc(&dest->backlogconns);
+				cp->flags |= IP_VS_CONN_F_BACKLOG;
+			} else if (new_state == IP_VS_TCP_S_ESTABLISHED &&
+					cp->flags & IP_VS_CONN_F_BACKLOG) {
+				atomic_dec(&dest->backlogconns);
+				cp->flags &= ~IP_VS_CONN_F_BACKLOG;
+			}
 		}
 	}

