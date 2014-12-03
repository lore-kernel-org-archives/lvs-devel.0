From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ipvs: uninitialized data with IP_VS_IPV6
Date: Wed, 3 Dec 2014 13:12:13 +0300
Message-ID: <20141203101213.GC29583@mwanda>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

The app_tcp_pkt_out() function expects "*diff" to be set and ends up
using uninitialized data if CONFIG_IP_VS_IPV6 is turned on.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This bug is very old.

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 1d5341f..f93f974 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -183,6 +183,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	struct nf_conn *ct;
 	struct net *net;
 
+	*diff = 0;
+
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
 	 * so turn this into a no-op for IPv6 packets
@@ -191,8 +193,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 #endif
 
-	*diff = 0;
-
 	/* Only useful for established sessions */
 	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
 		return 1;
