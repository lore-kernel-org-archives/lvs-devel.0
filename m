From: "longguang.yue" <bigclouds@163.com>
Subject: [PATCH v6] ipvs: adjust the debug info in function set_tcp_state
Date: Sun,  4 Oct 2020 23:18:57 +0800
Message-ID: <20201004151857.83621-1-bigclouds@163.com>
References: <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=DRj++
        rTYnioE6DyHj9kP5YSKC9vzNZX5bcQm6i2E0k0=; b=lIvvRuLnVPzdgx0unGR4l
        AyBs6OdzBg0o2cBRTYuE+MGPwCyyCaSj/rwb/gBLdM51xmnRPPTn8TivttUvw1dq
        yTk+c6o9eAOkr97eIElwXCqRZiu9HwOwcyHau0Q2j3XukMsCPEty579ubCPINqcb
        65bfRoeduc5rt9/UV1WNeo=
In-Reply-To: <alpine.LFD.2.23.451.2009300803110.6056@ja.home.ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: ja@ssi.bg, kuba@kernel.org, wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, yuelongguang@gmail.com, "longguang.yue" <bigclouds@163.com>

Outputting client,virtual,dst addresses info when tcp state changes,
which makes the connection debug more clear

---
v5,v6: fix indentation and add changelogs
v3,v4: fix checkpatch
v2: IP_VS_DBG_BUF outputs src,virtual,dst of ip_vs_conn
v1: fix the inverse of src and dst address

Signed-off-by: longguang.yue <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dc2e7da2742a..7da51390cea6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	if (new_state != cp->state) {
 		struct ip_vs_dest *dest = cp->dest;
 
-		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
-			      "%s:%d state: %s->%s conn->refcnt:%d\n",
+		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
+			      "d:%s:%d state: %s->%s conn->refcnt:%d\n",
 			      pd->pp->name,
 			      ((state_off == TCP_DIR_OUTPUT) ?
 			       "output " : "input "),
@@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			      th->fin ? 'F' : '.',
 			      th->ack ? 'A' : '.',
 			      th->rst ? 'R' : '.',
-			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
-			      ntohs(cp->dport),
 			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
 			      ntohs(cp->cport),
+			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+			      ntohs(cp->vport),
+			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
+			      ntohs(cp->dport),
 			      tcp_state_name(cp->state),
 			      tcp_state_name(new_state),
 			      refcount_read(&cp->refcnt));
-- 
2.20.1 (Apple Git-117)


