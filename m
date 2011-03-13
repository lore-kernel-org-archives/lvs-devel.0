From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/4] ipvs: avoid lookup for fwmark 0
Date: Mon, 14 Mar 2011 07:44:18 +0900
Message-ID: <1300056261-14709-2-git-send-email-horms@verge.net.au>
References: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Restore the previous behaviour to lookup for fwmark
service only when fwmark is non-null. This saves only CPU.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c73b0c8..f0369d6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -411,9 +411,11 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	svc = __ip_vs_svc_fwm_find(net, af, fwmark);
-	if (fwmark && svc)
-		goto out;
+	if (fwmark) {
+		svc = __ip_vs_svc_fwm_find(net, af, fwmark);
+		if (svc)
+			goto out;
+	}
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
-- 
1.7.2.3

