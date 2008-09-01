From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 25/25] IPVS: Add changelog notes to header comments
Date: Mon,  1 Sep 2008 14:56:22 +0200
Message-ID: <1220273782-19901-26-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273825; bh=vRPOmU67WtbBES6AuosdE1oWSd4=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=E5iFMWwoEPovbhGYwq96r4Ej/gYDrQVa3ogKNDM7
	2h922aYDgL3eBdXKIfzWHJFPO509yeUJzNpBNhDGOFLaEg==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add notes about the IPv6 changes to the relevant files' header comments.

Signed-off-by: Julius Volz <juliusv@google.com>

 7 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index ffd2fd5..0551145 100644
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
index 6f5d534..ea00ae7 100644
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
index 074efb8..9178ed7 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -15,6 +15,8 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ *	Julius Volz			add Generic Netlink interface
+ * 	Julius Volz, Vince Busam	add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 50f6215..edb80e9 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 32c0706..7d9d2cb 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 9b9f3b3..9278c0d 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
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

