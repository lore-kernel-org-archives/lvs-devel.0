From: yue longguang <yuelongguang@gmail.com>
Subject: [PATCH v3] ipvs: adjust the debug info in function set_tcp_state
Date: Fri, 25 Sep 2020 20:09:30 +0800
Message-ID: <CAPaK2r8cTOq5rEKZezse+wF0f9NierUabqcr31b46wJx43werQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=KuEuCrzxDVDfRygUDBAUCymQMtipb7e5y0kfRWS118o=;
        b=PrLIhOjV/Ysvo9D/s4gJeAknBbeqOv5C0zr7mpbfgit0w3HM32RJo/OpqGSPBRRrGP
         mmdSAdQva/GSIARGGx0bscS1ZIaGLNpcEcYtRv/bJbanJzwOlZkLHGdaOP4PoZcj9zkn
         cqHhUQFMauzjeIzRmXkYXVsjl1p18TAj0Q26uQj6SZFWysk6HipW4Q+s3SrXV+ttglze
         Ad05DQD71YW31pC82ykLQhLi84es2hMXY8JT3DN3aZnAfMzS5yyT5oBQqYfjHTHlCJCo
         smj1fj7pR7CndW2btbyfYbhlOYXdD1fKefRCFLmt8mQSnJ/UjWEK0o+6Mv7wrODyaZ8P
         Sr2g==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, Julian Anastasov <ja@ssi.bg>, wensong@linux-vs.org, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, David Miller <davem@davemloft.net>, kuba@kernel.org, lvs-devel@vger.kernel.org

From: "longguang.yue" <yuelongguang@gmail.com>

   outputting client,virtual,dst addresses info when tcp state changes,
   which makes the connection debug more clear

Signed-off-by: longguang.yue <yuelongguang@gmail.com>
---
net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c
b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dc2e7da2742a..7da51390cea6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct
ip_vs_conn *cp,
if (new_state != cp->state) {
struct ip_vs_dest *dest = cp->dest;

- IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
-       "%s:%d state: %s->%s conn->refcnt:%d\n",
+ IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
+       "d:%s:%d state: %s->%s conn->refcnt:%d\n",
      pd->pp->name,
      ((state_off == TCP_DIR_OUTPUT) ?
       "output " : "input "),
@@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd,
struct ip_vs_conn *cp,
      th->fin ? 'F' : '.',
      th->ack ? 'A' : '.',
      th->rst ? 'R' : '.',
-       IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
-       ntohs(cp->dport),
      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
      ntohs(cp->cport),
+       IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
+       ntohs(cp->vport),
+       IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
+       ntohs(cp->dport),
      tcp_state_name(cp->state),
      tcp_state_name(new_state),
      refcount_read(&cp->refcnt));
-- 
2.20.1 (Apple Git-117)
