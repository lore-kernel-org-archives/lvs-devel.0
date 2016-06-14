From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 3/5] ipvs: Don't check result < 0 after setting result = 0
Date: Tue, 14 Jun 2016 02:43:31 +0100
Message-ID: <1465868613-26146-4-git-send-email-quentin@armitage.org.uk>
References: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
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
 net/netfilter/ipvs/ip_vs_sync.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 3181fd0..29d73d8 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1497,13 +1497,13 @@ static struct socket *make_send_sock(struct netns_ipvs *ipvs, int id, struct net
 			  ipvs->mcast_ifn, &addr);
 
 		result = bind_mcastif_addr(sock, dev);
+		if (result < 0) {
+			pr_err("Error binding address of the mcast interface\n");
+			goto error;
+		}
 	}
 	else
 		result = 0;
-	if (result < 0) {
-		pr_err("Error binding address of the mcast interface\n");
-		goto error;
-	}
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->mcfg, id);
 	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
-- 
1.7.7.6

