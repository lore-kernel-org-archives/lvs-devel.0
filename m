From: Li Qiong <liqiong@nfschina.com>
Subject: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri,  2 Dec 2022 11:25:11 +0800
Message-ID: <20221202032511.1435-1-liqiong@nfschina.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>, Li Qiong <liqiong@nfschina.com>

The 'ret' should need to be initialized to 0, in case
return a uninitialized value because no default process
for "switch (cmd)".

Signed-off-by: Li Qiong <liqiong@nfschina.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 988222fff9f0..4b20db86077c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2456,7 +2456,7 @@ static int
 do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 {
 	struct net *net = sock_net(sk);
-	int ret;
+	int ret = 0;
 	unsigned char arg[MAX_SET_ARGLEN];
 	struct ip_vs_service_user *usvc_compat;
 	struct ip_vs_service_user_kern usvc;
-- 
2.11.0

