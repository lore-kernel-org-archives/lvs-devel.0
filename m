From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/4] Fix variable assignment in ip_vs_notrack
Date: Mon, 14 Mar 2011 07:44:21 +0900
Message-ID: <1300056261-14709-5-git-send-email-horms@verge.net.au>
References: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Jesper Juhl <jj@chaosbits.net>

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

