From: Simon Horman <horms@verge.net.au>
Subject: [patch 5/9] IPVS: rename ip_vs_sync_mesg as ip_vs_sync_mesg_v1
Date: Sun, 24 Oct 2010 00:26:31 +0900
Message-ID: <20101023153020.993493822@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_sync_mesg_v1.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

This is in preparation for adding a new version of the
synchronisation protocol.

* Change name of struct ip_vs_sync_mesg to struct ip_vs_sync_mesg_v1
* Change the name of SYNC_MESG_HEADER_LEN to SYNC_MESG_V1_HEADER_LEN
* Define SYNC_MESG_V1_HEADER_LEN as sizeof(struct ip_vs_sync_mesg_v1)
  instead of 4
* Always use SYNC_MESG_V1_HEADER_LEN instead of 4

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-15 07:50:16.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-15 07:50:24.000000000 +0900
@@ -81,7 +81,8 @@ struct ip_vs_sync_thread_data {
 (sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
 
 
-/*
+/* IPVS Connection Synchronisation v1
+
   The master mulitcasts messages to the backup load balancers in the
   following format.
 
@@ -102,10 +103,10 @@ struct ip_vs_sync_thread_data {
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */
 
-#define SYNC_MESG_HEADER_LEN	4
+#define SYNC_MESG_V1_HEADER_LEN	sizeof(struct ip_vs_sync_mesg_v1)
 #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
-struct ip_vs_sync_mesg {
+struct ip_vs_sync_mesg_v1 {
 	__u8                    nr_conns;
 	__u8                    syncid;
 	__u16                   size;
@@ -122,7 +123,7 @@ struct ip_vs_sync_buff {
 	unsigned long           firstuse;
 
 	/* pointers for the message data */
-	struct ip_vs_sync_mesg  *mesg;
+	struct ip_vs_sync_mesg_v1 *mesg;
 	unsigned char           *head;
 	unsigned char           *end;
 };
@@ -188,8 +189,8 @@ static inline struct ip_vs_sync_buff * i
 	}
 	sb->mesg->nr_conns = 0;
 	sb->mesg->syncid = ip_vs_master_syncid;
-	sb->mesg->size = 4;
-	sb->head = (unsigned char *)sb->mesg + 4;
+	sb->mesg->size = SYNC_MESG_V1_HEADER_LEN;
+	sb->head = (unsigned char *)sb->mesg + SYNC_MESG_V1_HEADER_LEN;
 	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
 	sb->firstuse = jiffies;
 	return sb;
@@ -238,7 +239,7 @@ get_curr_sync_buff(unsigned long time)
  */
 void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 {
-	struct ip_vs_sync_mesg *m;
+	struct ip_vs_sync_mesg_v1 *m;
 	struct ip_vs_sync_conn *s;
 	int len;
 
@@ -305,7 +306,7 @@ ip_vs_conn_fill_param_sync(int af, int p
  */
 static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
-	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
+	struct ip_vs_sync_mesg_v1 *m = (struct ip_vs_sync_mesg_v1 *)buffer;
 	struct ip_vs_sync_conn *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
@@ -315,7 +316,7 @@ static void ip_vs_process_message(char *
 	char *p;
 	int i;
 
-	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+	if (buflen < SYNC_MESG_V1_HEADER_LEN) {
 		IP_VS_ERR_RL("sync message header too short\n");
 		return;
 	}
@@ -335,7 +336,7 @@ static void ip_vs_process_message(char *
 		return;
 	}
 
-	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
+	p = (char *)buffer + SYNC_MESG_V1_HEADER_LEN;
 	for (i=0; i<m->nr_conns; i++) {
 		unsigned flags, state;
 
@@ -540,8 +541,8 @@ static int set_sync_mesg_maxlen(int sync
 
 		num = (dev->mtu - sizeof(struct iphdr) -
 		       sizeof(struct udphdr) -
-		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
-		sync_send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
+		       SYNC_MESG_V1_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
+		sync_send_mesg_maxlen = SYNC_MESG_V1_HEADER_LEN +
 			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
 		IP_VS_DBG(7, "setting the maximum length of sync sending "
 			  "message %d.\n", sync_send_mesg_maxlen);
@@ -719,7 +720,7 @@ ip_vs_send_async(struct socket *sock, co
 }
 
 static void
-ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
+ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg_v1 *msg)
 {
 	int msize;
 

