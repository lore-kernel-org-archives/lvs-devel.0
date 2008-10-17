From: Julius Volz <juliusv@google.com>
Subject: [PATCH] IPVS: Update CONFIG_IP_VS_IPV6 description and help text
Date: Fri, 17 Oct 2008 14:04:51 +0200
Message-ID: <1224245091-30426-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1224245100; bh=GIjadnqKdGt/LTXy/kkracM+2mU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer;
	b=I5fXkufcRHFcjO9qGX6mncO88isI//MjVODoaUASFfisN/BhOzvWe05JiRhC2+p95
	r0gn2Qlvh9p9DYElHkRVw==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, Julius Volz <juliusv@google.com>

This adds a URL to further info to the CONFIG_IP_VS_IPV6 Kconfig help
text. Also, I think it should be ok to remove the "DANGEROUS" label in the
description line at this point to get people to try it out and find all
the bugs ;) It's still marked as experimental, of course.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 05048e4..79a6980 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -25,11 +25,13 @@ menuconfig IP_VS
 if IP_VS
 
 config	IP_VS_IPV6
-	bool "IPv6 support for IPVS (DANGEROUS)"
+	bool "IPv6 support for IPVS"
 	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
 	---help---
 	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
 
+	  See http://www.mindbasket.com/ipvs for more information.
+
 	  Say N if unsure.
 
 config	IP_VS_DEBUG
-- 
1.5.4.5

