From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Restrict sync message to 255 connections
Date: Fri, 19 Sep 2008 20:41:56 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809192040250.22510@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

The nr_conns variable in the sync message header is only eight bits wide
and will overflow on interfaces with a large MTU. As a result the backup
won't parse all connections contained in the sync buffer. On regular
ethernet with an MTU of 1500 this isn't a problem, because we can't
overflow the value, but consider jumbo frames being used on a cross-over
connection between both directors.

We now restrict the size of the sync buffer, so that we never put more
than 255 connections into a single sync buffer.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 28237a5..de5e7e1 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -30,6 +30,7 @@
 #include <linux/err.h>
 #include <linux/kthread.h>
 #include <linux/wait.h>
+#include <linux/kernel.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
@@ -99,6 +100,7 @@ struct ip_vs_sync_thread_data {
 */
 
 #define SYNC_MESG_HEADER_LEN	4
+#define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
 struct ip_vs_sync_mesg {
 	__u8                    nr_conns;
@@ -516,8 +518,8 @@ static int set_sync_mesg_maxlen(int sync_state)
 		num = (dev->mtu - sizeof(struct iphdr) -
 		       sizeof(struct udphdr) -
 		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
-		sync_send_mesg_maxlen =
-			SYNC_MESG_HEADER_LEN + SIMPLE_CONN_SIZE * num;
+		sync_send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
+			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
 		IP_VS_DBG(7, "setting the maximum length of sync sending "
 			  "message %d.\n", sync_send_mesg_maxlen);
 	} else if (sync_state == IP_VS_STATE_BACKUP) {
