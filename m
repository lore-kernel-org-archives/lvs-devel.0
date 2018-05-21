From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
Subject: [PATCH] ipvs: drop templates for never established TCP connections
Date: Mon, 21 May 2018 19:27:07 +0200
Message-ID: <20180521172707.14106-1-mkoutny@suse.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: mkoutny@suse.com, mkubecek@suse.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

IPVS includes protection against filling the ip_vs_conn_tab by dropping 1/32 of
feasible entries every second. The template entries (for persistent services)
are never directly deleted by this mechanism but when a picked TCP connection
entry is being dropped (1), the respective template entry is dropped too
(realized by expiring 60 seconds after the connection entry being dropped).

There is another mechanism that removes connection entries when they
time out (2), in this case the associated template entry is not deleted.
Under SYN flood template entries would accumulate (due to their entry
longer timeout).

The accumulation takes place also with drop_entry being enabled. Roughly
15% ((31/32)^60) of SYN_RECV connections survive the dropping mechanism
(1) and are removed by the timeout mechanism (2)(defaults to 60 seconds
for SYN_RECV), thus template entries would still accumulate.

The patch ensures that when a connection entry times out, we also remove the
template entry from the table. To prevent breaking persistent services (since
the connection may time out in already established state) we add a new entry
flag to protect templates what spawned at least one established TCP connection.

Cc: Michal Kubeček <mkubecek@suse.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 include/uapi/linux/ip_vs.h           | 33 +++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_conn.c      | 10 +++++++++-
 net/netfilter/ipvs/ip_vs_core.c      | 15 ++++++++++++++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c |  6 ++++++
 4 files changed, 46 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 1c916b2f89dc..ef3bbc001fcd 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -79,22 +79,23 @@
  *      IPVS Connection Flags
  *      Only flags 0..15 are sent to backup server
  */
-#define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
-#define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
-#define IP_VS_CONN_F_LOCALNODE	0x0001		/* local node */
-#define IP_VS_CONN_F_TUNNEL	0x0002		/* tunneling */
-#define IP_VS_CONN_F_DROUTE	0x0003		/* direct routing */
-#define IP_VS_CONN_F_BYPASS	0x0004		/* cache bypass */
-#define IP_VS_CONN_F_SYNC	0x0020		/* entry created by sync */
-#define IP_VS_CONN_F_HASHED	0x0040		/* hashed entry */
-#define IP_VS_CONN_F_NOOUTPUT	0x0080		/* no output packets */
-#define IP_VS_CONN_F_INACTIVE	0x0100		/* not established */
-#define IP_VS_CONN_F_OUT_SEQ	0x0200		/* must do output seq adjust */
-#define IP_VS_CONN_F_IN_SEQ	0x0400		/* must do input seq adjust */
-#define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
-#define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
-#define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
-#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
+#define IP_VS_CONN_F_FWD_MASK		0x0007		/* mask for the fwd methods */
+#define IP_VS_CONN_F_MASQ		0x0000		/* masquerading/NAT */
+#define IP_VS_CONN_F_LOCALNODE		0x0001		/* local node */
+#define IP_VS_CONN_F_TUNNEL		0x0002		/* tunneling */
+#define IP_VS_CONN_F_DROUTE		0x0003		/* direct routing */
+#define IP_VS_CONN_F_BYPASS		0x0004		/* cache bypass */
+#define IP_VS_CONN_F_SYNC		0x0020		/* entry created by sync */
+#define IP_VS_CONN_F_HASHED		0x0040		/* hashed entry */
+#define IP_VS_CONN_F_NOOUTPUT		0x0080		/* no output packets */
+#define IP_VS_CONN_F_INACTIVE		0x0100		/* not established */
+#define IP_VS_CONN_F_OUT_SEQ		0x0200		/* must do output seq adjust */
+#define IP_VS_CONN_F_IN_SEQ		0x0400		/* must do input seq adjust */
+#define IP_VS_CONN_F_SEQ_MASK		0x0600		/* in/out sequence mask */
+#define IP_VS_CONN_F_NO_CPORT		0x0800		/* no client port set yet */
+#define IP_VS_CONN_F_TEMPLATE		0x1000		/* template, not connection */
+#define IP_VS_CONN_F_ONE_PACKET		0x2000		/* forward only one packet */
+#define IP_VS_CONN_F_TMPL_PERSISTED	0x4000		/* template, confirmed persistent */
 
 /* Initial bits allowed in backup server */
 #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 370abbf6f421..6afc606a388c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -820,6 +820,7 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
 static void ip_vs_conn_expire(struct timer_list *t)
 {
 	struct ip_vs_conn *cp = from_timer(cp, t, timer);
+	struct ip_vs_conn *cp_c;
 	struct netns_ipvs *ipvs = cp->ipvs;
 
 	/*
@@ -834,8 +835,15 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		del_timer(&cp->timer);
 
 		/* does anybody control me? */
-		if (cp->control)
+		cp_c = cp->control;
+		if (cp_c) {
 			ip_vs_control_del(cp);
+			if (cp_c->flags & IP_VS_CONN_F_TEMPLATE &&
+			    !(cp_c->flags & IP_VS_CONN_F_TMPL_PERSISTED)) {
+				IP_VS_DBG(4, "del conn template\n");
+				ip_vs_conn_expire_now(cp_c);
+			}
+		}
 
 		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
 		    !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5f6f73cf2174..8e4ba69a09e1 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -221,6 +221,17 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 	return 0;
 }
 
+static inline bool
+is_new_template_persisted(u16 protocol)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return false;
+	default:
+		return true;
+	}
+}
+
 /*
  *  IPVS persistent scheduling function
  *  It creates a connection entry according to its template if exists,
@@ -347,8 +358,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * This adds param.pe_data to the template,
 		 * and thus param.pe_data will be destroyed
 		 * when the template expires */
+		flags = IP_VS_CONN_F_TEMPLATE;
+		flags |= is_new_template_persisted(param.protocol) ? IP_VS_CONN_F_TMPL_PERSISTED : 0;
 		ct = ip_vs_conn_new(&param, dest->af, &dest->addr, dport,
-				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
+				    flags, dest, skb->mark);
 		if (ct == NULL) {
 			kfree(param.pe_data);
 			*ignored = -1;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 569631d2b2a1..ede6e0d31926 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -538,6 +538,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
   tcp_state_out:
 	if (new_state != cp->state) {
 		struct ip_vs_dest *dest = cp->dest;
+		struct ip_vs_conn *ct = cp->control;
 
 		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
 			      "%s:%d state: %s->%s conn->refcnt:%d\n",
@@ -569,6 +570,11 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
 		}
+
+		if (ct && ct->flags & IP_VS_CONN_F_TEMPLATE) {
+			if (new_state == IP_VS_TCP_S_ESTABLISHED)
+				ct->flags |= IP_VS_CONN_F_TMPL_PERSISTED;
+		}
 	}
 
 	if (likely(pd))
-- 
2.13.6

