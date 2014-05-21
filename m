From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH] ipvsadm: Fix list daemon to show backup daemon
Date: Tue, 20 May 2014 22:14:31 -0500
Message-ID: <1400642071-10408-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Ryan O'Hara <rohara@redhat.com>

The list_daemon function in ipvsadm.c will show the master daemon
twice, but never the backup daemon. This patch replaces the redundant
check for IP_VS_STATE_MASTER with a check for IP_VS_STATE_BACKUP, then
prints the appropriate message.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 ipvsadm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 4c83a8b..755827f 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1732,8 +1732,8 @@ static void list_daemon(void)
 		if (u[i].state & IP_VS_STATE_MASTER)
 			printf("master sync daemon (mcast=%s, syncid=%d)\n",
 			       u[i].mcast_ifn, u[i].syncid);
-		if (u[i].state & IP_VS_STATE_MASTER)
-			printf("master sync daemon (mcast=%s, syncid=%d)\n",
+		if (u[i].state & IP_VS_STATE_BACKUP)
+			printf("backup sync daemon (mcast=%s, syncid=%d)\n",
 			       u[i].mcast_ifn, u[i].syncid);
 	}
 	free(u);
-- 
1.9.0

