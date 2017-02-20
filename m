From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 4/4] ipvs: Document sysctl pmtu_disc
Date: Mon, 20 Feb 2017 16:31:38 +0800
Message-ID: <1487579498-18967-5-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
 <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Oz+8e0tSC6UjJmwfxFjnH78bvYCfomg6/V199kyu7tA=;
        b=RKSNXnnud0EtfW7dR3rZXnPRi8tRuCE8zthYIpWdNxpjlgwVrKbBsVnhSLHmgRQOtR
         cWKCLWAw+Vownay/OxcUthO410cnp88D2/wqyxEKgtk9y0Qpedoiiqmk/kIIFbCeJ8y6
         LKI9ZEu+WjqNPaKaoAVGf6dJFRbL4sk3JKyFkRuSpLtbUmduX7uo8ZBxpAGtzq761+rh
         9RhzpkLIZ1xFsT8mr7bgss/Lef1G0XCUU7Au3hUg1qd60EcVkTptrevRsDxld1iavPJl
         lQiMQKun15M3JelL/wDGwbk86ankIKVMiXslbQ0F18NhJxvg4SOJfrO8ZFWmS2KOvLna
         yIYw==
In-Reply-To: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl pmtu_disc based on commit 3654e61137db ("ipvs: add
pmtu_disc option to disable IP DF for TUN packets").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index a6feecd..0568986 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -175,6 +175,14 @@ nat_icmp_send - BOOLEAN
         for VS/NAT when the load balancer receives packets from real
         servers but the connection entries don't exist.
 
+pmtu_disc - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	By default, reject with FRAG_NEEDED all DF packets that exceed
+	the PMTU, irrespective of the forwarding method. For TUN method
+	the flag can be disabled to fragment such packets.
+
 secure_tcp - INTEGER
         0  - disabled (default)
 
-- 
2.5.5

