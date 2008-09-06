From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: fix bogus indentation
Date: Sat, 6 Sep 2008 14:26:48 +1000
Message-ID: <20080906042644.GD21521@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julius Volz <juliusv@google.com>

Sorry, this was my error.
Thanks to Julius Volz for pointing it out.

Cc: Julius Volz <juliusv@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 05797a5..1f4f3b9 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1033,7 +1033,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 							  ICMP_DEST_UNREACH,
 							  ICMP_PORT_UNREACH, 0);
 					return NF_DROP;
-			}
+				}
 			}
 		}
 		IP_VS_DBG_PKT(12, pp, skb, 0,

