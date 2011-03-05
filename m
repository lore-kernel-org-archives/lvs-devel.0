From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 13/18] IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
Date: Sun,  6 Mar 2011 08:45:55 +0900
Message-ID: <1299368760-14271-14-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 29cbe39..18b3842 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1250,6 +1250,7 @@ extern int ip_vs_icmp_xmit_v6
  int offset);
 #endif
 
+#ifdef CONFIG_SYSCTL
 /*
  *	This is a simple mechanism to ignore packets when
  *	we are loaded. Just set ip_vs_drop_rate to 'n' and
@@ -1265,6 +1266,9 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
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

