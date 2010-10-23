From: Simon Horman <horms@verge.net.au>
Subject: [patch 6/9] IPVS: Add ip_vs_sync_mesg_v2
Date: Sun, 24 Oct 2010 00:26:32 +0900
Message-ID: <20101023153021.543599177@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_sync_mesg_v2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 11:31:00.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 11:46:51.000000000 +0900
@@ -104,7 +104,6 @@ struct ip_vs_sync_thread_data {
 */
 
 #define SYNC_MESG_V1_HEADER_LEN	sizeof(struct ip_vs_sync_mesg_v1)
-#define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
 struct ip_vs_sync_mesg_v1 {
 	__u8                    nr_conns;
@@ -114,6 +113,46 @@ struct ip_vs_sync_mesg_v1 {
 	/* ip_vs_sync_conn entries start here */
 };
 
+/* IPVS Connection Synchronisation v2
+
+  The master mulitcasts messages to the backup load balancers in the
+  following format.
+
+       0                   1                   2                   3
+       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |  Count Conns  |    SyncID     |            Zero               |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |    Version    |     Zero      |            Size               |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                                                               |
+      |                    IPVS Sync Connection (1)                   |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                            .                                  |
+      |                            .                                  |
+      |                            .                                  |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                                                               |
+      |                    IPVS Sync Connection (n)                   |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+*/
+
+#define SYNC_MESG_V2_HEADER_LEN	sizeof(struct ip_vs_sync_mesg_v2)
+
+struct ip_vs_sync_mesg_v2 {
+	__u8                    nr_conns;
+	__u8                    syncid;
+	__u16                   zero1;
+
+	__u8			version;
+	__u8			zero2;
+	__u16			size;
+
+	/* ip_vs_sync_conn entries start here */
+};
+
+#define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
+
 /* the maximum length of sync (sending/receiving) message */
 static int sync_send_mesg_maxlen;
 static int sync_recv_mesg_maxlen;

