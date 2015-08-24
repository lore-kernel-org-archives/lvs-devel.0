From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v2 09/13] ipvs: attempt to schedule icmp packets
Date: Mon, 24 Aug 2015 16:44:41 -0700
Message-ID: <1440459885-1103938-9-git-send-email-agartrell@fb.com>
References: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=7kXYbYfQqsSzZVQzzqZE+JSxxrvO/JnVGI20IRPrvvM=;
 b=mv0xcALcnHOFHETS7nzJilbOvauOAwqaDhxOmoxLnU7yu8QP94DOpBHQvTEaJrWj1v9W
 5iy+gsJCgmqKGZU9lNu6FsUVrS0dABfMqCzHG27w8B0GzLORbdqwbL6UxsAK0rJUONJ1
 N770TbOhWy7jwQ+/qupBDXB/A8NYuksvjqQ= 
In-Reply-To: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Invoke the try_to_schedule logic from the icmp path and update it to the
appropriate ip_vs_conn_put function.  The schedule functions have been
updated to reject the packets immediately for now.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c       | 47 +++++++++++++++++++++++++++++------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  6 +++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  7 ++++++
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  6 +++++
 4 files changed, 59 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 558239a..361a4ff 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1390,7 +1390,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, offset2, ihl, verdict;
-	bool ipip;
+	bool ipip, new_cp = false;
 
 	*related = 1;
 
@@ -1468,7 +1468,19 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	 * For IPIP this is error for request, not for reply.
 	 */
 	cp = pp->conn_in_get(AF_INET, skb, &ciph);
-	if (!cp)
+
+	if (!cp) {
+		int v;
+
+		if (!sysctl_schedule_icmp(net_ipvs(net)))
+			return NF_ACCEPT;
+
+		if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp, &ciph))
+			return v;
+		new_cp = true;
+	}
+
+	if (unlikely(!cp))
 		return NF_ACCEPT;
 
 	verdict = NF_DROP;
@@ -1546,7 +1558,10 @@ ignore_ipip:
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
 out:
-	__ip_vs_conn_put(cp);
+	if (likely(!new_cp))
+		__ip_vs_conn_put(cp);
+	else
+		ip_vs_conn_put(cp);
 
 	return verdict;
 }
@@ -1562,6 +1577,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, verdict;
+	bool new_cp = false;
 
 	*related = 1;
 
@@ -1612,13 +1628,26 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	 */
 	cp = pp->conn_in_get(AF_INET6, skb, &ciph);
 
-	if (!cp)
+	if (!cp) {
+		int v;
+
+		if (!sysctl_schedule_icmp(net_ipvs(net)))
+			return NF_ACCEPT;
+
+		if (!ip_vs_try_to_schedule(AF_INET6, skb, pd, &v, &cp, &ciph))
+			return v;
+
+		new_cp = true;
+	}
+
+	if (unlikely(!cp))
 		return NF_ACCEPT;
+
 	/* VS/TUN, VS/DR and LOCALNODE just let it go */
 	if ((hooknum == NF_INET_LOCAL_OUT) &&
 	    (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)) {
-		__ip_vs_conn_put(cp);
-		return NF_ACCEPT;
+		verdict = NF_ACCEPT;
+		goto out;
 	}
 
 	/* do the statistics and put it back */
@@ -1631,7 +1660,11 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 
 	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
 
-	__ip_vs_conn_put(cp);
+out:
+	if (likely(!new_cp))
+		__ip_vs_conn_put(cp);
+	else
+		ip_vs_conn_put(cp);
 
 	return verdict;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 5b84c0b..cd2984f 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -19,6 +19,12 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
 
+	if (ip_vs_iph_icmp(iph)) {
+		/* TEMPORARY - do not schedule icmp yet */
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
 	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
 	if (sh == NULL) {
 		*verdict = NF_DROP;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8e92beb..dbc7075 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -41,6 +41,12 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct tcphdr _tcph, *th;
 	struct netns_ipvs *ipvs;
 
+	if (ip_vs_iph_icmp(iph)) {
+		/* TEMPORARY - do not schedule icmp yet */
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
 	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		*verdict = NF_DROP;
@@ -48,6 +54,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	}
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
+
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	rcu_read_lock();
 	if ((th->syn || sysctl_sloppy_tcp(ipvs)) && !th->rst &&
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index b62a3c0..1403be2 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -37,6 +37,12 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 
+	if (ip_vs_iph_icmp(iph)) {
+		/* TEMPORARY - do not schedule icmp yet */
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
 	/* IPv6 fragments, only first fragment will hit this */
 	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
-- 
Alex Gartrell <agartrell@fb.com>

