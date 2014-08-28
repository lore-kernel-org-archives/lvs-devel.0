From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 06/20] ipvs: prevent mixing heterogeneous pools and synchronization
Date: Wed, 27 Aug 2014 22:43:40 -0700
Message-ID: <1409204634-1123-7-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qq4VJvVv1zg04TvxyuS97nEF3Mcvdo4QjXdH6yjbGcM=;
 b=mPLVqsXZ0zyAjpu9CsED8jO7YJIdd6w55aysjNI5KtawYwNuBO1qggsxorzSEEox6GpI
 YFm1YOno4Yaw1nK1jsCgvpiOevTP0DHxSHzXETLGuAQDtzqAUUa2LXJCwSQINesT6xSS
 rbH552gnPZO1AG/s0536GhEmijvkFrZX1L8= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

The synchronization protocol is not compatible with heterogeneous pools, so
we need to verify that we're not turning both on at the same time.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index beffb8f..c374ebb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3351,6 +3351,12 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
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

