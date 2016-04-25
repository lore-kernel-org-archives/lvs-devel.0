From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/9] ipv6: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:16 +0200
Message-ID: <1461572722-6029-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, johannes@sipsolutions.net, linux-wireless@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/ila.h |  1 +
 net/ipv6/ila/ila_lwt.c   |  3 ++-
 net/ipv6/ila/ila_xlat.c  | 15 +++++++++------
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/ila.h b/include/uapi/linux/ila.h
index abde7bbd6f3b..cd97951680bf 100644
--- a/include/uapi/linux/ila.h
+++ b/include/uapi/linux/ila.h
@@ -14,6 +14,7 @@ enum {
 	ILA_ATTR_LOCATOR_MATCH,			/* u64 */
 	ILA_ATTR_IFINDEX,			/* s32 */
 	ILA_ATTR_DIR,				/* u32 */
+	ILA_ATTR_PAD,
 
 	__ILA_ATTR_MAX,
 };
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 2ae3c4fd8aab..9db3621b2126 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -109,7 +109,8 @@ static int ila_fill_encap_info(struct sk_buff *skb,
 {
 	struct ila_params *p = ila_params_lwtunnel(lwtstate);
 
-	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator))
+	if (nla_put_u64_64bit(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator,
+			      ILA_ATTR_PAD))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 0b03533453e4..0e9e579410da 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -418,12 +418,15 @@ static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
 
 static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
 {
-	if (nla_put_u64(msg, ILA_ATTR_IDENTIFIER,
-			(__force u64)ila->p.identifier) ||
-	    nla_put_u64(msg, ILA_ATTR_LOCATOR,
-			(__force u64)ila->p.ip.locator) ||
-	    nla_put_u64(msg, ILA_ATTR_LOCATOR_MATCH,
-			(__force u64)ila->p.ip.locator_match) ||
+	if (nla_put_u64_64bit(msg, ILA_ATTR_IDENTIFIER,
+			      (__force u64)ila->p.identifier,
+			      ILA_ATTR_PAD) ||
+	    nla_put_u64_64bit(msg, ILA_ATTR_LOCATOR,
+			      (__force u64)ila->p.ip.locator,
+			      ILA_ATTR_PAD) ||
+	    nla_put_u64_64bit(msg, ILA_ATTR_LOCATOR_MATCH,
+			      (__force u64)ila->p.ip.locator_match,
+			      ILA_ATTR_PAD) ||
 	    nla_put_s32(msg, ILA_ATTR_IFINDEX, ila->p.ifindex) ||
 	    nla_put_u32(msg, ILA_ATTR_DIR, ila->p.dir))
 		return -1;
-- 
2.8.1

