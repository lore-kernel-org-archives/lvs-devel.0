From: yangxingwu <xingwu.yang@gmail.com>
Subject: [PATCH] ipvs: remove unnecessary space
Date: Thu, 11 Jul 2019 11:39:59 +0800
Message-ID: <20190711033959.1593-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=M8wX1u1AyY8aIZh85CrgBQrNgkI4YoDiE4Y/ARBtWTI=;
        b=MQSWRWsAWJYvODOaMa5S5WYGn5WyApLDP13/bq1J3buPbjvqYJk04y5+eL1GBCPaEY
         VxMNOWWX/W8DqqO0Cycuruwb36aIFFnuV+tscB1DRqRuS9BkZh1rUkwn2yyJgDkC+pDu
         kx7fMeiWEn4hBGCAR+IMyee/am4cZRsk4uXbhxS7Yj6ONNrCqsd2KD+JtV7wkWRtueJj
         lwzKDnD6v1FnSawOO7c0h3P3kxy554wDZGoIiFrnWjoayKHK/WHfy5j+97z+IXEwhlO6
         HsYmw+95wRiHg6gkWWwdZL9X+7cHT6pmJwCjust5djfhvzIufdEyFICSR8cnVqESD0cd
         NgAQ==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, yangxingwu <xingwu.yang@gmail.com>

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

