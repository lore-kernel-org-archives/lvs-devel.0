From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC allocation
Date: Fri, 13 Apr 2012 16:49:37 +0300
Message-ID: <1334324982-3143-2-git-send-email-ja@ssi.bg>
References: <1334324982-3143-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1334324982-3143-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	They are called only on initialization.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8531293..f549ff7 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -197,7 +197,7 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
 int *
 ip_vs_create_timeout_table(int *table, int size)
 {
-	return kmemdup(table, size, GFP_ATOMIC);
+	return kmemdup(table, size, GFP_KERNEL);
 }
 
 
-- 
1.7.3.4

