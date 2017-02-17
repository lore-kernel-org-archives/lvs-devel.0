From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 2/4] ipvs: Document sysctl sync_qlen_max and sync_sock_size
Date: Fri, 17 Feb 2017 14:33:59 +0800
Message-ID: <1487313241-11361-3-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=/IvGIiTEZGmX57uBJyGcXpLKf60FqS/zlwr7Kr1oOHM=;
        b=h4TxfWW82oqNC6rFT5iNW4yeBNjz2GO79qyEp7puXHLE0winva9/Z2v4I7ScAGVvna
         PS6+cGH1lE4w6bfTCexE2MPrbByHQcDjw3UQCLEcof04RTieWilQmgoEFEaBWCGFEkj2
         lf92X/PSW+tmt3gbWSTKrPsYt1NVNhmgiwNfUbEwl3tk6qAhq+j7eGVF20CysER3ADGS
         SapZeloBZhFbfvthG3gNvuKYppscrLOakRyO3q/qHBgCUyBL5Jztg4Tx0qBX+yGrLm06
         jfFoNqgBXIpQoeAmYNQV4fDI6b2RzI7x0EV9HX4iNA5aOe4ws0aVqZ7HoQoNEEbH750P
         V2rg==
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_qlen_max and sync_sock_size based on commit
1c003b1580e2 ("ipvs: wakeup master thread").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7acaaa6..7622ba5 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -217,6 +217,19 @@ sync_retries - INTEGER
 	to protect against loss of sync messages. The range of the
 	sync_retries is from 0 to 3.
 
+sync_qlen_max - UNSIGNED LONG
+
+	Hard limit for queued sync messages that not sent yet. It defaults to
+	1/32 of the memory pages but actually represents number of messages.
+	It will protect us from allocating large parts of memory when the
+	sending rate is lower than the queuing rate.
+
+sync_sock_size - INTEGER
+	default 0
+
+	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
+	Default value is 0 (preserve system defaults).
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.5.5

