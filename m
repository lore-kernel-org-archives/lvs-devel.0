From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 5/9] IPVS: Make the cp argument to ip_vs_sync_conn() static
Date: Fri, 12 Nov 2010 08:34:57 +0100
Message-ID: <1289547301-28015-5-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Simon Horman <horms@verge.net.au>

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a6421e6..890f01c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -918,7 +918,7 @@ extern char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
 extern int stop_sync_thread(int state);
-extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern void ip_vs_sync_conn(const struct ip_vs_conn *cp);
 
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0cfeeee..4b0ed40 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -366,7 +366,7 @@ get_curr_sync_buff(unsigned long time)
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
  */
-void ip_vs_sync_conn(struct ip_vs_conn *cp)
+void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
 	struct ip_vs_sync_conn_v0 *s;
-- 
1.7.2.3

