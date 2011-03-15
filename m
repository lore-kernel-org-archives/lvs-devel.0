From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 19/24] IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
Date: Tue, 15 Mar 2011 14:27:27 +0900
Message-ID: <1300166852-725-20-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 687ef18..77ebece 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1253,6 +1253,7 @@ extern int ip_vs_icmp_xmit_v6
  int offset);
 #endif
 
+#ifdef CONFIG_SYSCTL
 /*
  *	This is a simple mechanism to ignore packets when
  *	we are loaded. Just set ip_vs_drop_rate to 'n' and
@@ -1268,6 +1269,9 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 	ipvs->drop_counter = ipvs->drop_rate;
 	return 1;
 }
+#else
+static inline int ip_vs_todrop(struct netns_ipvs *ipvs) { return 0; }
+#endif
 
 /*
  *      ip_vs_fwd_tag returns the forwarding tag of the connection
-- 
1.7.2.3

