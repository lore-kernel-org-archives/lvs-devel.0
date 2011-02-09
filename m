From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: remove extra lookups for ICMP packets
Date: Wed, 9 Feb 2011 02:26:38 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1102090222020.3494@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org


 	Remove code that should not be called anymore.
Now when ip_vs_out handles replies for local clients at
LOCAL_IN hook we do not need to call conn_out_get and
handle_response_icmp from ip_vs_in_icmp* because such
lookups were already performed for the ICMP packet and no
connection was found.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 	Patch is against lvs-test-2.6 from 09-FEB-2011
but should apply cleanly to net-next.

--- lvs-test-2.6-7c9989a/net/netfilter/ipvs/ip_vs_core.c	2011-02-07 13:40:00.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2011-02-09 02:02:53.135352388 +0200
@@ -729,7 +729,7 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
  #endif

  /* Handle relevant response ICMP messages - forward to the right
- * destination host. Used for NAT and local client.
+ * destination host.
   */
  static int handle_response_icmp(int af, struct sk_buff *skb,
  				union nf_inet_addr *snet,
@@ -979,7 +979,6 @@ static inline int is_tcp_reset(const str
  }

  /* Handle response packets: rewrite addresses and send away...
- * Used for NAT and local client.
   */
  static unsigned int
  handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
@@ -1280,7 +1279,6 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
  	struct ip_vs_protocol *pp;
  	struct ip_vs_proto_data *pd;
  	unsigned int offset, ihl, verdict;
-	union nf_inet_addr snet;

  	*related = 1;

@@ -1339,17 +1337,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
  	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
  	/* The embedded headers contain source and dest in reverse order */
  	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, 1);
-	if (!cp) {
-		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
-		if (cp) {
-			snet.ip = iph->saddr;
-			return handle_response_icmp(AF_INET, skb, &snet,
-						    cih->protocol, cp, pp,
-						    offset, ihl);
-		}
+	if (!cp)
  		return NF_ACCEPT;
-	}

  	verdict = NF_DROP;

@@ -1395,7 +1384,6 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	struct ip_vs_protocol *pp;
  	struct ip_vs_proto_data *pd;
  	unsigned int offset, verdict;
-	union nf_inet_addr snet;
  	struct rt6_info *rt;

  	*related = 1;
@@ -1455,18 +1443,8 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
  	/* The embedded headers contain source and dest in reverse order */
  	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
-	if (!cp) {
-		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
-		if (cp) {
-			ipv6_addr_copy(&snet.in6, &iph->saddr);
-			return handle_response_icmp(AF_INET6, skb, &snet,
-						    cih->nexthdr,
-						    cp, pp, offset,
-						    sizeof(struct ipv6hdr));
-		}
+	if (!cp)
  		return NF_ACCEPT;
-	}

  	verdict = NF_DROP;

