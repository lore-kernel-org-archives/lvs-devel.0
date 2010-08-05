From: Simon Horman <horms@verge.net.au>
Subject: [rfc 12/13] [RFC 12/13] IPVS: Fallback if persistence engine fails
Date: Thu, 05 Aug 2010 20:48:07 +0900
Message-ID: <20100805115241.864804832@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0012-IPVS-Fallback-if-persistence-engine-fails.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Fall back to normal persistence handling if the persistence
engine fails to recognise a packet.

This way, at least the packet will go somewhere.

It is envisaged that iptables could be used to block packets
such if this is not desired although nf_conntrack_sip would
likely need to be enhanced first.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    6 +++---
 net/netfilter/ipvs/ip_vs_core.c |   10 ++++------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index db5e0fd..ab3845d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -150,7 +150,7 @@ static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
 
 static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p)
 {
-	if (p->pe && p->pe->hashkey_raw)
+	if (p->pe_data && p->pe->hashkey_raw)
 		return p->pe->hashkey_raw(p, ip_vs_conn_rnd) &
 			ip_vs_conn_tab_mask;
 	return ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
@@ -340,7 +340,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->pe && p->pe->ct_match) {
+		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe->ct_match(p, cp))
 				goto out;
 			continue;
@@ -927,7 +927,7 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
-		if (cp->dest->svc->pe && cp->dest->svc->pe->show_pe_data) {
+		if (cp->pe_data && cp->dest->svc->pe->show_pe_data) {
 			pe_data[0] = ' ';
 			len = strlen(cp->dest->svc->pe->name);
 			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8cf87ea..4e53b13 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -175,7 +175,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
-static inline int
+static inline void
 ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
@@ -185,8 +185,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
-		return p->pe->fill_param(p, skb);
-	return 0;
+		p->pe->fill_param(p, skb);
 }
 
 /*
@@ -267,9 +266,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				vaddr = &fwmark;
 			}
 		}
-		if (ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
-						  vaddr, vport, &param))
-			return NULL;
+		ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
+					      vaddr, vport, &param);
 	}
 
 	/* Check if a template already exists */
-- 
1.7.1


