From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH linux-next] ipvs: ip_vs_fill_iph_skb: Silence warning that 'iph.thoff_reasm' may be used uninitialized
Date: Sun, 10 Mar 2013 09:09:05 -0600
Message-ID: <1362928145-62682-1-git-send-email-tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tim Gardner <tim.gardner@canonical.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

If CONFIG_IP_VS_IPV6 is not defined, then ip_vs_fill_iph_skb() does not
initialize all of the fields in struct ip_vs_iphdr. Silence the 'may be used
uninitialized' warning in the IPV4 only case by initializing the only field
that is unique to IPV6.

net/netfilter/ipvs/ip_vs_pe_sip.c: In function 'ip_vs_sip_fill_param':
net/netfilter/ipvs/ip_vs_pe_sip.c:87:11: warning: 'iph.thoff_reasm' may be used uninitialized in this function [-Wuninitialized]

gcc version 4.6.3

Also update comment to correctly reference fragoffs.

Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 include/net/ip_vs.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 108ebe8..64ca32f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -165,14 +165,16 @@ ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
 static inline void
 ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 {
+	/* May not get initialized in all cases */
+	iphdr->thoff_reasm = 0;
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		const struct ipv6hdr *iph =
 			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
-		/* ipv6_find_hdr() updates len, flags, thoff_reasm */
-		iphdr->thoff_reasm = 0;
+		/* ipv6_find_hdr() updates len, flags, and fragoffs */
 		iphdr->len	 = 0;
 		iphdr->flags	 = 0;
 		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
-- 
1.7.9.5
