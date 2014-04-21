From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] netfilter: Fix format string mismatch in ip_vs_proto_name()
Date: Mon, 21 Apr 2014 09:16:47 +0900
Message-ID: <1398039407-12060-2-git-send-email-horms@verge.net.au>
References: <1398039407-12060-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1398039407-12060-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Masanari Iida <standby24x7@gmail.com>, Simon Horman <horms@verge.net.au>

From: Masanari Iida <standby24x7@gmail.com>

Fix string mismatch in ip_vs_proto_name()

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f26ee4..d9da8c4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -97,7 +97,7 @@ const char *ip_vs_proto_name(unsigned int proto)
 		return "ICMPv6";
 #endif
 	default:
-		sprintf(buf, "IP_%d", proto);
+		sprintf(buf, "IP_%u", proto);
 		return buf;
 	}
 }
-- 
1.8.5.2

