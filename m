From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 07/25] IPVS: Add v6 support to ip_vs_service_get()
Date: Mon,  1 Sep 2008 14:56:04 +0200
Message-ID: <1220273782-19901-8-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273823; bh=4VMrTwQXBflzklWEiNwNdDwAemM=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=aCgRO8SRmwPiYX7Lu++KV4VHK9vish7KJiOWBNvK
	w5c4omAbEQ8Tknb2knzQkEuTDoe9ycFoqb86okB+yRtzng==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add support for selecting services based on their address family to
ip_vs_service_get() and adjust the callers.

Signed-off-by: Julius Volz <juliusv@google.com>

 4 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9657bd4..d653e8b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -783,7 +783,8 @@ extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 
 extern struct ip_vs_service *
-ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport);
+ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+		  const union nf_inet_addr *vaddr, __be16 vport);
 
 static inline void ip_vs_service_put(struct ip_vs_service *svc)
 {
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index aa74d20..151d368 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -421,23 +421,24 @@ __ip_vs_svc_fwm_get(int af, __u32 fwmark)
 }
 
 struct ip_vs_service *
-ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
+ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+		  const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
-	union nf_inet_addr _vaddr = { .ip = vaddr };
+
 	read_lock(&__ip_vs_svc_lock);
 
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_get(AF_INET, fwmark)))
+	if (fwmark && (svc = __ip_vs_svc_fwm_get(af, fwmark)))
 		goto out;
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, vport);
+	svc = __ip_vs_service_get(af, protocol, vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -447,7 +448,7 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, FTPPORT);
+		svc = __ip_vs_service_get(af, protocol, vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -455,16 +456,16 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, 0);
+		svc = __ip_vs_service_get(af, protocol, vaddr, 0);
 	}
 
   out:
 	read_unlock(&__ip_vs_svc_lock);
 
-	IP_VS_DBG(9, "lookup service: fwm %u %s %u.%u.%u.%u:%u %s\n",
-		  fwmark, ip_vs_proto_name(protocol),
-		  NIPQUAD(vaddr), ntohs(vport),
-		  svc?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup service: fwm %u %s %s:%u %s\n",
+		      fwmark, ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, vaddr), ntohs(vport),
+		      svc ? "hit" : "not hit");
 
 	return svc;
 }
@@ -605,8 +606,9 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
+	union nf_inet_addr _vaddr = { .ip = vaddr };
 
-	svc = ip_vs_service_get(0, protocol, vaddr, vport);
+	svc = ip_vs_service_get(AF_INET, 0, protocol, &_vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 15860e1..fe93c9e 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -74,16 +74,19 @@ tcp_conn_schedule(struct sk_buff *skb,
 {
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
+	struct ip_vs_iphdr iph;
 
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+
+	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
 	if (th->syn &&
-	    (svc = ip_vs_service_get(skb->mark, ip_hdr(skb)->protocol,
-				     ip_hdr(skb)->daddr, th->dest))) {
+	    (svc = ip_vs_service_get(AF_INET, skb->mark, iph.protocol,
+				     &iph.daddr, th->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 8dfad5d..5aefdf5 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -80,16 +80,18 @@ udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 {
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
+	struct ip_vs_iphdr iph;
 
-	uh = skb_header_pointer(skb, ip_hdrlen(skb),
-				sizeof(_udph), &_udph);
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+
+	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
-	if ((svc = ip_vs_service_get(skb->mark, ip_hdr(skb)->protocol,
-				     ip_hdr(skb)->daddr, uh->dest))) {
+	if ((svc = ip_vs_service_get(AF_INET, skb->mark, iph.protocol,
+				     &iph.daddr, uh->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
-- 
1.5.4.5

