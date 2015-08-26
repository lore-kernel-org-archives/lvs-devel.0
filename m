From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 05/14] ipvs: drop inverse argument to conn_{in,out}_get
Date: Tue, 25 Aug 2015 20:49:20 -0700
Message-ID: <1440560969-3511889-5-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QKItJQn2zn53fPgtI5tzTXWtg8Ia9nM9rDM4Krot3co=;
 b=PbvFDXTLWHpFIagU2MVPS0Ov79z6XYsTBSpjMXmQtPvqACd/HZrS3Msp49grfB1QnlMb
 mm9BcoL/CUBk3aTXM8Blz7MjHc16xGkrWXyGTffkvtnPDLd5SSKy0mZ+C2ovWi9no8rE
 f6iwWNpepNpo6xEXdSlo5GIQNwHumnw5exk= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

No longer necessary since the information is included in the ip_vs_iphdr
itself.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h                     | 12 ++++--------
 net/netfilter/ipvs/ip_vs_conn.c         | 12 ++++++------
 net/netfilter/ipvs/ip_vs_core.c         | 31 ++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c | 17 ++++++++---------
 net/netfilter/xt_ipvs.c                 |  2 +-
 5 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 62d9c61..3d47b5f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -495,14 +495,12 @@ struct ip_vs_protocol {
 	struct ip_vs_conn *
 	(*conn_in_get)(int af,
 		       const struct sk_buff *skb,
-		       const struct ip_vs_iphdr *iph,
-		       int inverse);
+		       const struct ip_vs_iphdr *iph);
 
 	struct ip_vs_conn *
 	(*conn_out_get)(int af,
 			const struct sk_buff *skb,
-			const struct ip_vs_iphdr *iph,
-			int inverse);
+			const struct ip_vs_iphdr *iph);
 
 	int (*snat_handler)(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			    struct ip_vs_conn *cp, struct ip_vs_iphdr *iph);
@@ -1226,14 +1224,12 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
 struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-					    const struct ip_vs_iphdr *iph,
-					    int inverse);
+					    const struct ip_vs_iphdr *iph);
 
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-					     const struct ip_vs_iphdr *iph,
-					     int inverse);
+					     const struct ip_vs_iphdr *iph);
 
 /* Get reference to gain full access to conn.
  * By default, RCU read-side critical sections have access only to
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b0f7b62..f71b314 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -316,7 +316,7 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 static int
 ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 			    const struct ip_vs_iphdr *iph,
-			    int inverse, struct ip_vs_conn_param *p)
+			    struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
 	struct net *net = skb_net(skb);
@@ -325,7 +325,7 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 	if (pptr == NULL)
 		return 1;
 
-	if (likely(!inverse))
+	if (likely(!ip_vs_iph_inverse(iph)))
 		ip_vs_conn_fill_param(net, af, iph->protocol, &iph->saddr,
 				      pptr[0], &iph->daddr, pptr[1], p);
 	else
@@ -336,11 +336,11 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 
 struct ip_vs_conn *
 ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-			const struct ip_vs_iphdr *iph, int inverse)
+			const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(af, skb, iph, &p))
 		return NULL;
 
 	return ip_vs_conn_in_get(&p);
@@ -440,11 +440,11 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 
 struct ip_vs_conn *
 ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-			 const struct ip_vs_iphdr *iph, int inverse)
+			 const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(af, skb, iph, &p))
 		return NULL;
 
 	return ip_vs_conn_out_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 46869e4..905fc16 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -444,12 +444,18 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 *    Do not schedule replies from local real server.
 	 */
-	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (cp = pp->conn_in_get(svc->af, skb, iph, 1))) {
-		IP_VS_DBG_PKT(12, svc->af, pp, skb, iph->off,
-			      "Not scheduling reply for existing connection");
-		__ip_vs_conn_put(cp);
-		return NULL;
+	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK)) {
+		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
+		cp = pp->conn_in_get(svc->af, skb, iph);
+		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
+
+		if (cp) {
+			IP_VS_DBG_PKT(12, svc->af, pp, skb, iph->off,
+				      "Not scheduling reply for existing"
+				      " connection");
+			__ip_vs_conn_put(cp);
+			return NULL;
+		}
 	}
 
 	/*
@@ -943,7 +949,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph);
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
+	cp = pp->conn_out_get(AF_INET, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -998,7 +1004,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, &ciph, 1);
+	cp = pp->conn_out_get(AF_INET6, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1224,7 +1230,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(af, skb, &iph, 0);
+	cp = pp->conn_out_get(af, skb, &iph);
 
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
@@ -1455,7 +1461,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, ipip ? 0 : 1);
+	cp = pp->conn_in_get(AF_INET, skb, &ciph);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1598,8 +1604,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	/* The embedded headers contain source and dest in reverse order
 	 * if not from localhost
 	 */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
-			     (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1);
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph);
 
 	if (!cp)
 		return NF_ACCEPT;
@@ -1709,7 +1714,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(af, skb, &iph, 0);
+	cp = pp->conn_in_get(af, skb, &iph);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs &&
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5de3dd3..be1791d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -42,10 +42,10 @@ struct isakmp_hdr {
 
 static void
 ah_esp_conn_fill_param_proto(struct net *net, int af,
-			     const struct ip_vs_iphdr *iph, int inverse,
+			     const struct ip_vs_iphdr *iph,
 			     struct ip_vs_conn_param *p)
 {
-	if (likely(!inverse))
+	if (likely(!ip_vs_iph_inverse(iph)))
 		ip_vs_conn_fill_param(net, af, IPPROTO_UDP,
 				      &iph->saddr, htons(PORT_ISAKMP),
 				      &iph->daddr, htons(PORT_ISAKMP), p);
@@ -57,14 +57,13 @@ ah_esp_conn_fill_param_proto(struct net *net, int af,
 
 static struct ip_vs_conn *
 ah_esp_conn_in_get(int af, const struct sk_buff *skb,
-		   const struct ip_vs_iphdr *iph,
-		   int inverse)
+		   const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
 	struct net *net = skb_net(skb);
 
-	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(net, af, iph, &p);
 	cp = ip_vs_conn_in_get(&p);
 	if (!cp) {
 		/*
@@ -73,7 +72,7 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 		 */
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for outin packet "
 			      "%s%s %s->%s\n",
-			      inverse ? "ICMP+" : "",
+			      ip_vs_iph_icmp(iph) ? "ICMP+" : "",
 			      ip_vs_proto_get(iph->protocol)->name,
 			      IP_VS_DBG_ADDR(af, &iph->saddr),
 			      IP_VS_DBG_ADDR(af, &iph->daddr));
@@ -85,18 +84,18 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 
 static struct ip_vs_conn *
 ah_esp_conn_out_get(int af, const struct sk_buff *skb,
-		    const struct ip_vs_iphdr *iph, int inverse)
+		    const struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
 	struct net *net = skb_net(skb);
 
-	ah_esp_conn_fill_param_proto(net, af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(net, af, iph, &p);
 	cp = ip_vs_conn_out_get(&p);
 	if (!cp) {
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
 			      "%s%s %s->%s\n",
-			      inverse ? "ICMP+" : "",
+			      ip_vs_iph_icmp(iph) ? "ICMP+" : "",
 			      ip_vs_proto_get(iph->protocol)->name,
 			      IP_VS_DBG_ADDR(af, &iph->saddr),
 			      IP_VS_DBG_ADDR(af, &iph->daddr));
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 3704625..452ba2a 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, &iph, 1 /* inverse */);
+	cp = pp->conn_out_get(family, skb, &iph);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;
-- 
Alex Gartrell <agartrell@fb.com>

