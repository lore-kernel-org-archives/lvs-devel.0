From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 06/84] ipvs: Pass ipvs not net to ip_vs_fill_conn
Date: Sun, 20 Sep 2015 01:22:22 -0500
Message-ID: <1442730220-32458-6-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

ipvs is what is actually desired so change the parameter and the modify
the callers to pass struct netns_ipvs.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h                     |  4 ++--
 net/netfilter/ipvs/ip_vs_conn.c         |  8 ++++----
 net/netfilter/ipvs/ip_vs_core.c         |  8 ++++----
 net/netfilter/ipvs/ip_vs_ftp.c          |  6 +++---
 net/netfilter/ipvs/ip_vs_nfct.c         |  2 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c | 14 +++++++-------
 net/netfilter/ipvs/ip_vs_sync.c         | 16 ++++++++--------
 7 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8cca99bbe15b..83e2aea63db2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1201,14 +1201,14 @@ enum {
 	IP_VS_DIR_LAST,
 };
 
-static inline void ip_vs_conn_fill_param(struct net *net, int af, int protocol,
+static inline void ip_vs_conn_fill_param(struct netns_ipvs *ipvs, int af, int protocol,
 					 const union nf_inet_addr *caddr,
 					 __be16 cport,
 					 const union nf_inet_addr *vaddr,
 					 __be16 vport,
 					 struct ip_vs_conn_param *p)
 {
-	p->ipvs = net_ipvs(net);
+	p->ipvs = ipvs;
 	p->af = af;
 	p->protocol = protocol;
 	p->caddr = caddr;
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d1b19bbacb45..afc7a7558434 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -148,7 +148,7 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_conn_param p;
 
-	ip_vs_conn_fill_param(cp->ipvs->net, cp->af, cp->protocol,
+	ip_vs_conn_fill_param(cp->ipvs, cp->af, cp->protocol,
 			      &cp->caddr, cp->cport, NULL, 0, &p);
 
 	if (cp->pe) {
@@ -319,17 +319,17 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 			    struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
-	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return 1;
 
 	if (likely(!ip_vs_iph_inverse(iph)))
-		ip_vs_conn_fill_param(net, af, iph->protocol, &iph->saddr,
+		ip_vs_conn_fill_param(ipvs, af, iph->protocol, &iph->saddr,
 				      pptr[0], &iph->daddr, pptr[1], p);
 	else
-		ip_vs_conn_fill_param(net, af, iph->protocol, &iph->daddr,
+		ip_vs_conn_fill_param(ipvs, af, iph->protocol, &iph->daddr,
 				      pptr[1], &iph->saddr, pptr[0], p);
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 3f33a076aaec..fd02aec0a11a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -215,7 +215,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      const union nf_inet_addr *vaddr, __be16 vport,
 			      struct ip_vs_conn_param *p)
 {
-	ip_vs_conn_fill_param(svc->net, svc->af, protocol, caddr, cport, vaddr,
+	ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, protocol, caddr, cport, vaddr,
 			      vport, p);
 	p->pe = rcu_dereference(svc->pe);
 	if (p->pe && p->pe->fill_param)
@@ -376,7 +376,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol, src_addr,
+	ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol, src_addr,
 			      src_port, dst_addr, dst_port, &param);
 
 	cp = ip_vs_conn_new(&param, dest->af, &dest->addr, dport, flags, dest,
@@ -524,7 +524,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	{
 		struct ip_vs_conn_param p;
 
-		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
+		ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol,
 				      caddr, cport, vaddr, vport, &p);
 		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
 				    dest->port ? dest->port : vport,
@@ -600,7 +600,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
+			ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol,
 					      &iph->saddr, pptr[0],
 					      &iph->daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, svc->af, &daddr, 0,
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 5ccbf3c16dd4..cf0cba956a21 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -223,14 +223,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(cp->ipvs->net, AF_INET,
+			ip_vs_conn_fill_param(cp->ipvs, AF_INET,
 					      iph->protocol, &from, port,
 					      &cp->caddr, 0, &p);
 			n_cp = ip_vs_conn_out_get(&p);
 		}
 		if (!n_cp) {
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(cp->ipvs->net,
+			ip_vs_conn_fill_param(cp->ipvs,
 					      AF_INET, IPPROTO_TCP, &cp->caddr,
 					      0, &cp->vaddr, port, &p);
 			/* As above, this is ipv4 only */
@@ -392,7 +392,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(cp->ipvs->net, AF_INET,
+		ip_vs_conn_fill_param(cp->ipvs, AF_INET,
 				      iph->protocol, &to, port, &cp->vaddr,
 				      htons(ntohs(cp->vport)-1), &p);
 		n_cp = ip_vs_conn_in_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index dae3c069966f..30434fb133df 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -161,7 +161,7 @@ static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
 
 	/* RS->CLIENT */
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	ip_vs_conn_fill_param(net, exp->tuple.src.l3num, orig->dst.protonum,
+	ip_vs_conn_fill_param(net_ipvs(net), exp->tuple.src.l3num, orig->dst.protonum,
 			      &orig->src.u3, orig->src.u.tcp.port,
 			      &orig->dst.u3, orig->dst.u.tcp.port, &p);
 	cp = ip_vs_conn_out_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index be1791d1c03f..406d9a433d92 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -41,16 +41,16 @@ struct isakmp_hdr {
 #define PORT_ISAKMP	500
 
 static void
-ah_esp_conn_fill_param_proto(struct net *net, int af,
+ah_esp_conn_fill_param_proto(struct netns_ipvs *ipvs, int af,
 			     const struct ip_vs_iphdr *iph,
 			     struct ip_vs_conn_param *p)
 {
 	if (likely(!ip_vs_iph_inverse(iph)))
-		ip_vs_conn_fill_param(net, af, IPPROTO_UDP,
+		ip_vs_conn_fill_param(ipvs, af, IPPROTO_UDP,
 				      &iph->saddr, htons(PORT_ISAKMP),
 				      &iph->daddr, htons(PORT_ISAKMP), p);
 	else
-		ip_vs_conn_fill_param(net, af, IPPROTO_UDP,
+		ip_vs_conn_fill_param(ipvs, af, IPPROTO_UDP,
 				      &iph->daddr, htons(PORT_ISAKMP),
 				      &iph->saddr, htons(PORT_ISAKMP), p);
 }
@@ -61,9 +61,9 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
-	ah_esp_conn_fill_param_proto(net, af, iph, &p);
+	ah_esp_conn_fill_param_proto(ipvs, af, iph, &p);
 	cp = ip_vs_conn_in_get(&p);
 	if (!cp) {
 		/*
@@ -88,9 +88,9 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
-	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 
-	ah_esp_conn_fill_param_proto(net, af, iph, &p);
+	ah_esp_conn_fill_param_proto(ipvs, af, iph, &p);
 	cp = ip_vs_conn_out_get(&p);
 	if (!cp) {
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 43f140950075..f8bc2027a6c4 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -784,21 +784,21 @@ control:
  *  fill_param used by version 1
  */
 static inline int
-ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
+ip_vs_conn_fill_param_sync(struct netns_ipvs *ipvs, int af, union ip_vs_sync_conn *sc,
 			   struct ip_vs_conn_param *p,
 			   __u8 *pe_data, unsigned int pe_data_len,
 			   __u8 *pe_name, unsigned int pe_name_len)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		ip_vs_conn_fill_param(net, af, sc->v6.protocol,
+		ip_vs_conn_fill_param(ipvs, af, sc->v6.protocol,
 				      (const union nf_inet_addr *)&sc->v6.caddr,
 				      sc->v6.cport,
 				      (const union nf_inet_addr *)&sc->v6.vaddr,
 				      sc->v6.vport, p);
 	else
 #endif
-		ip_vs_conn_fill_param(net, af, sc->v4.protocol,
+		ip_vs_conn_fill_param(ipvs, af, sc->v4.protocol,
 				      (const union nf_inet_addr *)&sc->v4.caddr,
 				      sc->v4.cport,
 				      (const union nf_inet_addr *)&sc->v4.vaddr,
@@ -953,7 +953,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 /*
  *  Process received multicast message for Version 0
  */
-static void ip_vs_process_message_v0(struct net *net, const char *buffer,
+static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer,
 				     const size_t buflen)
 {
 	struct ip_vs_sync_mesg_v0 *m = (struct ip_vs_sync_mesg_v0 *)buffer;
@@ -1009,14 +1009,14 @@ static void ip_vs_process_message_v0(struct net *net, const char *buffer,
 			}
 		}
 
-		ip_vs_conn_fill_param(net, AF_INET, s->protocol,
+		ip_vs_conn_fill_param(ipvs, AF_INET, s->protocol,
 				      (const union nf_inet_addr *)&s->caddr,
 				      s->cport,
 				      (const union nf_inet_addr *)&s->vaddr,
 				      s->vport, &param);
 
 		/* Send timeout as Zero */
-		ip_vs_proc_conn(net, &param, flags, state, s->protocol, AF_INET,
+		ip_vs_proc_conn(ipvs->net, &param, flags, state, s->protocol, AF_INET,
 				(union nf_inet_addr *)&s->daddr, s->dport,
 				0, 0, opt);
 	}
@@ -1171,7 +1171,7 @@ static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 			state = 0;
 		}
 	}
-	if (ip_vs_conn_fill_param_sync(net, af, s, &param, pe_data,
+	if (ip_vs_conn_fill_param_sync(net_ipvs(net), af, s, &param, pe_data,
 				       pe_data_len, pe_name, pe_name_len)) {
 		retc = 50;
 		goto out;
@@ -1268,7 +1268,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 		}
 	} else {
 		/* Old type of message */
-		ip_vs_process_message_v0(net, buffer, buflen);
+		ip_vs_process_message_v0(ipvs, buffer, buflen);
 		return;
 	}
 }
-- 
2.2.1
