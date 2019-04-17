From: linmiaohe <linmiaohe@huawei.com>
Subject: [PATCH] ipvs:set sock send/receive buffer correctly
Date: Wed, 17 Apr 2019 17:18:17 +0800
Message-ID: <501e5522-1d69-7c67-a1bc-fd8502d3b5d1@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Mingfangsen <mingfangsen@huawei.com>, liujie165@huawei.com, linmiaohe@huawei.com

From: Jie Liu <liujie165@huawei.com>

If we set sysctl_wmem_max or sysctl_rmem_max larger than INT_MAX,
the send/receive buffer of sock will be an negative value. Same as
when the val is larger than INT_MAX/2.

Fixes: 1c003b1580e2 ("ipvs: wakeup master thread")
Reported-by: Qiang Ning <ningqiang1@huawei.com>
Reviewed-by: Miaohe Lin <linmiaohe@huawei.com>
Signed-off-by: Jie Liu <liujie165@huawei.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2526be6b3d90..c0e4cbed6e74 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1278,14 +1278,12 @@ static void set_sock_size(struct sock *sk, int mode, int val)
 	/* setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val)); */
 	lock_sock(sk);
 	if (mode) {
-		val = clamp_t(int, val, (SOCK_MIN_SNDBUF + 1) / 2,
-			      sysctl_wmem_max);
-		sk->sk_sndbuf = val * 2;
+		val = min_t(u32, val, sysctl_wmem_max);
+		sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
 	} else {
-		val = clamp_t(int, val, (SOCK_MIN_RCVBUF + 1) / 2,
-			      sysctl_rmem_max);
-		sk->sk_rcvbuf = val * 2;
+		val = min_t(u32, val, sysctl_rmem_max);
+		sk->sk_rcvbuf = max_t(int, val * 2, SOCK_MIN_RCVBUF);
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
 	}
 	release_sock(sk);
-- 
2.19.1


