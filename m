From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 1/3] ipvs: extend connection flags to 32 bits
Date: Thu, 16 Sep 2010 23:42:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009162339520.6976@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Extend connection flags to 32 bits:

- the sync protocol supports 16 bits only, so bits 0..15 should be
used only for flags that should go to backup server, bits 16 and
above should be allocated for flags not sent to backup.

- use IP_VS_CONN_F_DEST_MASK as mask of connection flags in
destination that can be changed by user space

- allow IP_VS_CONN_F_ONE_PACKET to be set in destination

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp net-next-2.6-e548833/linux/include/linux/ip_vs.h linux/include/linux/ip_vs.h
--- net-next-2.6-e548833/linux/include/linux/ip_vs.h	2010-09-10 08:27:33.000000000 +0300
+++ linux/include/linux/ip_vs.h	2010-09-15 10:41:22.000000000 +0300
@@ -70,6 +70,7 @@
 
 /*
  *      IPVS Connection Flags
+ *      Only flags 0..15 are sent to backup server
  */
 #define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
 #define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
@@ -88,6 +89,13 @@
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
+/* Flags that are not sent to backup server start from bit 16 */
+
+/* Connection flags from destination that can be changed by user space */
+#define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
+				IP_VS_CONN_F_ONE_PACKET | \
+				0)
+
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
 
diff -urp net-next-2.6-e548833/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-e548833/linux/include/net/ip_vs.h	2010-09-10 08:27:33.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-09-14 10:21:09.000000000 +0300
@@ -366,6 +366,7 @@ struct ip_vs_conn {
 	union nf_inet_addr       caddr;          /* client address */
 	union nf_inet_addr       vaddr;          /* virtual address */
 	union nf_inet_addr       daddr;          /* destination address */
+	volatile __u32           flags;          /* status flags */
 	__be16                   cport;
 	__be16                   vport;
 	__be16                   dport;
@@ -378,7 +379,6 @@ struct ip_vs_conn {
 
 	/* Flags and state transition */
 	spinlock_t              lock;           /* lock for state transition */
-	volatile __u16          flags;          /* status flags */
 	volatile __u16          state;          /* state info */
 	volatile __u16          old_state;      /* old state, to be used for
 						 * state transition triggerd
diff -urp net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
--- net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-09-15 10:23:53.000000000 +0300
@@ -505,6 +505,8 @@ static inline int ip_vs_dest_totalconns(
 static inline void
 ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
+	unsigned int conn_flags;
+
 	/* if dest is NULL, then return directly */
 	if (!dest)
 		return;
@@ -512,16 +514,18 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, s
 	/* Increase the refcnt counter of the dest */
 	atomic_inc(&dest->refcnt);
 
+	conn_flags = atomic_read(&dest->conn_flags);
+	if (cp->protocol != IPPROTO_UDP)
+		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
 	/* Bind with the destination and its corresponding transmitter */
-	if ((cp->flags & IP_VS_CONN_F_SYNC) &&
-	    (!(cp->flags & IP_VS_CONN_F_TEMPLATE)))
+	if (cp->flags & IP_VS_CONN_F_SYNC) {
 		/* if the connection is not template and is created
 		 * by sync, preserve the activity flag.
 		 */
-		cp->flags |= atomic_read(&dest->conn_flags) &
-			     (~IP_VS_CONN_F_INACTIVE);
-	else
-		cp->flags |= atomic_read(&dest->conn_flags);
+		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
+			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
+	}
+	cp->flags |= conn_flags;
 	cp->dest = dest;
 
 	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
diff -urp net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-14 10:25:01.000000000 +0300
@@ -194,7 +194,7 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;			/* destination port to forward */
-	__be16  flags;
+	unsigned int flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
@@ -382,7 +382,8 @@ ip_vs_schedule(struct ip_vs_service *svc
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr, flags;
+	__be16 _ports[2], *pptr;
+	unsigned int flags;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -473,9 +474,9 @@ int ip_vs_leave(struct ip_vs_service *sv
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
-		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
-				iph.protocol == IPPROTO_UDP)?
-				IP_VS_CONN_F_ONE_PACKET : 0;
+		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+				      iph.protocol == IPPROTO_UDP)?
+				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
 		ip_vs_service_put(svc);
diff -urp net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-15 10:31:00.000000000 +0300
@@ -765,7 +765,8 @@ __ip_vs_update_dest(struct ip_vs_service
 
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
-	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
+	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
+	conn_flags |= IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
 #ifdef CONFIG_IP_VS_IPV6
@@ -782,7 +783,7 @@ __ip_vs_update_dest(struct ip_vs_service
 		}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
-	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != 0) {
+	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
 		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
 	} else {
 		/*
