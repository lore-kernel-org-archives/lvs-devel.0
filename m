From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 3/4] ipvs: Document sysctl sync_ports
Date: Mon, 20 Feb 2017 16:31:37 +0800
Message-ID: <1487579498-18967-4-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=r6VrToSPxONtfhEGpY6FGEmnVj2MSlDstBonzztXNzk=;
        b=LKj05H5mJJolEHYZ4TvdFkTrto7WN5I45AmlusvYTD6hBwWSfYukNm28a0K5bWaUh7
         jq/P4UXRnpLEPPgt8VLxOxqT/IBemqH9NyE6HhdapVXO5lexvlYG3KWAyaGdKGGTkf/b
         jnNyvJbcT5aSuj9o5yuotN+OlalJ0IHrIAY1Xx1GdhZg3zlrMHdOv8PjAN8ad1ndgVt9
         x9jIAdpIFHKCgKXmk4FibvLLHvNTBUGmD+B4/s5u8r0GFKi+3xuFrIabC7lSbWnfrWeg
         eSim4h6Y4d1/n3ZzL18gVMwef63y7gkLHbadtTMU/1EE48Hn4FvmzJZAcolSGCDWCZap
         w7mw==
In-Reply-To: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_ports based on commit f73181c8288f ("ipvs: add support
for sync threads").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 159d70b..a6feecd 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -231,6 +231,14 @@ sync_sock_size - INTEGER
 	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
 	Default value is 0 (preserve system defaults).
 
+sync_ports - INTEGER
+	default 1
+
+	The number of threads that master and backup servers can use for
+	sync traffic. Every thread will use single UDP port, thread 0 will
+	use the default port 8848 while last thread will use port
+	8848+sync_ports-1.
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.5.5

