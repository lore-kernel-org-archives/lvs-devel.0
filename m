From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 16/17] IPVS: ip_vs_ftp.c: local functions should not be exposed globally
Date: Wed,  2 May 2012 10:25:00 +0900
Message-ID: <1335921901-21284-17-git-send-email-horms@verge.net.au>
References: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, H Hartley Sweeten <hartleys@visionengravers.com>, H Hartley Sweeten <hsweeten@visionengravers.com>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>

From: H Hartley Sweeten <hartleys@visionengravers.com>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol 'ip_vs_ftp_init' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index debb8c7..091bec9 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -483,7 +483,7 @@ static struct pernet_operations ip_vs_ftp_ops = {
 	.exit = __ip_vs_ftp_exit,
 };
 
-int __init ip_vs_ftp_init(void)
+static int __init ip_vs_ftp_init(void)
 {
 	int rv;
 
-- 
1.7.9.5

