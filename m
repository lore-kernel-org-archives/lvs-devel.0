From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 03/24] IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support
Date: Wed, 20 Aug 2008 18:15:10 +0200
Message-ID: <1219248931-15064-4-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248951; bh=i2Mh5zn/AVHsmfAZ8G+AwuGLzNI=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=MbnNCKt5pV9osARqkCERj3G11E6qyqtSkx2HUelQ
	Ttda7LYXmB1tlKmU2v1/o85BEAHkx/t7mpEoVvC9/V8fNA==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add boolean config option CONFIG_IP_VS_IPV6 for enabling experimental IPv6
support in IPVS. Only visible if IPv6 support is set to 'y' or both IPv6
and IPVS are modules.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 09d0c3f..fd24182 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -24,6 +24,14 @@ menuconfig IP_VS
 
 if IP_VS
 
+config	IP_VS_IPV6
+	bool "IPv6 support for IPVS (DANGEROUS)"
+	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
+	---help---
+	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
+
+	  Say N if unsure.
+
 config	IP_VS_DEBUG
 	bool "IP virtual server debugging"
 	---help---
-- 
1.5.4.5

