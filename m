From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 4/4] ipvs: Document sysctl pmtu_disc
Date: Fri, 17 Feb 2017 14:34:01 +0800
Message-ID: <1487313241-11361-5-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=m7WWMPAekvct4dLcBsKEZJosAc6yKgS/kDarnWeMpCk=;
        b=D8Sp4CY8rZVBAR+krHslHkReXHuv1KyZqwN7779TmP+DunsdFksKKc8rNsF3CTP/c0
         ODTRmPN6Sdh5BYpp+OsbMFhggAWDYNV/i0+2t+nnZfflYhyzYKAmSa7uxxQ/W8XyEPob
         CUnt/dPkqYHVEWK/DwiVVE3qOv1I60WwLm5MlagE+fehDu+heV+/7OQmoPiZtX8FkUxx
         lY4YexWrDeil9YIcuuqsO9pjry6SZdmFsJpJiUGhUC5mwdMF71sfhGU0qa86tNQC2lzd
         PBbaYTC4gEN4gqnzWJvCq6QV2APb5Z2xzYwGI0QWyxb01N2HcuuTxGNUQEZbPSb+/jjX
         7l9Q==
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl pmtu_disc based on commit 3654e61137db ("ipvs: add pmtu_disc
option to disable IP DF for TUN packets").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index e4d9235..fb65d4a 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -175,6 +175,15 @@ nat_icmp_send - BOOLEAN
         for VS/NAT when the load balancer receives packets from real
         servers but the connection entries don't exist.
 
+pmtu_disc - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	When enabled PMTU discovery(default) and received packets larger than
+	the next MTU, we will send back FRAG_NEEDED message and drop the
+	incoming packet. But if users prefer to fragment regardless of DF bit
+	other than drop the packet, they can disable it.
+
 secure_tcp - INTEGER
         0  - disabled (default)
 
-- 
2.5.5

