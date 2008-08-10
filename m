From: sven.wegener@stealer.net
Subject: [PATCH 6/9] ipvs: Annotate init functions with __init
Date: Sun, 10 Aug 2008 11:07:36 +0000
Message-ID: <1218366459-23971-7-git-send-email-sven.wegener@stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Sven Wegener <sven.wegener@stealer.net>

Being able to discard these functions saves a couple of bytes at runtime. The
cleanup functions can't be annotated with __exit as they are also called from
init functions.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_app.c   |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 1f1897a..201b8ea 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -608,7 +608,7 @@ int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
 }
 
 
-int ip_vs_app_init(void)
+int __init ip_vs_app_init(void)
 {
 	/* we will replace it with proc_net_ipvs_create() soon */
 	proc_net_fops_create(&init_net, "ip_vs_app", 0, &ip_vs_app_fops);
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index f8bdae4..44a6872 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -965,7 +965,7 @@ static void ip_vs_conn_flush(void)
 }
 
 
-int ip_vs_conn_init(void)
+int __init ip_vs_conn_init(void)
 {
 	int idx;
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 9a5ace0..df13333 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -2306,7 +2306,7 @@ static struct nf_sockopt_ops ip_vs_sockopts = {
 };
 
 
-int ip_vs_control_init(void)
+int __init ip_vs_control_init(void)
 {
 	int ret;
 	int idx;
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 876714f..6c93ffa 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -190,7 +190,7 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 }
 
 
-int ip_vs_protocol_init(void)
+int __init ip_vs_protocol_init(void)
 {
 	char protocols[64];
 #define REGISTER_PROTOCOL(p)			\
-- 
1.5.6.4

