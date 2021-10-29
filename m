From: yangxingwu <xingwu.yang@gmail.com>
Subject: [PATCH v2] ipvs: Fix reuse connection if RS weight is 0
Date: Fri, 29 Oct 2021 11:26:04 +0800
Message-ID: <20211029032604.5432-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-doc-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=LtgP/cUoxxhvYcfdihWX13hRZAIDcFCne2uXGpi/AnA=;
        b=pnVPSE1jjdTlHf5q+/QOUvnEnDh/dyo56Nltoztkn7rp+u2qIthB4nz3zQts+FpEaC
         ztX77ZUZG39hwxvuBeOUVCq5ol3T6+oOYJa8bHnbXZE2cWTGG1Qf0O0YXl73KaFpu0iQ
         CQXkjEnU7IFLnvn1f+Ij2haWAY7oY5krONTZ2Xss/PowjeSm5Eo0LA9lKrxzzz6qm9qz
         X7/4eE9kpYZ+AKwDk8M+IgYdSOGwXG1VqZ6gjFdouNpSWYHLJ8iiRXPGpy33W6w4GqTc
         D3PDOZdA/hsQZ5Em7wFXVcQrmlWHF8ctOokrHC4PdaoO1KdkhrtW38ry8HxfVeJYrwJg
         f9kA==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: horms@verge.net.au
Cc: ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, corbet@lwn.net, xingwu.yang@gmail.com, legend050709@qq.com

Since commit dc7b3eb900aa ("ipvs: Fix reuse connection if real server is
dead"), new connections to dead servers are redistributed immediately to
new servers.

Then commit d752c3645717 ("ipvs: allow rescheduling of new connections when
port reuse is detected") disable expire_nodest_conn if conn_reuse_mode is
0. And new connection may be distributed to a real server with weight 0.

Co-developed-by: Chuanqi Liu <legend050709@qq.com>
Signed-off-by: Chuanqi Liu <legend050709@qq.com>
Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
---
 Documentation/networking/ipvs-sysctl.rst | 3 +--
 net/netfilter/ipvs/ip_vs_core.c          | 7 ++++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 2afccc63856e..1cfbf1add2fc 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -37,8 +37,7 @@ conn_reuse_mode - INTEGER
 
 	0: disable any special handling on port reuse. The new
 	connection will be delivered to the same real server that was
-	servicing the previous connection. This will effectively
-	disable expire_nodest_conn.
+	servicing the previous connection.
 
 	bit 1: enable rescheduling of new connections when it is safe.
 	That is, whenever expire_nodest_conn and for TCP sockets, when
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 128690c512df..374f4b0b7080 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2042,14 +2042,15 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 			     ipvs, af, skb, &iph);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
-	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
+	if (!iph.fragoffs && is_new_conn(skb, &iph) && cp) {
 		bool old_ct = false, resched = false;
 
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
-		    unlikely(!atomic_read(&cp->dest->weight))) {
+		    unlikely(!atomic_read(&cp->dest->weight)) && !cp->control) {
 			resched = true;
 			old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
-		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
+		} else if (conn_reuse_mode &&
+			   is_new_conn_expected(cp, conn_reuse_mode)) {
 			old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
 			if (!atomic_read(&cp->n_control)) {
 				resched = true;
-- 
2.30.2

