From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-ipvs: Delete an unnecessary check before the function
 call "module_put"
Date: Thu, 02 Jul 2015 17:10:41 +0200
Message-ID: <55955471.9000501@users.sourceforge.net>
References: <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net> <546BA253.6030100@users.sourceforge.net> <20141119134040.GA12270@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20141119134040.GA12270@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Cc: LKML <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 2 Jul 2015 17:00:14 +0200

The module_put() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/netfilter/ipvs/ip_vs_sched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 199760c..e50221b 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -137,7 +137,7 @@ struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name)
 
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 {
-	if (scheduler && scheduler->module)
+	if (scheduler)
 		module_put(scheduler->module);
 }
 
-- 
2.4.5

