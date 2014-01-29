From: Michal Kubecek <mkubecek@suse.cz>
Subject: [Patch resend nf] ipvs: fix AF assignment in ip_vs_conn_new()
Date: Wed, 29 Jan 2014 15:54:37 +0100 (CET)
Message-ID: <20140129145437.69F56E916F@unicorn.suse.cz>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>

If a fwmark is passed to ip_vs_conn_new(), it is passed in
vaddr, not daddr. Therefore we should set AF to AF_UNSPEC in
vaddr assignment (like we do in ip_vs_ct_in_get()).

Signed-off-by: Bogdano Arendartchuk <barendartchuk@suse.com>
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
(first time it didn't reach all recipients due to a malformed header)
---
 net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 59a1a85..282b39b 100644
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
+		       &cp->vaddr, vaddr);
+	cp->vport	   = p->vport;
+	ip_vs_addr_set(p->af, &cp->daddr, p->daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
-- 
1.8.1.4

