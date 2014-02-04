From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: fix AF assignment in ip_vs_conn_new()
Date: Tue,  4 Feb 2014 21:34:21 +0900
Message-ID: <1391517261-27222-2-git-send-email-horms@verge.net.au>
References: <1391517261-27222-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1391517261-27222-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Michal Kubecek <mkubecek@suse.cz>, Bogdano Arendartchuk <barendartchuk@suse.com>, Simon Horman <horms@verge.net.au>

From: Michal Kubecek <mkubecek@suse.cz>

If a fwmark is passed to ip_vs_conn_new(), it is passed in
vaddr, not daddr. Therefore we should set AF to AF_UNSPEC in
vaddr assignment (like we do in ip_vs_ct_in_get()), otherwise we
may copy only first 4 bytes of an IPv6 address into cp->daddr.

Signed-off-by: Bogdano Arendartchuk <barendartchuk@suse.com>
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 59a1a85..a8eb0a8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -871,11 +871,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	cp->protocol	   = p->protocol;
 	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
 	cp->cport	   = p->cport;
-	ip_vs_addr_set(p->af, &cp->vaddr, p->vaddr);
-	cp->vport	   = p->vport;
-	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
+	/* proto should only be IPPROTO_IP if p->vaddr is a fwmark */
 	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
-		       &cp->daddr, daddr);
+		       &cp->vaddr, p->vaddr);
+	cp->vport	   = p->vport;
+	ip_vs_addr_set(p->af, &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
-- 
1.8.5.2
