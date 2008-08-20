From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 24/24] IPVS: Add notes about IPv6 changes
Date: Wed, 20 Aug 2008 18:15:31 +0200
Message-ID: <1219248931-15064-25-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248943; bh=/dS3T5LijI7ZEROE3/nLORZ4tIQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=Pk9YDZQvwYx/V1St6QF/IISpoa9Hgigk8kxWFDW8
	LXg7/PpRqoGckbjTzO1dRVkO6+M33c1plKUJYVar8FCF5Q==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add notes about the IPv6 changes to header comments in relevant files.

Signed-off-by: Julius Volz <juliusv@google.com>

 5 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 011d455..aa6f43b 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -19,6 +19,7 @@
  * and others. Many code here is taken from IP MASQ code of kernel 2.2.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 0f9a0a2..5bb53c0 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -21,6 +21,7 @@
  * Changes:
  *	Paul `Rusty' Russell		properly handle non-linear skbs
  *	Harald Welte			don't use nfcache
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index ba4d7c2..ec5e855 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -15,6 +15,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz, Vince Busam	add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 301b779..5c4b8f9 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 15c59aa..e1a3fde 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
-- 
1.5.4.5

