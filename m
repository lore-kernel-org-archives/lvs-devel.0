From: Tim Serong <tserong@suse.com>
Subject: [PATCH] ipvsadm: Fix buffer overrun in ipvs_dests_parse_cb() (bnc#775051)
Date: Tue, 18 Sep 2012 20:01:53 +1000
Message-ID: <1347962513-9933-1-git-send-email-tserong@suse.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Tim Serong <tserong@suse.com>

The attrs and dest_attrs arrays in ipvs_dest_parse_cb() seem to be using
the wrong defines for their length.  This resulted in a buffer overrun
corrupting EBX, which later caused a segfault running 'ipvsadm -Ln' on
32 bit intel (SLES 11 SP2).

Signed-off-by: Tim Serong <tserong@suse.com>
---
 libipvs/ip_vs.h   |    2 +-
 libipvs/libipvs.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 9726a17..5e1d544 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -413,7 +413,7 @@ enum {
 	__IPVS_CMD_ATTR_MAX,
 };
 
-#define IPVS_CMD_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+#define IPVS_CMD_ATTR_MAX (__IPVS_CMD_ATTR_MAX - 1)
 
 /*
  * Attributes used to describe a service
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index a157e18..be34dbc 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -726,8 +726,8 @@ ipvs_sort_services(struct ip_vs_get_services *s, ipvs_service_cmp_t f)
 static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(msg);
-	struct nlattr *attrs[IPVS_DEST_ATTR_MAX + 1];
-	struct nlattr *dest_attrs[IPVS_SVC_ATTR_MAX + 1];
+	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
+	struct nlattr *dest_attrs[IPVS_DEST_ATTR_MAX + 1];
 	struct ip_vs_get_dests **dp = (struct ip_vs_get_dests **)arg;
 	struct ip_vs_get_dests *d = (struct ip_vs_get_dests *)*dp;
 	int i = d->num_dests;
-- 
1.7.10.4

