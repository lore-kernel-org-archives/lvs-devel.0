From: Julius Volz <julius.volz@gmail.com>
Subject: [PATCH] IPVS: Add IPv6 support to SH and DH schedulers
Date: Sun, 2 Nov 2008 00:13:19 +0100
Message-ID: <20081101231319.GA12150@cydonia.lan>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:mime-version:content-type:content-disposition:user-agent;
        bh=kJXlQgrl+D6v6afIdl3etmmBaBu/uP8bw0ttQZA2P50=;
        b=m7s6T88xMQiAuBhtrrosjwvaECP6TiTyWJN0NLjibq413KlVGaDlpNjHK34oF9Zivp
         T5RdS8UQaYj/d9+qEcWfUAvlKcI53Jmltqm5fW6wc3lxhXDevgY3JXl+orOFIXHWNK1d
         SjaxlZTa4PI8fEZqP12Hg1+sv2xvgl1X6jcVE=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au

Add IPv6 support to SH and DH schedulers. I hope this simple IPv6 address
hashing is good enough. The 128 bit are just XORed into 32 before hashing
them like an IPv4 address.

Signed-off-by: Julius Volz <julius.volz@gmail.com>
---
 net/netfilter/ipvs/ip_vs_dh.c |   30 +++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_sh.c |   30 +++++++++++++++++++++---------
 2 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 77179b9..d8258e0 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -64,9 +64,16 @@ struct ip_vs_dh_bucket {
 /*
  *	Returns hash value for IPVS DH entry
  */
-static inline unsigned ip_vs_dh_hashkey(__be32 addr)
+static inline unsigned ip_vs_dh_hashkey(int af, const union nf_inet_addr *addr)
 {
-	return (ntohl(addr)*2654435761UL) & IP_VS_DH_TAB_MASK;
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+	return (ntohl(addr_fold)*2654435761UL) & IP_VS_DH_TAB_MASK;
 }
 
 
@@ -74,9 +81,10 @@ static inline unsigned ip_vs_dh_hashkey(__be32 addr)
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_dh_get(struct ip_vs_dh_bucket *tbl, __be32 addr)
+ip_vs_dh_get(int af, struct ip_vs_dh_bucket *tbl,
+	     const union nf_inet_addr *addr)
 {
-	return (tbl[ip_vs_dh_hashkey(addr)]).dest;
+	return (tbl[ip_vs_dh_hashkey(af, addr)]).dest;
 }
 
 
@@ -202,12 +210,14 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_dh_bucket *tbl;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
+
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	IP_VS_DBG(6, "ip_vs_dh_schedule(): Scheduling...\n");
 
 	tbl = (struct ip_vs_dh_bucket *)svc->sched_data;
-	dest = ip_vs_dh_get(tbl, iph->daddr);
+	dest = ip_vs_dh_get(svc->af, tbl, &iph.daddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -215,8 +225,10 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 	}
 
-	IP_VS_DBG(6, "DH: destination IP address %pI4 --> server %pI4:%d\n",
-		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
+	IP_VS_DBG_BUF(6, "DH: destination IP address %s --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      ntohs(dest->port));
 
 	return dest;
 }
@@ -232,7 +244,7 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
 #ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	0,
+	.supports_ipv6 =	1,
 #endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index be5863c..4074ccf 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -61,9 +61,16 @@ struct ip_vs_sh_bucket {
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned ip_vs_sh_hashkey(__be32 addr)
+static inline unsigned ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
 {
-	return (ntohl(addr)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
 }
 
 
@@ -71,9 +78,10 @@ static inline unsigned ip_vs_sh_hashkey(__be32 addr)
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(struct ip_vs_sh_bucket *tbl, __be32 addr)
+ip_vs_sh_get(int af, struct ip_vs_sh_bucket *tbl,
+	     const union nf_inet_addr *addr)
 {
-	return (tbl[ip_vs_sh_hashkey(addr)]).dest;
+	return (tbl[ip_vs_sh_hashkey(af, addr)]).dest;
 }
 
 
@@ -199,12 +207,14 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_bucket *tbl;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
+
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
 	tbl = (struct ip_vs_sh_bucket *)svc->sched_data;
-	dest = ip_vs_sh_get(tbl, iph->saddr);
+	dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -212,8 +222,10 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 	}
 
-	IP_VS_DBG(6, "SH: source IP address %pI4 --> server %pI4:%d\n",
-		  &iph->saddr, &dest->addr.ip, ntohs(dest->port));
+	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      ntohs(dest->port));
 
 	return dest;
 }
@@ -229,7 +241,7 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.module =		THIS_MODULE,
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
 #ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	0,
+	.supports_ipv6 =	1,
 #endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
-- 
1.5.3.7


