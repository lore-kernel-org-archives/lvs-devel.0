From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH ipvs-next] ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL
Date: Tue,  6 Aug 2013 11:20:23 +0200
Message-ID: <416f7af019bf82342eee08dcb3fc3ca8b4931e6a.1375780430.git.dborkman@redhat.com>
References: <cover.1375780430.git.dborkman@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1375780430.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, dborkman@redhat.com

skb_header_pointer could return NULL, so check for it as we do it
everywhere else in ipvs code. This fixes a coverity warning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 I'd consider the case of NULL quite unlikely, therefore ipvs-next should
 be sufficient.

 net/netfilter/ipvs/ip_vs_sh.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index f16c027..3588fae 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -269,14 +269,20 @@ ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
 		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (unlikely(th == NULL))
+			return 0;
 		port = th->source;
 		break;
 	case IPPROTO_UDP:
 		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		if (unlikely(uh == NULL))
+			return 0;
 		port = uh->source;
 		break;
 	case IPPROTO_SCTP:
 		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		if (unlikely(sh == NULL))
+			return 0;
 		port = sh->source;
 		break;
 	default:
-- 
1.7.11.7

