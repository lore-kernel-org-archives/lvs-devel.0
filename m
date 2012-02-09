From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH] ipvsadm: fix list_daemon to handle master/backup status in
 either position
Date: Thu, 09 Feb 2012 09:50:32 -0600
Message-ID: <4F33EB48.8010708@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010302040707050404030004"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

This is a multi-part message in MIME format.
--------------010302040707050404030004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached is a patch that fixes the list_daemon function such that it 
does not assume that the master sync daemon status is always in the 
first position and master sync daemon status is always in the second 
position.

If libipvs uses the netlink interface to retrieve sync daemon status, 
the results are not guaranteed to follow this ordering. As explained in 
a previous email, if libipvs uses the netlink interface to retrieve sync 
daemon status while only a backup sync daemon is running, the backup 
sync daemon status will but in the first position (index 0). This 
differs from the getsockopt interface, which would always put master 
sync daemon status in first position and backup sync daemon status in 
the second position, even when only backup sync daemon exists. Solution 
is to make ipvsadm check both elements of the array for master and backup.

Ryan


--------------010302040707050404030004
Content-Type: text/plain;
 name="ipvsadm-1.26-fix_list_daemon.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ipvsadm-1.26-fix_list_daemon.patch"

Index: ipvsadm.c
===================================================================
--- ipvsadm.c	(revision 77)
+++ ipvsadm.c	(working copy)
@@ -1631,16 +1631,19 @@
 static void list_daemon(void)
 {
 	ipvs_daemon_t *u;
+	int i;
 
 	if (!(u = ipvs_get_daemon()))
 		exit(1);
 
-	if (u[0].state & IP_VS_STATE_MASTER)
-		printf("master sync daemon (mcast=%s, syncid=%d)\n",
-		       u[0].mcast_ifn, u[0].syncid);
-	if (u[1].state & IP_VS_STATE_BACKUP)
-		printf("backup sync daemon (mcast=%s, syncid=%d)\n",
-		       u[1].mcast_ifn, u[1].syncid);
+	for (i = 0; i < 2; i++) {
+		if (u[i].state & IP_VS_STATE_MASTER)
+			printf("master sync daemon (mcast=%s, syncid=%d)\n",
+			       u[i].mcast_ifn, u[i].syncid);
+		if (u[i].state & IP_VS_STATE_MASTER)
+			printf("master sync daemon (mcast=%s, syncid=%d)\n",
+			       u[i].mcast_ifn, u[i].syncid);
+	}
 	free(u);
 }
 

--------------010302040707050404030004--
