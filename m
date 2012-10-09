From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: initialize returned data in do_ip_vs_get_ctl
Date: Tue,  9 Oct 2012 13:47:17 +0900
Message-ID: <1349758037-25317-2-git-send-email-horms@verge.net.au>
References: <1349758037-25317-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1349758037-25317-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Simon Horman <horms@verge.net.au>

From: Arnd Bergmann <arnd@arndb.de>

As reported by a gcc warning, the do_ip_vs_get_ctl does not initalize
all the members of the ip_vs_timeout_user structure it returns if
at least one of the TCP or UDP protocols is disabled for ipvs.

This makes sure that the data is always initialized, before it is
returned as a response to IPVS_CMD_GET_CONFIG or printed as a
debug message in IPVS_CMD_SET_CONFIG.

Without this patch, building ARM ixp4xx_defconfig results in:

net/netfilter/ipvs/ip_vs_ctl.c: In function 'ip_vs_genl_set_cmd':
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.udp_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.udp_timeout' was declared here
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_fin_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_fin_timeout' was declared here
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_timeout' was declared here

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7e7198b..c4ee437 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2589,6 +2589,8 @@ __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 	struct ip_vs_proto_data *pd;
 #endif
 
+	memset(u, 0, sizeof (*u));
+
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 	u->tcp_timeout = pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
@@ -2766,7 +2768,6 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		memset(&t, 0, sizeof(t));
 		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
-- 
1.7.10.4

