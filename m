From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 07/12] ipvs: create ip_vs_defrag_user
Date: Sun, 17 Oct 2010 16:32:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171629430.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Create new function ip_vs_defrag_user to return correct
IP_DEFRAG_xxx user depending on the hooknum. It will be needed
when we add handlers in LOCAL_OUT.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 16:30:01.832355877 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 17:18:47.290355715 +0300
@@ -543,6 +543,15 @@ __sum16 ip_vs_checksum_complete(struct s
  	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
  }

+static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
+{
+	if (NF_INET_LOCAL_IN == hooknum)
+		return IP_DEFRAG_VS_IN;
+	if (NF_INET_FORWARD == hooknum)
+		return IP_DEFRAG_VS_FWD;
+	return IP_DEFRAG_VS_OUT;
+}
+
  static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
  {
  	int err = ip_defrag(skb, user);
@@ -714,7 +723,8 @@ out:
   *	Find any that might be relevant, check against existing connections.
   *	Currently handles error types - unreachable, quench, ttl exceeded.
   */
-static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
+static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
+			  unsigned int hooknum)
  {
  	struct iphdr *iph;
  	struct icmphdr	_icmph, *ic;
@@ -729,7 +739,7 @@ static int ip_vs_out_icmp(struct sk_buff

  	/* reassemble IP fragments */
  	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
+		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
  			return NF_STOLEN;
  	}

@@ -788,7 +798,8 @@ static int ip_vs_out_icmp(struct sk_buff
  }

  #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
+static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
+			     unsigned int hooknum)
  {
  	struct ipv6hdr *iph;
  	struct icmp6hdr	_icmph, *ic;
@@ -804,7 +815,7 @@ static int ip_vs_out_icmp_v6(struct sk_b

  	/* reassemble IP fragments */
  	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
+		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
  			return NF_STOLEN;
  	}

@@ -986,7 +997,9 @@ ip_vs_out(unsigned int hooknum, struct s
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6) {
  		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
+			int related;
+			int verdict = ip_vs_out_icmp_v6(skb, &related,
+							hooknum);

  			if (related) {
  				if (sysctl_ip_vs_snat_reroute &&
@@ -1000,7 +1013,8 @@ ip_vs_out(unsigned int hooknum, struct s
  	} else
  #endif
  		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-			int related, verdict = ip_vs_out_icmp(skb, &related);
+			int related;
+			int verdict = ip_vs_out_icmp(skb, &related, hooknum);

  			if (related) {
  				if (sysctl_ip_vs_snat_reroute &&
@@ -1019,19 +1033,19 @@ ip_vs_out(unsigned int hooknum, struct s
  	/* reassemble IP fragments */
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6) {
-		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
-
-			if (related)
-				return verdict;
-
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
+			if (ip_vs_gather_frags_v6(skb,
+						  ip_vs_defrag_user(hooknum)))
+				return NF_STOLEN;
  		}
+
+		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
  	} else
  #endif
  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
  			     !pp->dont_defrag)) {
-			if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
+			if (ip_vs_gather_frags(skb,
+					       ip_vs_defrag_user(hooknum)))
  				return NF_STOLEN;

  			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
@@ -1114,8 +1128,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *

  	/* reassemble IP fragments */
  	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (ip_vs_gather_frags(skb, hooknum == NF_INET_LOCAL_IN ?
-					    IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD))
+		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
  			return NF_STOLEN;
  	}

@@ -1226,9 +1239,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in

  	/* reassemble IP fragments */
  	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, hooknum == NF_INET_LOCAL_IN ?
-					       IP_DEFRAG_VS_IN :
-					       IP_DEFRAG_VS_FWD))
+		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
  			return NF_STOLEN;
  	}

@@ -1349,7 +1360,8 @@ ip_vs_in(unsigned int hooknum, struct sk
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6) {
  		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
-			int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int related;
+			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);

  			if (related)
  				return verdict;
@@ -1358,7 +1370,8 @@ ip_vs_in(unsigned int hooknum, struct sk
  	} else
  #endif
  		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-			int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+			int related;
+			int verdict = ip_vs_in_icmp(skb, &related, hooknum);

  			if (related)
  				return verdict;
