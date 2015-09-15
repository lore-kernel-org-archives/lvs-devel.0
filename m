From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs-next,v2] ipvs: add sysctl to ignore tunneled packets
Date: Mon, 14 Sep 2015 23:23:05 -0700
Message-ID: <1442298185-1495819-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=zL3O7jIGJUm+uVhmvTxd6g5atOZukp8F/37yEs/CKXY=;
 b=EQ5j3L5xRQ40OXKHQYIE/sE0fxMVWPT3QAXiPH/Fqf7OWADg86SJou7b0Q7MbgYJiDWW
 9IMt4gy9nTGglbxW9i331auSYVRXIHfHcIpLTM7m1elL/TPbn7e4dSmq+68hmkpB3UJN
 WVjPyhvzFsOdL+MolTGMq1JWqU5ElrGCeCg= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This is a way to avoid nasty routing loops when multiple ipvs instances can
forward to eachother.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 Documentation/networking/ipvs-sysctl.txt | 10 ++++++++++
 include/net/ip_vs.h                      | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c          | 10 +++++++++-
 net/netfilter/ipvs/ip_vs_ctl.c           |  7 +++++++
 4 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 3ba7095..e6b1c02 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -157,6 +157,16 @@ expire_quiescent_template - BOOLEAN
 	persistence template if it is to be used to schedule a new
 	connection and the destination server is quiescent.
 
+ignore_tunneled - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	If set, ipvs will set the ipvs_property on all packets which are of
+	unrecognized protocols.  This prevents us from routing tunneled
+	protocols like ipip, which is useful to prevent rescheduling
+	packets that have been tunneled to the ipvs host (i.e. to prevent
+	ipvs routing loops when ipvs is also acting as a real server).
+
 nat_icmp_send - BOOLEAN
         0 - disabled (default)
         not 0 - enabled
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 47677f0..1096a71 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -998,6 +998,7 @@ struct netns_ipvs {
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
 	int			sysctl_schedule_icmp;
+	int			sysctl_ignore_tunneled;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1121,6 +1122,11 @@ static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_schedule_icmp;
 }
 
+static inline int sysctl_ignore_tunneled(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_ignore_tunneled;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1198,6 +1204,11 @@ static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_ignore_tunneled(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 99be680..453972c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1760,8 +1760,16 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	/* Protocol supported? */
 	pd = ip_vs_proto_data_get(net, iph.protocol);
-	if (unlikely(!pd))
+	if (unlikely(!pd)) {
+		/* The only way we'll see this packet again is if it's
+		 * encapsulated, so mark it with ipvs_property=1 so we
+		 * skip it if we're ignoring tunneled packets
+		 */
+		if (sysctl_ignore_tunneled(ipvs))
+			skb->ipvs_property = 1;
+
 		return NF_ACCEPT;
+	}
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 31d80e2..7338827 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1850,6 +1850,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "ignore_tunneled",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3902,6 +3908,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	ipvs->sysctl_conn_reuse_mode = 1;
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
 	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
+	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
 	if (ipvs->sysctl_hdr == NULL) {
-- 
Alex Gartrell <agartrell@fb.com>

