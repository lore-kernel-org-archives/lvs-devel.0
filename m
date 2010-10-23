From: Simon Horman <horms@verge.net.au>
Subject: [patch 1/9] IPVS: Make the cp argument to ip_vs_sync_conn() static
Date: Sun, 24 Oct 2010 00:26:27 +0900
Message-ID: <20101023153018.826373888@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_sync_conn-const.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-10 23:29:32.000000000 +0900
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-10 23:29:40.000000000 +0900
@@ -889,7 +889,7 @@ extern char ip_vs_master_mcast_ifn[IP_VS
 extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
 extern int stop_sync_thread(int state);
-extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern void ip_vs_sync_conn(const struct ip_vs_conn *cp);
 
 
 /*
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 23:29:49.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 23:29:52.000000000 +0900
@@ -236,7 +236,7 @@ get_curr_sync_buff(unsigned long time)
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
  */
-void ip_vs_sync_conn(struct ip_vs_conn *cp)
+void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
 	struct ip_vs_sync_conn *s;

