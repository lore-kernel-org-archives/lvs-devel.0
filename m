From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 10/14] ipvs: attempt to schedule icmp packets
Date: Tue, 25 Aug 2015 20:49:25 -0700
Message-ID: <1440560969-3511889-10-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=TeozjihdCuF+umFDr9PLTULKDzRYXkZS/ya6GHq1bU4=;
 b=lLGPu0JaoBAwR9yn4EL9OMbxPzAGcyRDoRuUKzQbRPAGiBJubKblMDU9+OlLa7gfjik6
 fM56/gwYrDDFpMtOHXddcPEFqaD3/paX6XrmJ5A4r4cd309axlpeJ6TkHBPuejOHigfL
 kV37LCDmJg3VEpfZ77+sbqxeqIZaGUOpkv8= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
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
 net/netfilter/ipvs/ip_vs_core.c       | 45 ++++++++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  6 +++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  7 ++++++
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  6 +++++
 4 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index efff6cf..564ba7f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1406,7 +1406,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, offset2, ihl, verdict;
-	bool ipip;
+	bool ipip, new_cp = false;
 
 	*related = 1;
 
@@ -1484,8 +1484,17 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	 * For IPIP this is error for request, not for reply.
 	 */
 	cp = pp->conn_in_get(AF_INET, skb, &ciph);
-	if (!cp)
-		return NF_ACCEPT;
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
 
 	verdict = NF_DROP;
 
@@ -1562,7 +1571,10 @@ ignore_ipip:
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
 out:
-	__ip_vs_conn_put(cp);
+	if (likely(!new_cp))
+		__ip_vs_conn_put(cp);
+	else
+		ip_vs_conn_put(cp);
 
 	return verdict;
 }
@@ -1578,6 +1590,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, verdict;
+	bool new_cp = false;
 
 	*related = 1;
 
@@ -1628,13 +1641,23 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	 */
 	cp = pp->conn_in_get(AF_INET6, skb, &ciph);
 
-	if (!cp)
-		return NF_ACCEPT;
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
 	/* VS/TUN, VS/DR and LOCALNODE just let it go */
 	if ((hooknum == NF_INET_LOCAL_OUT) &&
 	    (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)) {
-		__ip_vs_conn_put(cp);
-		return NF_ACCEPT;
+		verdict = NF_ACCEPT;
+		goto out;
 	}
 
 	/* do the statistics and put it back */
@@ -1648,7 +1671,11 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 
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

