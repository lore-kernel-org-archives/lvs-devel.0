From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch nf] ipvs: initialize tbl->entries after allocation
Date: Mon, 23 Apr 2018 13:53:41 -0700
Message-ID: <20180423205341.13142-1-xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=R+dJr5g4SUMwgnuPLLZS7MrlsSoSkxBZ1XeFnhbXIpo=;
        b=kwwrsRJBgAUGv+uOeKf3/PTWON21KV90Dbp4EmweNo0k0NxbMCZiX6A+rAgVosDmWt
         qznT/1uzObDWOCLaYbvbK5ETnXCeZ88ulQAn0pDtEcjCGD2iLUrCVLF6+4bbCzFhKJfh
         M/mLZJbRhxCGuYhb+YSVRQ2vXWLgYRWiM8pMh21CultMzfQpuobKJaHy7C0DR5RGbV4Z
         hbIvAZ+cOJmC6mTlKfxNIkWZdDR/U3XNtDP+Kd+ttfNatK/0zQALojD8+2Xp4dKvbsns
         hVj9iISxcedEOn8jcUaRrcoa3YObVg2jxgLlPS1yglJlaqMI1CpUZS24xm2c4vAunoUf
         xMkQ==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>

tbl->entries is not initialized after kmalloc(), therefore
causes an uninit-value warning in ip_vs_lblc_check_expire()
as reported by syzbot.

Reported-by: <syzbot+3dfdea57819073a04f21@syzkaller.appspotmail.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 92adc04557ed..bc2bc5eebcb8 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -534,6 +534,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	tbl->counter = 1;
 	tbl->dead = false;
 	tbl->svc = svc;
+	atomic_set(&tbl->entries, 0);
 
 	/*
 	 *    Hook periodic timer for garbage collection
-- 
2.13.0

