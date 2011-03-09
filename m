From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Fix variable assignment in ip_vs_notrack
Date: Wed, 9 Mar 2011 22:55:05 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1103092250510.4471@swampdragon.chaosbits.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, trivial@kernel.org

There's no sense to 'ct = ct = ' in ip_vs_notrack(). Just assign 
nf_ct_get()'s return value directly to the pointer variable 'ct' once.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ip_vs.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b7bbd6c..269d1ef 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1031,7 +1031,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
 		nf_reset(skb);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

