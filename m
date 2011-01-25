From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 12:40:18 +0800
Message-ID: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:from:to:cc:subject:date:message-id:x-mailer;
        bh=pCblcEX2F2uxESz6Lv5tQYCE9ukoc/uC/eiZLzIJ/iw=;
        b=AuAOP8+fKOHGsfFktYUYpNKIoEFpTKup98th8/nDGLXK5hUp46kNTyhUrU3mAtZkqy
         PpgNNPwc32ipkLHf2R5B7vULl9R3qkV7Q3Jj0JWT4z612zI/KQ/Qvb67+Le8cQgC8wm6
         YcEbUbI5QnFXHmRbvwyiGxM1a2TJsW8N9vF9w=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

Fix compiler warnings when IP_VS_DBG() isn't defined.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c  |    4 +---
 3 files changed, 9 insertions(+), 3 deletions(-)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f36a84f..d889f4f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1894,9 +1894,7 @@ static int __net_init __ip_vs_init(struct net *net)
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
