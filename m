From: Li Qiong <liqiong@nfschina.com>
Subject: [PATCH v2] ipvs: add a 'default' case in do_ip_vs_set_ctl()
Date: Mon, 12 Dec 2022 15:43:51 +0800
Message-ID: <20221212074351.26440-1-liqiong@nfschina.com>
References: <272315c8-5e3b-e8ca-3c7f-68eccd0f2430@nfschina.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <272315c8-5e3b-e8ca-3c7f-68eccd0f2430@nfschina.com>
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>, Li Qiong <liqiong@nfschina.com>

It is better to return the default switch case with
'-EINVAL', in case new commands are added. otherwise,
return a uninitialized value of ret.

Signed-off-by: Li Qiong <liqiong@nfschina.com>
Reviewed-by: Simon Horman <horms@verge.net.au>
---
v2: Add 'default' case instead of initializing 'ret'.
---
 net/netfilter/ipvs/ip_vs_ctl.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 988222fff9f0..97f6a1c8933a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2590,6 +2590,11 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 		break;
 	case IP_VS_SO_SET_DELDEST:
 		ret = ip_vs_del_dest(svc, &udest);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		ret = -EINVAL;
+		break;
 	}
 
   out_unlock:
-- 
2.11.0

