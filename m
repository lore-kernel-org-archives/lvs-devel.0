From: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: [PATCH net-next 2/6] net: Convert mpls_net_ops
Date: Thu, 15 Mar 2018 12:11:06 +0300
Message-ID: <152110506653.28582.3966480691261586346.stgit@localhost.localdomain>
References: <152110491273.28582.13804059107038714030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
	s=selector1; h=From:Date:Subject:Message-ID:Content-Type:MIME-Version; 
	bh=3Ks38T4Bbu2WQgU3uTIcgX7B2IJ3Z6N4P+cuqPt2awY=;
	b=YE40r3ts7SyWPKD8EwhuGqKZrKYITRf1mEbAtMXYJbSQn8uv6jpuhxNkisnVlL7fSmQ2i63j1ugPrjfsV337+cYBZowgR16M0J90WxqFWdDoamJcv8a6FodKfM1wE+jMXVmqDg3+DtRWQjKEgcLieXFAyReHJYTCfe7Tr5bTBeQ=
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

These pernet_operations register and unregister sysctl table.
Exit methods frees platform_labels from net::mpls::platform_label.
Everything is per-net, and they looks safe to be marked async.

Signed-off-by: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
---
 net/mpls/af_mpls.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7a4de6d618b1..d4a89a8be013 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -2488,6 +2488,7 @@ static void mpls_net_exit(struct net *net)
 static struct pernet_operations mpls_net_ops = {
 	.init = mpls_net_init,
 	.exit = mpls_net_exit,
+	.async = true,
 };
 
 static struct rtnl_af_ops mpls_af_ops __read_mostly = {
