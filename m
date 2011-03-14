From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 16/20] IPVS: Conditional ip_vs_conntrack_enabled()
Date: Mon, 14 Mar 2011 12:45:42 +0900
Message-ID: <1300074346-13799-17-git-send-email-horms@verge.net.au>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

ip_vs_conntrack_enabled() becomes a noop when CONFIG_SYSCTL is undefined.

In preparation for not including sysctl_conntrack in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 77ebece..299aeb5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1359,7 +1359,11 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
  */
 static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 {
+#ifdef CONFIG_SYSCTL
 	return ipvs->sysctl_conntrack;
+#else
+	return 0;
+#endif
 }
 
 extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
-- 
1.7.2.3

