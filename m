From: Hans Schillstrom <hans@schillstrom.com>
Subject: [PATCH net] ipv6: ipv6_find_hdr restore prev functionality
Date: Thu, 27 Feb 2014 12:57:58 +0100
Message-ID: <1393502278-32297-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, ja@ssi.bg, aatteka@nicira.com, kaber@trash.net, ard@telegraafnet.nl, lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans@schillstrom.com>

The commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8 ("ipv6: improve 
ipv6_find_hdr() to skip empty routing headers") broke ipv6_find_hdr().

When a target is specified like IPPROTO_ICMPV6 ipv6_find_hdr()
returns -ENOENT when it's found, not the header as expected.

A part of IPVS is broken and possible also nft_exthdr_eval().
When target is -1 which it is most cases, it works.

This patch exits the do while loop if the specific header is found
so the nexthdr could be returned as expected.

Reported-by: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
CC:Ansis Atteka <aatteka@nicira.com>
---
 net/ipv6/exthdrs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 140748d..8af3eb5 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -212,7 +212,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		found = (nexthdr == target);
 
 		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
-			if (target < 0)
+			if (target < 0 || found)
 				break;
 			return -ENOENT;
 		}
-- 
1.7.11.7
