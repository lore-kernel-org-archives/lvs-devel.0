From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: Free resources on module removal
Date: Fri, 22 Jul 2011 09:18:40 +0900
Message-ID: <1311293920-1983-2-git-send-email-horms@verge.net.au>
References: <1311293920-1983-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1311293920-1983-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Dave Jones <davej@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Huajun Li <huajun.li.lee@gmail.com>, Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>

This resolves a panic on module removal.

Reported-by: Dave Jones <davej@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 699c79a..a178cb3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3771,6 +3771,7 @@ err_sock:
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
+	unregister_netdevice_notifier(&ip_vs_dst_notifier);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
-- 
1.7.5.4

