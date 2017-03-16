From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/5] ipvs: remove an annoying printk in netns init
Date: Thu, 16 Mar 2017 13:43:11 +0100
Message-ID: <1489668195-15240-2-git-send-email-horms@verge.net.au>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1489668205; bh=wbb4OeyijVqUoGdKrfY6FOJmwWb5NwKz1MfhN7EzIEQ=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=pBSoJgW+pfKcfG7uRxETfGnzoZnsb1fRSvcaGhWLQvCI/EE+wUlF1ecpQctDw4+3o
         HDXpfZTKAUCqvcI/Z7Fxp8NyeTUkLeKExpYhA2qbqmyCfASRL+iCaSVgYQYl51lhaX
         smpo/IBJ8tVEXZVPCmWgR4zcsNVgzUldExMWFS+o=
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Cong Wang <xiyou.wangcong@gmail.com>, Simon Horman <horms@verge.net.au>

From: Cong Wang <xiyou.wangcong@gmail.com>

At most it is used for debugging purpose, but I don't think
it is even useful for debugging, just remove it.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index db40050f8785..9aaa49025cdc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2231,8 +2231,6 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_sync_net_init(ipvs) < 0)
 		goto sync_fail;
 
-	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
-			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
 /*
  * Error handling
-- 
2.7.0.rc3.207.g0ac5344

