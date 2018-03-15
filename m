From: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: [PATCH net-next 1/6] net: Convert l2tp_net_ops
Date: Thu, 15 Mar 2018 12:10:57 +0300
Message-ID: <152110505785.28582.3727938208418496683.stgit@localhost.localdomain>
References: <152110491273.28582.13804059107038714030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
	s=selector1; h=From:Date:Subject:Message-ID:Content-Type:MIME-Version; 
	bh=KtkFbtU5ZxgvJ+kDUy1GSJ2R5JZ8VUOvXqKoWpp+w/I=;
	b=HOfoePEjhLv6Xk/00CwsFwKM4elnbbeieXl7FYbx687vh7JOkVq7MyUxVkjQ8tF34PZ0IlYFPrSRB3XZ16Dllu1ZZqb6rCR5rsAadEMShUXqg1VnxRauFxQHocqtgK0CTm3i+8xf+emla8V7OlsGPjnpjjN6zsMGWSLBADfp9Dc=
In-Reply-To: <152110491273.28582.13804059107038714030.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wensong-ud5FBsm0p/xg9hUCZPvPmw@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, ja-FgGsKACvmQM@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org, g.nault-pHk1y4uTXVDytLWWfqlThQ@public.gmane.org, jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org, lorenzo.bianconi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, amine.kherbouche-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org

Init method is rather simple. Exit method queues del_work
for every tunnel from per-net list. This seems to be safe
to be marked async.

Signed-off-by: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
---
 net/l2tp/l2tp_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 83421c6f0bef..189a12a5e4ac 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1787,6 +1787,7 @@ static struct pernet_operations l2tp_net_ops = {
 	.exit = l2tp_exit_net,
 	.id   = &l2tp_net_id,
 	.size = sizeof(struct l2tp_net),
+	.async = true,
 };
 
 static int __init l2tp_init(void)
