From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] IPVS: Change sock_create_kernel() to __sock_create()
Date: Sat, 22 Jan 2011 14:10:35 +1100
Message-ID: <1295665835-8708-3-git-send-email-horms@verge.net.au>
References: <1295665835-8708-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1295665835-8708-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

The recent netns changes omitted to change
sock_create_kernel() to __sock_create() in ip_vs_sync.c

The effect of this is that the interface will be selected in the
root-namespace, from my point of view it's a major bug.

Reported-by: Hans Schillstrom <hans@schillstrom.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d1adf98..d5a6e64 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1305,7 +1305,7 @@ static struct socket *make_send_sock(struct net *net)
 	int result;
 
 	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1351,7 +1351,7 @@ static struct socket *make_receive_sock(struct net *net)
 	int result;
 
 	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
-- 
1.7.2.3

