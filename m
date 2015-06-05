From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ipvs: prevent some underflows
Date: Fri, 5 Jun 2015 12:33:15 +0300
Message-ID: <20150605093315.GD24871@mwanda>
Mime-Version: 1.0
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

Quite a few drivers allow very low settings for dev->mtu.  My static
checker complains this could cause some underflow problems when we do
the subtractions in set_sync_mesg_maxlen().

I don't know that it's harmful necessarily, but it seems like an easy
thing to prevent the underflows.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Please review this one carefully, because I'm not very sure of myself
here.

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b08ba95..b4e148b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1352,7 +1352,7 @@ static int set_sync_mesg_maxlen(struct net *net, int sync_state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct net_device *dev;
-	int num;
+	unsigned int num;
 
 	if (sync_state == IP_VS_STATE_MASTER) {
 		dev = __dev_get_by_name(net, ipvs->master_mcast_ifn);
@@ -1363,7 +1363,8 @@ static int set_sync_mesg_maxlen(struct net *net, int sync_state)
 		       sizeof(struct udphdr) -
 		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
 		ipvs->send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
-			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
+			SIMPLE_CONN_SIZE * min_t(uint, num,
+						 MAX_CONNS_PER_SYNCBUFF);
 		IP_VS_DBG(7, "setting the maximum length of sync sending "
 			  "message %d.\n", ipvs->send_mesg_maxlen);
 	} else if (sync_state == IP_VS_STATE_BACKUP) {
@@ -1371,8 +1372,11 @@ static int set_sync_mesg_maxlen(struct net *net, int sync_state)
 		if (!dev)
 			return -ENODEV;
 
-		ipvs->recv_mesg_maxlen = dev->mtu -
-			sizeof(struct iphdr) - sizeof(struct udphdr);
+		if (dev->mtu < sizeof(struct iphdr) + sizeof(struct udphdr))
+			ipvs->recv_mesg_maxlen = 0;
+		else
+			ipvs->recv_mesg_maxlen = dev->mtu -
+				sizeof(struct iphdr) - sizeof(struct udphdr);
 		IP_VS_DBG(7, "setting the maximum length of sync receiving "
 			  "message %d.\n", ipvs->recv_mesg_maxlen);
 	}
