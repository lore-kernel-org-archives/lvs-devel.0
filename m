From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] netfilter, ipvs: Avoid undefined order of evaluation in
 assignments to struct nf_conn *
Date: Sun, 29 May 2011 20:22:56 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1105292011450.4411@swampdragon.chaosbits.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: netfilter@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

In net/netfilter/ipvs/ip_vs_nfct.c::ip_vs_update_conntrack(),
net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_nat_xmit(), 
net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_nat_xmit_v6(), 
net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_icmp_xmit)() 
net/netfilter/ipvs/ip_vs_xmit.c::and ip_vs_icmp_xmit_v6() we do this:
	...
	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
	...

Since '=' is not a sequence point the order of these assignments happening 
is undefined. Luckily it's easy to avoid by just doing what is obviously 
the intended thing:
	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ip_vs_nfct.c |    2 +-
 ip_vs_xmit.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

 Compile tested only.
 Patch is against Linus' tree as of a few minutes ago.

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index f454c80..a3d86c2 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -82,7 +82,7 @@ void
 ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 {
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	struct nf_conntrack_tuple new_tuple;
 
 	if (ct == NULL || nf_ct_is_confirmed(ct) || nf_ct_is_untracked(ct) ||
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ee319a4..16d129e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -544,7 +544,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
@@ -661,7 +661,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
@@ -1176,7 +1176,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "
@@ -1296,7 +1296,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

