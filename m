From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH net-next v4 2/3] ipvs: Don't check result < 0 after setting result = 0
Date: Thu, 16 Jun 2016 08:00:26 +0100
Message-ID: <1466060427-12988-2-git-send-email-quentin@armitage.org.uk>
References: <Message-id: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
 <1466060427-12988-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466060427-12988-1-git-send-email-quentin@armitage.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

Move the block testing result < 0 to avoid the test immediately
after setting result = 0

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index fbc5ba4..2be99b2 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1496,13 +1496,14 @@ static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id,
 	if (result > 0)
 		set_sock_size(sock->sk, 1, result);
 
-	if (AF_INET == ipvs->mcfg.mcast_af)
+	if (ipvs->mcfg.mcast_af == AF_INET) {
 		result = bind_mcastif_addr(sock, dev);
-	else
+		if (result < 0) {
+			pr_err("Error binding address of mcast interface\n");
+			goto error;
+		}
+	} else {
 		result = 0;
-	if (result < 0) {
-		pr_err("Error binding address of the mcast interface\n");
-		goto error;
 	}
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->mcfg, id);
-- 
1.7.7.6

