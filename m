From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/7] ipvs: fix error return code
Date: Wed, 29 Aug 2012 18:49:11 +0200
Message-ID: <1346258957-7649-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1346258957-7649-1-git-send-email-Julia.Lawall@lip6.fr>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1346258957-7649-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: kernel-janitors@vger.kernel.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Initialize return variable before exiting on an error path.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}

// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 3c60137..767cc12 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1171,8 +1171,10 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		goto out_err;
 	}
 	svc->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!svc->stats.cpustats)
+	if (!svc->stats.cpustats) {
+		ret = -ENOMEM;
 		goto out_err;
+	}
 
 	/* I'm the first user of the service */
 	atomic_set(&svc->usecnt, 0);

