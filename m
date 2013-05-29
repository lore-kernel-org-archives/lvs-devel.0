From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] ip_vs_sh: fix build
Date: Wed, 29 May 2013 13:33:51 +0100
Message-ID: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org, ja@ssi.bg, horms@verge.net.au
Cc: pablo@netfilter.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

kfree_rcu() requires offsetof(..., rcu_head) < 4096, which can get
violated with a sufficiently high CONFIG_IP_VS_SH_TAB_BITS.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 net/netfilter/ipvs/ip_vs_sh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.10-rc3/net/netfilter/ipvs/ip_vs_sh.c
+++ 3.10-rc3-ip_vs_sh-build/net/netfilter/ipvs/ip_vs_sh.c
@@ -67,8 +67,8 @@ struct ip_vs_sh_bucket {
 #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
 
 struct ip_vs_sh_state {
-	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
 	struct rcu_head			rcu_head;
+	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
 };
 
 /*



