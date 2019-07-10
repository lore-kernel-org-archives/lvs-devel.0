From: yangxingwu <xingwu.yang@gmail.com>
Subject: [PATCH] ipvs: remove unnecessary space
Date: Wed, 10 Jul 2019 15:45:52 +0800
Message-ID: <20190710074552.74394-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rV8XY23YcgGtmJ7pWfTCdKdGdKOHA29Wd8XEtkDo6dw=;
        b=rk0yxVoRI1NSXQaTxJGnXTVDTyoh73Qr15nBHk581jpDGshkxfpn3RztceSyQs+tHe
         ti7BzzdaHXnGOAGg6mqaBJ1SAJHD3e6CdgRxUu5ixvnbeMoOmTLMD9XC6iTWrjA6F+08
         WKInMtFYRWZALcgK61SSZxrpio9iP4ILgs+n8XyfIl4/ijmVe2vKFVBz1EhdmKo7KRMx
         genAn4wRFNkS02wbrK1nV8BTUxA/GLNMlgzTkAJyRvlOY05RHzqBLzUZl5A8vk4jqgvz
         q4QPtcHkt2xMb3JPCE4OfqRs1uXAXn3kU5N3dvXfNh3+iHcvizhBiRoXII9PboSmzdrW
         +bsw==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, yangxingwu <xingwu.yang@gmail.com>

this patch removes the extra space.

Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 94d9d34..98e358e 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -174,8 +174,8 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
 		return 0;
 	}
 
-	table =  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
-			 sizeof(unsigned long), GFP_KERNEL);
+	table =	kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
+			sizeof(unsigned long), GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
 
-- 
1.8.3.1

