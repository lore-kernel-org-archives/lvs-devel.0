From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 20/24] IPVS: Turn off FTP application helper for IPv6
Date: Tue,  2 Sep 2008 15:55:51 +0200
Message-ID: <1220363755-9854-21-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363765; bh=eeJGW0YSAG1fYF5Vjsd2/ocYQOo=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=MH6IsH+DytDliByJHK5s2RcWZtAOrjnVYTMAcTR5
	enpiZ2ieuUbbTyDeTXY4XL/A8248Wc/NcLml+N6QSRfUTw==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Immediately return from FTP application helper and do nothing when dealing
with IPv6 packets. IPv6 is not supported by this helper yet.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index 0c3fbe0..2e7dbd8 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -147,6 +147,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	unsigned buf_len;
 	int ret;
 
+#ifdef CONFIG_IP_VS_IPV6
+	/* This application helper doesn't work with IPv6 yet,
+	 * so turn this into a no-op for IPv6 packets
+	 */
+	if (cp->af == AF_INET6)
+		return 1;
+#endif
+
 	*diff = 0;
 
 	/* Only useful for established sessions */
@@ -248,6 +256,14 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 
+#ifdef CONFIG_IP_VS_IPV6
+	/* This application helper doesn't work with IPv6 yet,
+	 * so turn this into a no-op for IPv6 packets
+	 */
+	if (cp->af == AF_INET6)
+		return 1;
+#endif
+
 	/* no diff required for incoming packets */
 	*diff = 0;
 
-- 
1.5.4.5

