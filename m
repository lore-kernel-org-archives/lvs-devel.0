From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 50/56] ipvs: Fix uninit-value in do_ip_vs_set_ctl()
Date: Sun, 18 Oct 2020 15:24:11 -0400
Message-ID: <20201018192417.4055228-50-sashal@kernel.org>
References: <20201018192417.4055228-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603049119;
        bh=JC0Y0QPLd4dv2Chd2uSnFM6k2pNn9+xYOM4MwLSX+Ps=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=I/UTwr1vfNZNZnCFBRSRBXlvnAUX8TmcEYTPukCr3taqO0HbZw3QiQvE9wMHzM8Hl
         ZocWgSgRefUzp0BFBoK0erbD4GsDGbwPOa/v52ZcsgYczL4Oe+Lru0OfZO52ZlhyUK
         hyB6RpHjkN7URlIecD5IjgQLA3cjRVoiw8C8IRtE=
In-Reply-To: <20201018192417.4055228-1-sashal@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Peilin Ye <yepeilin.cs@gmail.com>, syzbot+23b5f9e7caf61d9a3898@syzkaller.appspotmail.com, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: Peilin Ye <yepeilin.cs@gmail.com>

[ Upstream commit c5a8a8498eed1c164afc94f50a939c1a10abf8ad ]

do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
zero. Fix it.

Reported-by: syzbot+23b5f9e7caf61d9a3898@syzkaller.appspotmail.com
Link: https://syzkaller.appspot.com/bug?id=46ebfb92a8a812621a001ef04d90dfa459520fe2
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Peilin Ye <yepeilin.cs@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Reviewed-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c339b5e386b78..3ad1de081e3c7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2393,6 +2393,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		/* Set timeout values for (tcp tcpfin udp) */
 		ret = ip_vs_set_timeout(ipvs, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
+	} else if (!len) {
+		/* No more commands with len == 0 below */
+		ret = -EINVAL;
+		goto out_unlock;
 	}
 
 	usvc_compat = (struct ip_vs_service_user *)arg;
@@ -2469,9 +2473,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 	case IP_VS_SO_SET_DELDEST:
 		ret = ip_vs_del_dest(svc, &udest);
-		break;
-	default:
-		ret = -EINVAL;
 	}
 
   out_unlock:
-- 
2.25.1

