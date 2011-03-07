From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] netfilter:ipvs: use kmemdup
Date: Mon, 07 Mar 2011 10:11:34 +0800
Message-ID: <4D743ED6.5010608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, ja@ssi.bg, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

The semantic patch that makes this output is available
in scripts/coccinelle/api/memdup.cocci.

More information about semantic patching is available at
http://coccinelle.lip6.fr/


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |    9 ++++-----
 net/netfilter/ipvs/ip_vs_sync.c   |    3 +--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 0d83bc0..13d607a 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -92,14 +92,13 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
 		return -EINVAL;
 
-	p->pe_data = kmalloc(matchlen, GFP_ATOMIC);
-	if (!p->pe_data)
-		return -ENOMEM;
-
 	/* N.B: pe_data is only set on success,
 	 * this allows fallback to the default persistence logic on failure
 	 */
-	memcpy(p->pe_data, dptr + matchoff, matchlen);
+	p->pe_data = kmemdup(dptr + matchoff, matchlen, GFP_ATOMIC);
+	if (!p->pe_data)
+		return -ENOMEM;
+
 	p->pe_data_len = matchlen;
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index fecf24d..c5d13b0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -697,13 +697,12 @@ ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
 			return 1;
 		}
 
-		p->pe_data = kmalloc(pe_data_len, GFP_ATOMIC);
+		p->pe_data = kmemdup(pe_data, pe_data_len, GFP_ATOMIC);
 		if (!p->pe_data) {
 			if (p->pe->module)
 				module_put(p->pe->module);
 			return -ENOMEM;
 		}
-		memcpy(p->pe_data, pe_data, pe_data_len);
 		p->pe_data_len = pe_data_len;
 	}
 	return 0;
-- 
1.6.3.3
