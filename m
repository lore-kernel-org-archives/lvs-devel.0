From: yangxingwu <xingwu.yang@gmail.com>
Subject: [PATCH nf-next v4] netfilter: ipvs: Fix reuse connection if RS weight is 0
Date: Sat, 30 Oct 2021 14:40:49 +0800
Message-ID: <20211030064049.9992-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=UjE5rqV9YkEJ/jh/9FOC8oevBVSTtNSrYDvMxA/WymY=;
        b=pBVae0l1mAb7sndDjkicYEsznprOmQKXS6Hyvgd6iZ2yGyVr6tGS8rIl/og97/laJF
         I95LHJeQR4UkLLOE6wiWX+FFRNzkS8SgDHfMXqaxAGyvnlSqDonSTf2w0rid0k2QZG13
         Ngb6hrFjZqgavSqA5Y/dkSeWL9FazihRDne/PtADOeV6yoUdHn1NHBKrDjnnSaSsWoDD
         wSLHG9DU9rmfWRyrPGUn8N3gFEGmUaTlpXWwyvYHSscvYYKNhMez5R72CK2rNZWusZ/7
         nbfuOcmoR7jYCVJj8/egg7T5/HxV5kV173OLVaHQtWKW0crlNL/Q5VnK3AoAJnMpCmWe
         eEaA==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: horms@verge.net.au
Cc: ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, corbet@lwn.net, yangxingwu <xingwu.yang@gmail.com>, Chuanqi Liu <legend050709@qq.com>

We are changing expire_nodest_conn to work even for reused connections when
conn_reuse_mode=0 but without affecting the controlled and persistent
connections during the graceful termination period while server is with
weight=0.

Fixes: d752c3645717 ("ipvs: allow rescheduling of new connections when port
reuse is detected")
Co-developed-by: Chuanqi Liu <legend050709@qq.com>
Signed-off-by: Chuanqi Liu <legend050709@qq.com>
Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
---
 Documentation/networking/ipvs-sysctl.rst |  3 +--
 net/netfilter/ipvs/ip_vs_core.c          | 12 ++++--------
 2 files changed, 5 insertions(+), 10 deletions(-)

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
index 128690c512df..ce6ceb55822b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1100,10 +1100,6 @@ static inline bool is_new_conn(const struct sk_buff *skb,
 static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
 					int conn_reuse_mode)
 {
-	/* Controlled (FTP DATA or persistence)? */
-	if (cp->control)
-		return false;
-
 	switch (cp->protocol) {
 	case IPPROTO_TCP:
 		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
@@ -1964,7 +1960,6 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 	int ret, pkts;
-	int conn_reuse_mode;
 	struct sock *sk;
 
 	/* Already marked as IPVS request or reply? */
@@ -2041,15 +2036,16 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
 			     ipvs, af, skb, &iph);
 
-	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
-	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
+	if (!iph.fragoffs && is_new_conn(skb, &iph) && cp && !cp->control) {
 		bool old_ct = false, resched = false;
+		int conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
 		    unlikely(!atomic_read(&cp->dest->weight))) {
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

