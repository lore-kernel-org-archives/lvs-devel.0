From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 02/12] ipvs: optimize checksums for apps
Date: Sun, 17 Oct 2010 16:17:20 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171614330.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Avoid full checksum calculation for apps that can provide
info whether csum was broken after payload mangling. For now only
ip_vs_ftp mangles payload and it updates the csum, so the full
recalculation is avoided for all packets.

 	Add CHECKSUM_UNNECESSARY for snat_handler (TCP and UDP).
It is needed to support SNAT from local address for the case
when csum is fully recalculated.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- nf-next-2.6-a91fd26/linux/include/net/ip_vs.h	2010-10-13 22:22:35.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-10-16 12:46:47.934355392 +0300
@@ -593,11 +593,19 @@ struct ip_vs_app {
  	__be16			port;		/* port number in net order */
  	atomic_t		usecnt;		/* usage counter */

-	/* output hook: return false if can't linearize. diff set for TCP.  */
+	/*
+	 * output hook: Process packet in inout direction, diff set for TCP.
+	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
+	 *	   2=Mangled but checksum was not updated
+	 */
  	int (*pkt_out)(struct ip_vs_app *, struct ip_vs_conn *,
  		       struct sk_buff *, int *diff);

-	/* input hook: return false if can't linearize. diff set for TCP. */
+	/*
+	 * input hook: Process packet in outin direction, diff set for TCP.
+	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
+	 *	   2=Mangled but checksum was not updated
+	 */
  	int (*pkt_in)(struct ip_vs_app *, struct ip_vs_conn *,
  		      struct sk_buff *, int *diff);

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_ftp.c linux/net/netfilter/ipvs/ip_vs_ftp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-10-16 12:46:47.934355392 +0300
@@ -242,9 +242,14 @@ static int ip_vs_ftp_out(struct ip_vs_ap
  			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
  						       start-data, end-start,
  						       buf, buf_len);
-			if (ret)
+			if (ret) {
  				ip_vs_nfct_expect_related(skb, ct, n_cp,
  							  IPPROTO_TCP, 0, 0);
+				if (skb->ip_summed == CHECKSUM_COMPLETE)
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				/* csum is updated */
+				ret = 1;
+			}
  		}

  		/*
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 12:46:09.514355652 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 12:46:47.935355696 +0300
@@ -120,6 +120,7 @@ tcp_snat_handler(struct sk_buff *skb,
  	struct tcphdr *tcph;
  	unsigned int tcphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -134,13 +135,20 @@ tcp_snat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;

  		/* Call application helper if needed */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - tcphoff;
+		else
+			payload_csum = 1;
  	}

  	tcph = (void *)skb_network_header(skb) + tcphoff;
@@ -151,12 +159,13 @@ tcp_snat_handler(struct sk_buff *skb,
  		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - tcphoff));
-	} else if (!cp->app) {
+	} else if (!payload_csum) {
  		/* Only port and addr are changed, do fast csum update */
  		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
  				     cp->dport, cp->vport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		tcph->check = 0;
@@ -174,6 +183,7 @@ tcp_snat_handler(struct sk_buff *skb,
  							skb->len - tcphoff,
  							cp->protocol,
  							skb->csum);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;

  		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
  			  pp->name, tcph->check,
@@ -190,6 +200,7 @@ tcp_dnat_handler(struct sk_buff *skb,
  	struct tcphdr *tcph;
  	unsigned int tcphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -204,6 +215,8 @@ tcp_dnat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -212,8 +225,13 @@ tcp_dnat_handler(struct sk_buff *skb,
  		 *	Attempt ip_vs_app call.
  		 *	It will fix ip_vs_conn and iph ack_seq stuff
  		 */
-		if (!ip_vs_app_pkt_in(cp, skb))
+		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - tcphoff;
+		else
+			payload_csum = 1;
  	}

  	tcph = (void *)skb_network_header(skb) + tcphoff;
@@ -226,12 +244,13 @@ tcp_dnat_handler(struct sk_buff *skb,
  		tcp_partial_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
  					htons(oldlen),
  					htons(skb->len - tcphoff));
-	} else if (!cp->app) {
+	} else if (!payload_csum) {
  		/* Only port and addr are changed, do fast csum update */
  		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
  				     cp->vport, cp->dport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		tcph->check = 0;
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c linux/net/netfilter/ipvs/ip_vs_proto_udp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 12:46:09.515355469 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 12:46:47.936355945 +0300
@@ -121,6 +121,7 @@ udp_snat_handler(struct sk_buff *skb,
  	struct udphdr *udph;
  	unsigned int udphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -135,6 +136,8 @@ udp_snat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -142,8 +145,13 @@ udp_snat_handler(struct sk_buff *skb,
  		/*
  		 *	Call application helper if needed
  		 */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - udphoff;
+		else
+			payload_csum = 1;
  	}

  	udph = (void *)skb_network_header(skb) + udphoff;
@@ -156,12 +164,13 @@ udp_snat_handler(struct sk_buff *skb,
  		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
  					htons(oldlen),
  					htons(skb->len - udphoff));
-	} else if (!cp->app && (udph->check != 0)) {
+	} else if (!payload_csum && (udph->check != 0)) {
  		/* Only port and addr are changed, do fast csum update */
  		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
  				     cp->dport, cp->vport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		udph->check = 0;
@@ -181,6 +190,7 @@ udp_snat_handler(struct sk_buff *skb,
  							skb->csum);
  		if (udph->check == 0)
  			udph->check = CSUM_MANGLED_0;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
  		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
  			  pp->name, udph->check,
  			  (char*)&(udph->check) - (char*)udph);
@@ -196,6 +206,7 @@ udp_dnat_handler(struct sk_buff *skb,
  	struct udphdr *udph;
  	unsigned int udphoff;
  	int oldlen;
+	int payload_csum = 0;

  #ifdef CONFIG_IP_VS_IPV6
  	if (cp->af == AF_INET6)
@@ -210,6 +221,8 @@ udp_dnat_handler(struct sk_buff *skb,
  		return 0;

  	if (unlikely(cp->app != NULL)) {
+		int ret;
+
  		/* Some checks before mangling */
  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
  			return 0;
@@ -218,8 +231,13 @@ udp_dnat_handler(struct sk_buff *skb,
  		 *	Attempt ip_vs_app call.
  		 *	It will fix ip_vs_conn
  		 */
-		if (!ip_vs_app_pkt_in(cp, skb))
+		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
  			return 0;
+		/* ret=2: csum update is needed after payload mangling */
+		if (ret == 1)
+			oldlen = skb->len - udphoff;
+		else
+			payload_csum = 1;
  	}

  	udph = (void *)skb_network_header(skb) + udphoff;
@@ -232,12 +250,13 @@ udp_dnat_handler(struct sk_buff *skb,
  		udp_partial_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
  					htons(oldlen),
  					htons(skb->len - udphoff));
-	} else if (!cp->app && (udph->check != 0)) {
+	} else if (!payload_csum && (udph->check != 0)) {
  		/* Only port and addr are changed, do fast csum update */
  		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
  				     cp->vport, cp->dport);
  		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = (cp->app && pp->csum_check) ?
+					 CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
  	} else {
  		/* full checksum calculation */
  		udph->check = 0;
