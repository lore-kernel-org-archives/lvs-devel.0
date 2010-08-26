From: Simon Horman <horms@verge.net.au>
Subject: [patch net-next 4/4] [PATCH net-next-2.6] ipvs: switch to GFP_KERNEL allocations
Date: Thu, 26 Aug 2010 21:54:31 +0900
Message-ID: <20100826125727.437158980@vergenet.net>
References: <20100826125427.056491061@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-switch-to-GFP_KERNEL-allocations.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>

Switch from GFP_ATOMIC allocations to GFP_KERNEL ones in
ip_vs_add_service() and ip_vs_new_dest(), as we hold a mutex and are
allowed to sleep in this context.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0f0c079..896f34b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -843,7 +843,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 			return -EINVAL;
 	}
 
-	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
+	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
 	if (dest == NULL) {
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
@@ -1177,7 +1177,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 #endif
 
-	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
+	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
 		ret = -ENOMEM;


