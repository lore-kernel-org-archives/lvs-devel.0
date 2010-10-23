From: Simon Horman <horms@verge.net.au>
Subject: [patch 8/9] IPVS: Calculate remaining synchronisation buffer space earlier
Date: Sun, 24 Oct 2010 00:26:34 +0900
Message-ID: <20101023153022.623482962@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_sync_conn-space.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Up until now there have only been two possible buffer entry sizes.
So it has been easy enough to check there is enough space for the
larger version left after some space is used and flush the buffer
accordingly.

v2 of the synchronisation protocol will add a variety of different
entry lengths, including dynamically sized entries. So move
this calculation before an entry is added to the buffer but after
its size is known.

This may cause a delay in synchronisation as the calculation
and thus flushing of a full buffer is effectively delayed by one entry
more than before.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 13:27:05.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 13:30:36.000000000 +0900
@@ -286,7 +286,16 @@ void ip_vs_sync_conn(struct ip_vs_conn *
 	struct ip_vs_sync_conn *s;
 	int len;
 
+	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
+		SIMPLE_CONN_SIZE;
+
 	spin_lock(&curr_sb_lock);
+
+	/* check if there is a enough space */
+	if (curr_sb && curr_sb->head + len > curr_sb->end) {
+		sb_queue_tail(curr_sb);
+		curr_sb = NULL;
+	}
 	if (!curr_sb) {
 		if (!(curr_sb=ip_vs_sync_buff_create())) {
 			spin_unlock(&curr_sb_lock);
@@ -295,8 +304,6 @@ void ip_vs_sync_conn(struct ip_vs_conn *
 		}
 	}
 
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
 	m = curr_sb->mesg;
 	s = (struct ip_vs_sync_conn *)curr_sb->head;
 
@@ -320,11 +327,6 @@ void ip_vs_sync_conn(struct ip_vs_conn *
 	m->size += len;
 	curr_sb->head += len;
 
-	/* check if there is a space for next one */
-	if (curr_sb->head+FULL_CONN_SIZE > curr_sb->end) {
-		sb_queue_tail(curr_sb);
-		curr_sb = NULL;
-	}
 	spin_unlock(&curr_sb_lock);
 
 	/* synchronize its controller if it has */

