From: Simon Horman <horms@verge.net.au>
Subject: [patch v4 11/12] IPVS: Fallback if persistence engine fails
Date: Mon, 04 Oct 2010 18:04:03 +0900
Message-ID: <20101004090818.970365585@akiko.akashicho.tokyo.vergenet.net>
References: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0011-IPVS-Fallback-if-persistence-engine-fails.patch
Sender: netfilter-devel-owner@vger.kernel.org
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
Acked-by: Julian Anastasov <ja@ssi.bg>

---

v2
* Trivial rediff

v3
* Re-diff for addition of inverse parameter to ip_vs_conn_hashkey_param()
  and checking of cp->dest in ip_vs_conn_seq_show()

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-02 10:48:09.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-02 10:48:35.000000000 +0900
@@ -154,7 +154,7 @@ static unsigned int ip_vs_conn_hashkey_p
 	const union nf_inet_addr *addr;
 	__be16 port;
 
-	if (p->pe && p->pe->hashkey_raw)
+	if (p->pe_data && p->pe->hashkey_raw)
 		return p->pe->hashkey_raw(p, ip_vs_conn_rnd, inverse) &
 			ip_vs_conn_tab_mask;
 
@@ -353,7 +353,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->pe && p->pe->ct_match) {
+		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe->ct_match(p, cp))
 				goto out;
 			continue;
@@ -956,7 +956,7 @@ static int ip_vs_conn_seq_show(struct se
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
-		if (cp->dest && cp->dest->svc->pe &&
+		if (cp->dest && cp->pe_data &&
 		    cp->dest->svc->pe->show_pe_data) {
 			pe_data[0] = ' ';
 			len = strlen(cp->dest->svc->pe->name);
 			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-10-02 10:48:09.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-10-02 10:48:35.000000000 +0900
@@ -176,7 +176,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
-static inline int
+static inline void
 ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
@@ -186,8 +186,7 @@ ip_vs_conn_fill_param_persist(const stru
 	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
-		return p->pe->fill_param(p, skb);
-	return 0;
+		p->pe->fill_param(p, skb);
 }
 
 /*
@@ -268,9 +267,8 @@ ip_vs_sched_persist(struct ip_vs_service
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

