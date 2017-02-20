From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 2/4] ipvs: Document sysctl sync_qlen_max and sync_sock_size
Date: Mon, 20 Feb 2017 16:31:36 +0800
Message-ID: <1487579498-18967-3-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=EAQ9pCHYLi31I3wxfRl1jP+NPvqNV/ikQQKykYPzG/o=;
        b=F7blNXOLGpgnrl73VP1P7/jXSwz39S8LJtTLDIsNwERK0kencxL678Vj9nawe3rQtd
         mCCdlQ8Vzny6bc1c7BHxYK39kpRnRSH7p51cGe/KHXC+pMdQah9XCJPVfShMrBawexle
         m8ILeBBPT0LFzkjijdJoP27jdVOnKhK22HT/HhIe4KnUQCw96/7S+AYZxUMtzmyI9Wja
         D/zzQ3GvGtgcKwoWMJWEjJ8zl8cT6mStMJRiY5+fCfJSrow2kqvuGH1UtTaayxck5Rv/
         9AmadFrjmFBPMdv1l00hBsBZx45G4l76qEKkFvkIyfV+PPuo33nld8Y3yi2SdFvDYPws
         qxmQ==
In-Reply-To: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_qlen_max and sync_sock_size based on
commit 1c003b1580e2 ("ipvs: wakeup master thread").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7acaaa6..159d70b 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -217,6 +217,20 @@ sync_retries - INTEGER
 	to protect against loss of sync messages. The range of the
 	sync_retries is from 0 to 3.
 
+sync_qlen_max - UNSIGNED LONG
+
+	Hard limit for queued sync messages that are not sent yet. It
+	defaults to 1/32 of the memory pages but actually represents
+	number of messages. It will protect us from allocating large
+	parts of memory when the sending rate is lower than the queuing
+	rate.
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

