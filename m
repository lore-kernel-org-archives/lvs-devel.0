From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 2/2] ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup}
Date: Wed,  7 Oct 2015 14:23:23 +0900
Message-ID: <1444195403-4288-3-git-send-email-horms@verge.net.au>
References: <1444195403-4288-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1444195403-4288-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

If CONFIG_PROC_FS is undefined then the arguments of proc_create()
and remove_proc_entry() are unused. As a result the net variables of
ip_vs_conn_net_{init,cleanup} are unused.

net/netfilter/ipvs//ip_vs_conn.c: In function =E2=80=98ip_vs_conn_net_i=
nit=E2=80=99:
net/netfilter/ipvs//ip_vs_conn.c:1350:14: warning: unused variable =E2=80=
=98net=E2=80=99 [-Wunused-variable]
net/netfilter/ipvs//ip_vs_conn.c: In function =E2=80=98ip_vs_conn_net_c=
leanup=E2=80=99:
net/netfilter/ipvs//ip_vs_conn.c:1361:14: warning: unused variable =E2=80=
=98net=E2=80=99 [-Wunused-variable]
=2E..

Resolve this by dereferencing net as needed rather than storing it
in a variable.

=46ixes: 3d99376689ee ("ipvs: Pass ipvs not net into ip_vs_control_net_=
(init|cleanup)")
Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs=
_conn.c
index d1d168c7fc68..85ca189bdc3d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1347,23 +1347,20 @@ flush_again:
  */
 int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net =3D ipvs->net;
-
 	atomic_set(&ipvs->conn_count, 0);
=20
-	proc_create("ip_vs_conn", 0, net->proc_net, &ip_vs_conn_fops);
-	proc_create("ip_vs_conn_sync", 0, net->proc_net, &ip_vs_conn_sync_fop=
s);
+	proc_create("ip_vs_conn", 0, ipvs->net->proc_net, &ip_vs_conn_fops);
+	proc_create("ip_vs_conn_sync", 0, ipvs->net->proc_net,
+		    &ip_vs_conn_sync_fops);
 	return 0;
 }
=20
 void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net =3D ipvs->net;
-
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(ipvs);
-	remove_proc_entry("ip_vs_conn", net->proc_net);
-	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
+	remove_proc_entry("ip_vs_conn", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs_conn_sync", ipvs->net->proc_net);
 }
=20
 int __init ip_vs_conn_init(void)
--=20
2.1.4
