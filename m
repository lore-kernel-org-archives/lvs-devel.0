From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 1/4] ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
Date: Mon, 20 Feb 2017 16:31:35 +0800
Message-ID: <1487579498-18967-2-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zi9rS3Ggg4QsQbH/yoyQLy36nG4CNG03rAnM5sKOpKI=;
        b=Gtt1td34SGI7md0UitzEdq0XnoUAAp1CdqSi2cc4bHnxaX7+ii2ARJ4QnTUcjPnnia
         IMyZKZXQnpUXsLG26cJStljnjuD6HS33wYfSZ+XZpVbGpX0E+QBi+JVtVcg2GBEg2z2G
         I2D7C5b5b4CkHf3Zh3qeSYzLXHhBetmf01KzsWL7Ui8LKN6ZEn0w+qJfulELB4hCnGLM
         GFeDbE+oB26mNxoO2YNSwUypUZ/X0O96E3/64lv9wmYZX/mVmYcILNeDX6Hu83yFVEZx
         /L2aBQZqxRpI5pcOfbT8kUZT0tVuv58LVMuX2wfk0tUW0SPOkz+ljXnkJ9rhvGB/JfW0
         0/Yw==
In-Reply-To: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>

Fix sync_threshold description which should have two values. Also add
sync_refresh_period and sync_retries based on commit 749c42b620a9
("ipvs: reduce sync rate with time thresholds").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 40 +++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index e6b1c02..7acaaa6 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -185,15 +185,37 @@ secure_tcp - INTEGER
         The value definition is the same as that of drop_entry and
         drop_packet.
 
-sync_threshold - INTEGER
-        default 3
-
-        It sets synchronization threshold, which is the minimum number
-        of incoming packets that a connection needs to receive before
-        the connection will be synchronized. A connection will be
-        synchronized, every time the number of its incoming packets
-        modulus 50 equals the threshold. The range of the threshold is
-        from 0 to 49.
+sync_threshold - vector of 2 INTEGERs: sync_threshold, sync_period
+	default 3 50
+
+	It sets synchronization threshold, which is the minimum number
+	of incoming packets that a connection needs to receive before
+	the connection will be synchronized. A connection will be
+	synchronized, every time the number of its incoming packets
+	modulus sync_period equals the threshold. The range of the
+	threshold is from 0 to sync_period.
+
+	When sync_period and sync_refresh_period are 0, send sync only
+	for state changes or only once when pkts matches sync_threshold
+
+sync_refresh_period - UNSIGNED INTEGER
+	default 0
+
+	In seconds, difference in reported connection timer that triggers
+	new sync message. It can be used to avoid sync messages for the
+	specified period (or half of the connection timeout if it is lower)
+	if connection state is not changed since last sync.
+
+	This is useful for normal connections with high traffic to reduce
+	sync rate. Additionally, retry sync_retries times with period of
+	sync_refresh_period/8.
+
+sync_retries - INTEGER
+	default 0
+
+	Defines sync retries with period of sync_refresh_period/8. Useful
+	to protect against loss of sync messages. The range of the
+	sync_retries is from 0 to 3.
 
 snat_reroute - BOOLEAN
 	0 - disabled
-- 
2.5.5

