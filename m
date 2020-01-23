From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ipvs: fix spelling mistake "to" -> "too"
Date: Thu, 23 Jan 2020 00:43:28 +0000
Message-ID: <20200123004328.2833127-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There is a spelling mistake in a IP_VS_ERR_RL message. Fix it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8dc892a9dc91..605e0f68f8bd 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1239,7 +1239,7 @@ static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
 
 			p = msg_end;
 			if (p + sizeof(s->v4) > buffer+buflen) {
-				IP_VS_ERR_RL("BACKUP, Dropping buffer, to small\n");
+				IP_VS_ERR_RL("BACKUP, Dropping buffer, too small\n");
 				return;
 			}
 			s = (union ip_vs_sync_conn *)p;
-- 
2.24.0

