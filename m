From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/4] ipvs: handle ip_vs_fill_iph_skb_off failure
Date: Mon,  7 Mar 2016 12:03:31 +0900
Message-ID: <1457319814-8027-2-git-send-email-horms@verge.net.au>
References: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319820; bh=2mOVxJVXZ6W1SNpjNIPxj5wIp+9XbPgMuJHKLa/dz2o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=S1I9TD1b3WkPv1ba2iOgfAeeSXGb3KuCPh+ClKu4WWMUAtI5fsWFTjnuD8YlPkTdG
	 aTX5tvxeYYzc6FTnRJncxyRu/VPW1wvERe3EYEc7959Kf5n4sn9ENsWdnTQRN+YYcP
	 jUZEfgsN3oUy2RefVnRYsjJwVKM0yqpKXDmkSEJ4=
In-Reply-To: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Arnd Bergmann <arnd@arndb.de>, Simon Horman <horms@verge.net.au>

From: Arnd Bergmann <arnd@arndb.de>

ip_vs_fill_iph_skb_off() may not find an IP header, and gcc has
determined that ip_vs_sip_fill_param() then incorrectly accesses
the protocol fields:

net/netfilter/ipvs/ip_vs_pe_sip.c: In function 'ip_vs_sip_fill_param':
net/netfilter/ipvs/ip_vs_pe_sip.c:76:5: error: 'iph.protocol' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  if (iph.protocol != IPPROTO_UDP)
     ^
net/netfilter/ipvs/ip_vs_pe_sip.c:81:10: error: 'iph.len' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  dataoff = iph.len + sizeof(struct udphdr);
          ^

This adds a check for the ip_vs_fill_iph_skb_off() return code
before looking at the ip header data returned from it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b0e010c527de ("ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1b8d594e493a..c4e9ca016a88 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -70,10 +70,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	const char *dptr;
 	int retc;
 
-	ip_vs_fill_iph_skb(p->af, skb, false, &iph);
+	retc = ip_vs_fill_iph_skb(p->af, skb, false, &iph);
 
 	/* Only useful with UDP */
-	if (iph.protocol != IPPROTO_UDP)
+	if (!retc || iph.protocol != IPPROTO_UDP)
 		return -EINVAL;
 	/* todo: IPv6 fragments:
 	 *       I think this only should be done for the first fragment. /HS
-- 
2.1.4

