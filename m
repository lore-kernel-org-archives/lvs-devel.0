From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 04/24] IPVS: Fix variable assignment in ip_vs_notrack
Date: Tue, 15 Mar 2011 14:27:12 +0900
Message-ID: <1300166852-725-5-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Jesper Juhl <jj@chaosbits.net>, Simon Horman <horms@verge.net.au>

From: Jesper Juhl <jj@chaosbits.net>

There's no sense to 'ct = ct = ' in ip_vs_notrack(). Just assign
nf_ct_get()'s return value directly to the pointer variable 'ct' once.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e74da41e..1dcb75d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1190,7 +1190,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
 		nf_reset(skb);
-- 
1.7.2.3

