From: yangxingwu <xingwu.yang@gmail.com>
Subject: [PATCH] ipvs: remove unnecessary space
Date: Fri, 12 Jul 2019 21:07:21 +0800
Message-ID: <20190712130721.7168-1-xingwu.yang@gmail.com>
References: <80a4e132f3be48899904eccdc023f5c53229840b.camel@perches.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=M8wX1u1AyY8aIZh85CrgBQrNgkI4YoDiE4Y/ARBtWTI=;
        b=rHEVvDNmjPN89MNTOPTSN3d/nJEc78QJ8AYNecX5Bs+ZA/Q004H178HvUmWoI/vgA0
         GBEfWvjsCj4aGjGBm8uyQ7jsVLTdZcXbZUvRU5P8sruoji9Sb4qg/Z7NiJICtnpclT7W
         T8YAR54AWq1g+hvk0GeXSi/hhtl+XsJbZaWhS1tCw0dW2OKqEbmpGIVCIpW5FNs/7KJY
         WdsDRHhxgOJmLtwUYPAM1HBtYXaB8l66Nvsn7Eghe8itAoGMM65i37/Kc1bLc2bsCK5h
         9+DvE7ZXQJV0sV5bDMAG2Su6TPAKs7tXjIWm8F0dvrWMsL4kudNNmddXsFWMrxcI/ajg
         NKOg==
In-Reply-To: <80a4e132f3be48899904eccdc023f5c53229840b.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, joe@perches.com, yangxingwu <xingwu.yang@gmail.com>

this patch removes the extra space and use bitmap_zalloc instead

Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 94d9d34..3229867 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -174,8 +174,7 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
 		return 0;
 	}
 
-	table =  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
-			 sizeof(unsigned long), GFP_KERNEL);
+	table = bitmap_zalloc(IP_VS_MH_TAB_SIZE, GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
 
-- 
1.8.3.1

