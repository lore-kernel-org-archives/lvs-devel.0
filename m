From: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: [PATCH net-next 4/6] net: Convert ipvs_core_ops
Date: Thu, 15 Mar 2018 12:11:25 +0300
Message-ID: <152110508554.28582.4604877155259248267.stgit@localhost.localdomain>
References: <152110491273.28582.13804059107038714030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
	s=selector1; h=From:Date:Subject:Message-ID:Content-Type:MIME-Version; 
	bh=2F3jL+Q9OE3eTQvLD8lWKxN7iYOE4SzaWz5FQ02o7vU=;
	b=hKu4Ynqv5iGpq62nfZ0I5JcRMfV/Z/ha9Db4sRhHakoKCyty+8kecMkXu1xOe2V4X43AfwmeBQan2dcnoFwqC5yW8rHiTdMuWr5ZlO2hDWSJF2N9epIlxHLdxItqXRFUjJG8sj/+acFr6kEiVOIGBt0uaqcZeqtTb2rD8HbISIU=
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

These pernet_operations register and unregister nf hooks,
/proc entries, sysctl, percpu statistics. There are several
global lists, and the only list modified without exclusive
locks is ip_vs_conn_tab in ip_vs_conn_flush(). We iterate
the list and force the timers expire at the moment. Since
there were possible several timer expirations before this
patch, and since they are safe, the patch does not invent
new parallelism of their destruction. These pernet_operations
look safe to be converted.

Signed-off-by: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
---
 net/netfilter/ipvs/ip_vs_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5f6f73cf2174..c5d16e2bc8e2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2289,6 +2289,7 @@ static struct pernet_operations ipvs_core_ops = {
 	.exit = __ip_vs_cleanup,
 	.id   = &ip_vs_net_id,
 	.size = sizeof(struct netns_ipvs),
+	.async = true,
 };
 
 static struct pernet_operations ipvs_core_dev_ops = {
