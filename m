From: xiaoyu Du <tingsrain@gmail.com>
Subject: [PATCH] IPVS : bugfix for ICMPv6 checksum calculation
Date: Thu, 12 Aug 2010 09:39:15 +0800
Message-ID: <AANLkTimQSppX5HzBoAcU73+7odFBJ8jXHBtszBO+8LVm@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:date:message-id
         :subject:from:to:content-type;
        bh=rM0zLb8C5UkkcZQO0VA2PaN2SB9bHWsZKVnBiP5UeCQ=;
        b=HHQT0B3R692ZdJaofAiWnH/k2c3xlNZ8WmoC3P8qZYymwNBZ/VWn15OiUEF4FL8nT/
         gN+TNgjTOu6GzYBeXsOCj1lGWzpn/9Tzv3N3vk1D+kU0UnX//ZR/M5kHf15RIf/yaoLn
         IOzFHJwYcbBCTmRzqnNJ8IFJOYXLklZXNWrR4=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hi:

This patch correct the ICMPv6 checksum calculation when IPv6 vs is used.

Signed-off-by: Xiaoyu Du <tingsrain@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f8ddba..124a1ae 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -638,8 +638,12 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb,
struct ip_vs_protocol *pp,

 	/* And finally the ICMP checksum */
 	icmph->icmp6_cksum = 0;
-	/* TODO IPv6: is this correct for ICMPv6? */
 	ip_vs_checksum_complete(skb, icmp_offset);
+	icmph->icmp6_cksum = csum_ipv6_magic(&iph->saddr,
+			&iph->daddr,
+			skb->len - icmp_offset, IPPROTO_ICMPV6,
+			skb->csum);
+
 	skb->ip_summed = CHECKSUM_UNNECESSARY;

 	if (inout)
--
