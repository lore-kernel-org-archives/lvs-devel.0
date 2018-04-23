From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch nf] ipvs: initialize tbl->entries in ip_vs_lblc_init_svc()
Date: Mon, 23 Apr 2018 14:04:45 -0700
Message-ID: <20180423210445.18336-1-xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Tw1YFQj8mLL6HtY+dQI3kJu/f3dYbpY+NtGKAgAXxlI=;
        b=Ke3lK00vUEYOxALvfsgJh5TRjc/Fp3mJSityy3wS0WJIx4uCyudCLd8j/jVggBcOIz
         8iDKhZkJGEtXV5ND7M0GGQg703j2Qf0ofUPSKWEjo62OkR08xcWfcCFWZdg5khA9++tu
         GuhYG+8UKS5VqklsJZDrwBNwJ6NKNXm/qs7mBcxiabDXdn1OSVxUcwaWRx5C8Vn8bKVM
         O5iDDE5b5qKbh/ZtigSEymi7aPW2e/n9nPESzf3xAY2tFr2ZFz/UJAPXxvGQ5H2N31r9
         jvyToomsTb6Gf3eY9UlrBEo73/4ECnqvMGD0eN7gx/UrSgCdjoIXr/0gT9sbY/3bAYNn
         Xnlw==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>

Similarly, tbl->entries is not initialized after kmalloc(),
therefore causes an uninit-value warning in ip_vs_lblc_check_expire(),
as reported by syzbot.

Reported-by: <syzbot+3e9695f147fb529aa9bc@syzkaller.appspotmail.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 3057e453bf31..83918119ceb8 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -371,6 +371,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	tbl->counter = 1;
 	tbl->dead = false;
 	tbl->svc = svc;
+	atomic_set(&tbl->entries, 0);
 
 	/*
 	 *    Hook periodic timer for garbage collection
-- 
2.13.0

