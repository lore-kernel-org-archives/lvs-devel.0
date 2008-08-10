From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 6/9] ipvs: Annotate init functions with __init
Date: Sun, 10 Aug 2008 20:32:11 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808102029200.12259@titan.stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <1218366459-23971-7-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-7-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Being able to discard these functions saves a couple of bytes at runtime. The
cleanup functions can't be annotated with __exit as they are also called from
init functions.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_app.c   |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

There's one more, register_ip_vs_protocol() is also only used during 
initialization.

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
index 876714f..6099a88 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -43,7 +43,7 @@ static struct ip_vs_protocol *ip_vs_proto_table[IP_VS_PROTO_TAB_SIZE];
 /*
  *	register an ipvs protocol
  */
-static int __used register_ip_vs_protocol(struct ip_vs_protocol *pp)
+static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 {
 	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
 
@@ -190,7 +190,7 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 }
 
 
-int ip_vs_protocol_init(void)
+int __init ip_vs_protocol_init(void)
 {
 	char protocols[64];
 #define REGISTER_PROTOCOL(p)			\
