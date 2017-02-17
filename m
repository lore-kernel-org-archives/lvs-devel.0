From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 1/4] ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
Date: Fri, 17 Feb 2017 14:33:58 +0800
Message-ID: <1487313241-11361-2-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zi9rS3Ggg4QsQbH/yoyQLy36nG4CNG03rAnM5sKOpKI=;
        b=SU8NmIZvAoDc0hNrkWoD5OTK6QFvuW0wHwHMFublhooNxC57bya/wprSed4+SJPmTq
         IbvuTjbg0zhlDW8Fbut9CJ630T7jxPJOMdR+cSL66EcCR6cYtqWm3COENEKmTUWpgDEq
         lHA24/kRfrN0MI31FOtO4/PHDOwEuRs7lW0CL4zFY90KHeVv+Dz63jUObuFVfLxaxT82
         O30AISnBxYJA93VXH6lrWKvdE8ZabVY/WoSNDT7fF9iTrK50UMgTzIr3zHf0FtdS3S2r
         92W4ydU+vwRVfSFqoCZYTpFt4N9IsxHWrDSJQ3Af7o2JKHLFWyZ2Wk2Pbb24YeOTmVzP
         TU/w==
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Hangbin Liu <liuhangbin@gmail.com>

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

