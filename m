From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 01/24] IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support
Date: Tue,  2 Sep 2008 15:55:32 +0200
Message-ID: <1220363755-9854-2-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363763; bh=w+rd/FK/oQAlzatdvAV2gVLQYYc=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=Drmkls0qjlic8Z4EY0b0HVSFiGTPq+s9xeO/H0Wj
	8IR1fJ7UkaOdUHwAj2K/ezUZWk38T8e41iHfFSIU+ZM/6Q==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
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
index 2e48a7e..794cecb 100644
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

