From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v2 4/5] ipvs: Lock socket before setting SK_CAN_REUSE
Date: Tue, 14 Jun 2016 15:24:21 +0100
Message-ID: <1465914262-30112-5-git-send-email-quentin@armitage.org.uk>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

When other settings are changed in the socket it is locked, so
lock the socket before setting SK_CAN_REUSE.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0ca937a..734335a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1539,7 +1539,9 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id, int ifi
 	}
 
 	/* it is equivalent to the REUSEADDR option in user-space */
+	lock_sock(sock->sk);
 	sock->sk->sk_reuse = SK_CAN_REUSE;
+	release_sock(sock->sk);
 	result = sysctl_sync_sock_size(ipvs);
 	if (result > 0)
 		set_sock_size(sock->sk, 0, result);
-- 
1.7.7.6

