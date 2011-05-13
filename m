From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/1] IPVS: seq_release_net should be used.
Date: Fri, 13 May 2011 08:03:20 +0200
Message-ID: <1305266600-21507-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Without this patch every access to ip_vs in procfs will increase
the netns count i.e. an unbalanced get_net()/put_net().
(ipvsadm commands also use procfs.)
The result is you can't exit a netns if reading ip_vs_* procfs entries.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_app.c  |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c |    4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c  |    6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 51f3af7..059af31 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -572,7 +572,7 @@ static const struct file_operations ip_vs_app_fops = {
 	.open	 = ip_vs_app_open,
 	.read	 = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d3fd91b..bf28ac2 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1046,7 +1046,7 @@ static const struct file_operations ip_vs_conn_fops = {
 	.open    = ip_vs_conn_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 static const char *ip_vs_origin_name(unsigned flags)
@@ -1114,7 +1114,7 @@ static const struct file_operations ip_vs_conn_sync_fops = {
 	.open    = ip_vs_conn_sync_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 89842f0..699c79a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2066,7 +2066,7 @@ static const struct file_operations ip_vs_info_fops = {
 	.open    = ip_vs_info_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
@@ -2106,7 +2106,7 @@ static const struct file_operations ip_vs_stats_fops = {
 	.open = ip_vs_stats_seq_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 
 static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
@@ -2175,7 +2175,7 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
 	.open = ip_vs_stats_percpu_seq_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 #endif
 
-- 
1.7.2.3

