From: Peilin Ye <yepeilin.cs@gmail.com>
Subject: [Linux-kernel-mentees] [PATCH net] ipvs: Fix uninit-value in do_ip_vs_set_ctl()
Date: Mon, 10 Aug 2020 18:07:03 -0400
Message-ID: <20200810220703.796718-1-yepeilin.cs@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3ZbMbahrrNkhzXHol1Zr0zVJbIcJ6vrUXkY246I6Gww=;
        b=elE8gXGFCgxGb+WPV22Nwena1f+CuNWdGDIMre+3IYPlJ/dgFxnsv/Nif8jf/9So9g
         Jfq6u/NSq38DCrgFyDUCnVrtGGmwME440my9SPaB2eKBvqacSCkWOroSb302H/A+6/NC
         aFFqf3hnQoBHQs4bfAIRRTwhGKzSgh+tqHkZiR1s4ZRMDUflziWLspPza1JmWtc5x5BH
         hu4Tzumv1CTdCpFez/JNDr9TK5nh5chZTSr0bzMdsoAMlEO6Hm717BFu50YmP2Huc7uT
         O71KhjXh8z3c2xG1Y5UMQPdQCh0Jh59+6yuOQHl1iV7kGHoV8J8a70s1YKxmLmGKTxYf
         aS6A==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: Peilin Ye <yepeilin.cs@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org

do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
zero. Fix it.

Reported-and-tested-by: syzbot+23b5f9e7caf61d9a3898@syzkaller.appspotmail.com
Link: https://syzkaller.appspot.com/bug?id=46ebfb92a8a812621a001ef04d90dfa459520fe2
Signed-off-by: Peilin Ye <yepeilin.cs@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 412656c34f20..c050b6a42786 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2418,7 +2418,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	struct net *net = sock_net(sk);
 	int ret;
-	unsigned char arg[MAX_SET_ARGLEN];
+	unsigned char arg[MAX_SET_ARGLEN] = {};
 	struct ip_vs_service_user *usvc_compat;
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
-- 
2.25.1

