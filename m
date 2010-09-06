From: Simon Horman <horms@verge.net.au>
Subject: [patch net] ipvs: fix active FTP
Date: Mon, 6 Sep 2010 13:02:29 +0900
Message-ID: <20100906040228.GA21473@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

From: Julian Anastasov <ja@ssi.bg>

- Do not create expectation when forwarding the PORT
  command to avoid blocking the connection. The problem is that
  nf_conntrack_ftp.c:help() tries to create the same expectation later in
  POST_ROUTING and drops the packet with "dropping packet" message after
  failure in nf_ct_expect_related.

- Change ip_vs_update_conntrack to alter the conntrack
  for related connections from real server. If we do not alter the reply in
  this direction the next packet from client sent to vport 20 comes as NEW
  connection. We alter it but may be some collision happens for both
  conntracks and the second conntrack gets destroyed immediately. The
  connection stucks too.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

Dave, this patch fixes a regression since 2.6.35 so please consider it for net.

This change is also applicable to net-next, although there is some diff
noise. Do you want me to resolve that and post a net-next version
separately? (The same applies to "ipvs: avoid oops for passive FTP" which
you merged into net last week.)

Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2010-09-02 17:21:01.000000000 +0900
+++ net-2.6/include/net/ip_vs.h	2010-09-06 12:56:34.000000000 +0900
@@ -955,6 +955,9 @@ static inline __wsum ip_vs_check_diff2(_
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
+extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
+				   int outin);
+
 #endif /* __KERNEL__ */
 
 #endif	/* _NET_IP_VS_H */
Index: net-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-09-02 17:21:04.000000000 +0900
+++ net-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-09-06 12:56:34.000000000 +0900
@@ -924,6 +924,7 @@ handle_response(int af, struct sk_buff *
 
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	ip_vs_update_conntrack(skb, cp, 0);
 	ip_vs_conn_put(cp);
 
 	skb->ipvs_property = 1;
Index: net-2.6/net/netfilter/ipvs/ip_vs_ftp.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-06 12:54:17.000000000 +0900
+++ net-2.6/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-06 12:56:34.000000000 +0900
@@ -410,7 +410,6 @@ static int ip_vs_ftp_in(struct ip_vs_app
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
-	struct nf_conn *ct;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -497,11 +496,6 @@ static int ip_vs_ftp_in(struct ip_vs_app
 		ip_vs_control_add(n_cp, cp);
 	}
 
-	ct = (struct nf_conn *)skb->nfct;
-	if (ct && ct != &nf_conntrack_untracked)
-		ip_vs_expect_related(skb, ct, n_cp,
-				     IPPROTO_TCP, &n_cp->dport, 1);
-
 	/*
 	 *	Move tunnel to listen state
 	 */
Index: net-2.6/net/netfilter/ipvs/ip_vs_xmit.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_xmit.c	2010-09-02 17:21:04.000000000 +0900
+++ net-2.6/net/netfilter/ipvs/ip_vs_xmit.c	2010-09-06 12:56:34.000000000 +0900
@@ -349,8 +349,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
 }
 #endif
 
-static void
-ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+void
+ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 {
 	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 	struct nf_conntrack_tuple new_tuple;
@@ -365,11 +365,17 @@ ip_vs_update_conntrack(struct sk_buff *s
 	 * real-server we will see RIP->DIP.
 	 */
 	new_tuple = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-	new_tuple.src.u3 = cp->daddr;
+	if (outin)
+		new_tuple.src.u3 = cp->daddr;
+	else
+		new_tuple.dst.u3 = cp->vaddr;
 	/*
 	 * This will also take care of UDP and other protocols.
 	 */
-	new_tuple.src.u.tcp.port = cp->dport;
+	if (outin)
+		new_tuple.src.u.tcp.port = cp->dport;
+	else
+		new_tuple.dst.u.tcp.port = cp->vport;
 	nf_conntrack_alter_reply(ct, &new_tuple);
 }
 
@@ -428,7 +434,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
-	ip_vs_update_conntrack(skb, cp);
+	ip_vs_update_conntrack(skb, cp, 1);
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
@@ -506,7 +512,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
-	ip_vs_update_conntrack(skb, cp);
+	ip_vs_update_conntrack(skb, cp, 1);
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
