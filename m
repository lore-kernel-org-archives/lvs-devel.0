From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 11/12] IPVS: Fallback if persistence engine fails
Date: Sun, 22 Aug 2010 21:45:08 +0900
Message-ID: <20100822124900.505995463@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=pe-fallback.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Fall back to normal persistence handling if the persistence
engine fails to recognise a packet.

This way, at least the packet will go somewhere.

It is envisaged that iptables could be used to block packets
such if this is not desired although nf_conntrack_sip would
likely need to be enhanced first.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-07-27 22:10:18.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-07-27 22:12:05.000000000 +0900
@@ -150,7 +150,7 @@ static unsigned int ip_vs_conn_hashkey(i
 
 static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p)
 {
-	if (p->pe && p->pe->hashkey_raw)
+	if (p->pe_data && p->pe->hashkey_raw)
 		return p->pe->hashkey_raw(p, ip_vs_conn_rnd) &
 			ip_vs_conn_tab_mask;
 	return ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
@@ -340,7 +340,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->pe && p->pe->ct_match) {
+		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe->ct_match(p, cp))
 				goto out;
 			continue;
@@ -927,7 +927,7 @@ static int ip_vs_conn_seq_show(struct se
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
-		if (cp->dest->svc->pe && cp->dest->svc->pe->show_pe_data) {
+		if (cp->pe_data && cp->dest->svc->pe->show_pe_data) {
 			pe_data[0] = ' ';
 			len = strlen(cp->dest->svc->pe->name);
 			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-07-27 22:10:18.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-07-27 22:12:05.000000000 +0900
@@ -175,7 +175,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
-static inline int
+static inline void
 ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
@@ -185,8 +185,7 @@ ip_vs_conn_fill_param_persist(const stru
 	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
-		return p->pe->fill_param(p, skb);
-	return 0;
+		p->pe->fill_param(p, skb);
 }
 
 /*
@@ -267,9 +266,8 @@ ip_vs_sched_persist(struct ip_vs_service
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

