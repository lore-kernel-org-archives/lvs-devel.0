From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 02/20] ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
Date: Wed, 27 Aug 2014 22:43:36 -0700
Message-ID: <1409204634-1123-3-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=sxeCAc8yMMetjUoTKGwOP6QFthWen/p/6WgvroJssPw=;
 b=qNTuHmbmpbsrkiBUoY8O8O3ERZ5Bi8A49IWJcvMDnvE18sixg4odCnj/DdZabfRtdwjd
 mPrj6IuUdpkqDhEXvWmwb85+uG46D4HoYXw0K4gORNu7q49P3wY6MwCTPjqUKMTJ5mci
 I9R+ySLmqHwjqmpThGmOrdqsnDHz+Q6T/Mc= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

We need to remove the assumption that virtual address family is the same as
real address family in order to support heterogeneous services (that is,
services with v4 vips and v6 backends or the opposite).

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h             |  5 +++--
 net/netfilter/ipvs/ip_vs_conn.c |  8 +++++++-
 net/netfilter/ipvs/ip_vs_ctl.c  | 24 ++++++++++++------------
 net/netfilter/ipvs/ip_vs_sync.c | 10 ++++++++--
 4 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b7e2b62..2fa1155 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1399,8 +1399,9 @@ void ip_vs_unregister_nl_ioctl(void);
 int ip_vs_control_init(void);
 void ip_vs_control_cleanup(void);
 struct ip_vs_dest *
-ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
-		__be16 dport, const union nf_inet_addr *vaddr, __be16 vport,
+ip_vs_find_dest(struct net *net, int svc_af, int dest_af,
+		const union nf_inet_addr *daddr, __be16 dport,
+		const union nf_inet_addr *vaddr, __be16 vport,
 		__u16 protocol, __u32 fwmark, __u32 flags);
 void ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 610e19c..8f4c602 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -616,7 +616,13 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	rcu_read_lock();
-	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
+
+	/* This function is only invoked by the synchronization code. We do
+	 * not currently support heterogeneous pools with synchronization,
+	 * so we can make the assumption that the svc_af is the same as the
+	 * dest_af
+	 */
+	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, cp->af, &cp->daddr,
 			       cp->dport, &cp->vaddr, cp->vport,
 			       cp->protocol, cp->fwmark, cp->flags);
 	if (dest) {
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e9473e1..eec8dee 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -574,8 +574,8 @@ bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
  * Called under RCU lock.
  */
 static struct ip_vs_dest *
-ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
-		  __be16 dport)
+ip_vs_lookup_dest(struct ip_vs_service *svc, int dest_af,
+		  const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct ip_vs_dest *dest;
 
@@ -583,9 +583,9 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 	 * Find the destination for the given service
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if ((dest->af == svc->af)
-		    && ip_vs_addr_equal(svc->af, &dest->addr, daddr)
-		    && (dest->port == dport)) {
+		if ((dest->af == dest_af) &&
+		    ip_vs_addr_equal(dest_af, &dest->addr, daddr) &&
+		    (dest->port == dport)) {
 			/* HIT */
 			return dest;
 		}
@@ -602,7 +602,7 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  * on the backup.
  * Called under RCU lock, no refcnt is returned.
  */
-struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
+struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int svc_af, int dest_af,
 				   const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
@@ -613,14 +613,14 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	struct ip_vs_service *svc;
 	__be16 port = dport;
 
-	svc = ip_vs_service_find(net, af, fwmark, protocol, vaddr, vport);
+	svc = ip_vs_service_find(net, svc_af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	if (fwmark && (flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ)
 		port = 0;
-	dest = ip_vs_lookup_dest(svc, daddr, port);
+	dest = ip_vs_lookup_dest(svc, dest_af, daddr, port);
 	if (!dest)
-		dest = ip_vs_lookup_dest(svc, daddr, port ^ dport);
+		dest = ip_vs_lookup_dest(svc, dest_af, daddr, port ^ dport);
 	return dest;
 }
 
@@ -938,7 +938,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
-	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+	dest = ip_vs_lookup_dest(svc, udest->af, &daddr, dport);
 	rcu_read_unlock();
 
 	if (dest != NULL) {
@@ -1002,7 +1002,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
-	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+	dest = ip_vs_lookup_dest(svc, udest->af, &daddr, dport);
 	rcu_read_unlock();
 
 	if (dest == NULL) {
@@ -1084,7 +1084,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
-	dest = ip_vs_lookup_dest(svc, &udest->addr, dport);
+	dest = ip_vs_lookup_dest(svc, udest->af, &udest->addr, dport);
 	rcu_read_unlock();
 
 	if (dest == NULL) {
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index db80126..61701ed 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -880,8 +880,14 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		 * but still handled.
 		 */
 		rcu_read_lock();
-		dest = ip_vs_find_dest(net, type, daddr, dport, param->vaddr,
-				       param->vport, protocol, fwmark, flags);
+		/* This function is only invoked by the synchronization
+		 * code. We do not currently support heterogeneous pools
+		 * with synchronization, so we can make the assumption that
+		 * the svc_af is the same as the dest_af
+		 */
+		dest = ip_vs_find_dest(net, type, type, daddr, dport,
+				       param->vaddr, param->vport, protocol,
+				       fwmark, flags);
 
 		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
 		rcu_read_unlock();
-- 
1.8.1

