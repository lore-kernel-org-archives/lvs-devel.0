From: yue longguang <yuelongguang@gmail.com>
Subject: [PATCH] ipvs: adjust the debug order of src and dst
Date: Wed, 23 Sep 2020 14:06:25 +0800
Message-ID: <CAPaK2r921GtJVhwGKnZyCcQ1qkcWA=8TBWwNkW03R_=7TKzo6g@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=zhNLPdt3MABy9YGkQQhQ6/eOKIUXSwNa1xulGA5X34I=;
        b=lT7Ov8RiWALgWo1tGW58nncRiqRjEqVnH4H0E5Yobwk9FNfUMCkYZfDjZvfB5orEP1
         +YpacYIhhKTJNnlLPzzbUo0RfIaFLJhb/tDOA/EOCjfS7FGPsOEvvXv6k75sub9w73ng
         wXZETZ/7tVv61t4+eu088LGRF+qzVs+5exUq0Jxflj7BSbmE4BRCG86nliVX+LQ5fj37
         gCqfJIkkELSCCxlMtMl0W+Nu/LOjCHxxPoCDFFg+Eyifj8TyBN/C8r88oDWhxsf3Bg4q
         1hyaMUiWzqUKKCLf4I/EOiD38fvIR+mv6i81Th4zYDo4VoRru7GhoxG5NSmQTVE2WAVa
         wPBg==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, David Miller <davem@davemloft.net>, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>

From: ylg <bigclouds@163.com>

adjust the debug order of src and dst when tcp state changes

Signed-off-by: ylg <bigclouds@163.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c
b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dc2e7da2742a..6567eb45a234 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -548,10 +548,10 @@ set_tcp_state(struct ip_vs_proto_data *pd,
struct ip_vs_conn *cp,
       th->fin ? 'F' : '.',
       th->ack ? 'A' : '.',
       th->rst ? 'R' : '.',
-      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
-      ntohs(cp->dport),
       IP_VS_DBG_ADDR(cp->af, &cp->caddr),
       ntohs(cp->cport),
+      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
+      ntohs(cp->dport),
       tcp_state_name(cp->state),
       tcp_state_name(new_state),
       refcount_read(&cp->refcnt));
-- 
2.20.1 (Apple Git-117)
