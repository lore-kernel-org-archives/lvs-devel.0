From: trix@redhat.com
Subject: [PATCH] ipvs: add prameter name to ip_vs_enqueue_expire_nodest_conns
Date: Tue, 21 Jul 2020 13:47:20 -0700
Message-ID: <20200721204720.7818-1-trix@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1595364449;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=vJQdVCFU+bbg1bLHFMdzaVvzuHDTychMnPcWRjdwPXE=;
        b=aGpT7+8865ZkJrF7639b2J6TB+bfAMJ55LoqJ6RUbGDorrqpXL4eRtkx7NTT7Cx8oASjb2
        LYojKepss3wB9ZdoqgOQXAc2UtNzr/nNZXkgPVSTefMB1Us++y2Ew7NUXEBtay/ZJj9DG2
        FrE7a587WsQ5CZc78K8aBOnVHr6bBtc=
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kuba@kernel.org, pablo@netfilter.org, kim.andrewsy@gmail.com
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Tom Rix <trix@redhat.com>

From: Tom Rix <trix@redhat.com>

Compile error here

In file included from net/netfilter/ipvs/ip_vs_conn.c:37:
ip_vs.h: In function ‘ip_vs_enqueue_expire_nodest_conns’:
ip_vs.h:1536:54: error: parameter name omitted

So add parameter name

Fixes: 04231e52d355 ("ipvs: queue delayed work to expire no destination connections if expire_nodest_conn=1")

Signed-off-by: Tom Rix <trix@redhat.com>
---
 include/net/ip_vs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 91a9e1d590a6..9a59a33787cb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1533,7 +1533,7 @@ static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs)
 
 void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs);
 #else
-static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
+static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs) {}
 #endif
 
 #define IP_VS_DFWD_METHOD(dest) (atomic_read(&(dest)->conn_flags) & \
-- 
2.18.1

