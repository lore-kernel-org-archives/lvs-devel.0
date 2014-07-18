From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range check just before the check for equality
Date: Fri, 18 Jul 2014 18:33:58 +0300
Message-ID: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id;
        bh=w7RFpWuyOu0CQ1nkLwgx+Cgx6q1nvm7hyvZAZsyjYYk=;
        b=eQ9Pw0M80y6aWW7mZa0t6QIMYxdHSZJQb+yRgXED1+9Xyxi5Yr+TadHs47ZtMZnBOW
         m4+9Nika+aKZk97IQvL2VojmvMQ2JuXmW8hk+0xiqsKmwh6+Trl+d0RahOkTkd6hY4VF
         9pPu9LAccRoncMIM76V/40rD/nheNdyvB2u0hyzURU0/7RYsptpXrRHW2IxcWXOdKx/J
         CsgIVP/Tdxkl8iby5vAw4PP3VV1ddaEK7QlE0gTlRNJdvgXiD83+fLmKjhlwOcOVSbOv
         0GSzjvfVJWYyWvhIbRc1xVvwl1cWOeuxlPta1ULZEykSvD2jalKXofxI9puYou/DnVkf
         8Rcg==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: dcb314@hotmail.com, davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org, ja@ssi.bg, horms@verge.net.au, wensong@linux-vs.org, Andrey Utkin <andrey.krieger.utkin@gmail.com>

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=80601
Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 581a658..4ed7b59 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2338,8 +2338,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
 		return -EINVAL;
-	if (len < 0 || len >  MAX_ARG_LEN)
-		return -EINVAL;
 	if (len != set_arglen[SET_CMDID(cmd)]) {
 		pr_err("set_ctl: len %u != %u\n",
 		       len, set_arglen[SET_CMDID(cmd)]);
-- 
1.8.5.5
