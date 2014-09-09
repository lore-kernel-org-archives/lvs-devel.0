From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 05/20] ipvs: prevent mixing heterogeneous pools and synchronization
Date: Tue, 9 Sep 2014 16:40:24 -0700
Message-ID: <1410306039-2977-6-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=azmpI9t7HjDBM9dCNmIoTxJ2Mn9C/1k01PxVrluUH7E=;
 b=AvZomQ7ityuFnh218KGytnSR2nquvu3n5vPMtJeDGsTetvUYQGrqi/UBxj0vvjaUqTFP
 08yHlYWoqB2OXq8BNkU9Ob78HygT08ku4KnZ+mAPaJoGBAR6VU4MVBl3iNjhWhIcLzTd
 8oxeIwayxYoHkubZj1zApgSmNEV/D9CvO1E= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

The synchronization protocol is not compatible with heterogeneous pools, so
we need to verify that we're not turning both on at the same time.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h            |  4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c | 15 +++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7600dbe..576d7f0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -990,6 +990,10 @@ struct netns_ipvs {
 	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	/* net name space ptr */
 	struct net		*net;            /* Needed by timer routines */
+	/* Number of heterogeneous destinations, needed because
+	 * heterogeneous are not supported when synchronization is
+	 * enabled */
+	unsigned int		mixed_address_family_dests;
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 33d04ee..175945f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -779,6 +779,12 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
 
+	/* We cannot modify an address and change the address family */
+	BUG_ON(!add && udest->af != dest->af);
+
+	if (add && udest->af != svc->af)
+		ipvs->mixed_address_family_dests++;
+
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
 	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
@@ -1061,6 +1067,9 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
+	if (dest->af != svc->af)
+		net_ipvs(svc->net)->mixed_address_family_dests--;
+
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
 
@@ -3245,6 +3254,12 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;
 
+	/* The synchronization protocol is incompatible with mixed family
+	 * services
+	 */
+	if (net_ipvs(net)->mixed_address_family_dests > 0)
+		return -EINVAL;
+
 	return start_sync_thread(net,
 				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
 				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
-- 
1.8.1

