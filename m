From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 17/24] IPVS: Make proc/net files output IPv6 entries correctly
Date: Wed, 20 Aug 2008 18:15:24 +0200
Message-ID: <1219248931-15064-18-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248944; bh=iG7G6f7SB+/xyPVka355dRZCZtM=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=p5Tvuf4hoR4XhZevWIJqtAh6trItCb+p/zDkkiDy
	CxAarydjHXV2foSyXPzS0adURrNFek/XxPtMRX+pwMIZxA==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add support for IPv6 entry output to ip_vs_conn_seq_show() and
ip_vs_conn_sync_seq_show() proc/net file handlers.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 5e013c9..f0b848d 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -815,14 +815,26 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 	else {
 		const struct ip_vs_conn *cp = v;
 
-		seq_printf(seq,
-			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
+		if (cp->af == AF_INET)
+			seq_printf(seq,
+				"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
-				ntohl(cp->caddr), ntohs(cp->cport),
-				ntohl(cp->vaddr), ntohs(cp->vport),
-				ntohl(cp->daddr), ntohs(cp->dport),
+				ntohl(cp->caddr.ip), ntohs(cp->cport),
+				ntohl(cp->vaddr.ip), ntohs(cp->vport),
+				ntohl(cp->daddr.ip), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ);
+#ifdef CONFIG_IP_VS_IPV6
+		else
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT " %04X " NIP6_FMT " %04X %-11s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.in6), ntohs(cp->cport),
+				NIP6(cp->vaddr.in6), ntohs(cp->vport),
+				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				(cp->timer.expires-jiffies)/HZ);
+#endif
 	}
 	return 0;
 }
@@ -864,15 +876,28 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 	else {
 		const struct ip_vs_conn *cp = v;
 
-		seq_printf(seq,
-			"%-3s %08X %04X %08X %04X %08X %04X %-11s %-6s %7lu\n",
+		if (cp->af == AF_INET)
+			seq_printf(seq,
+				"%-3s %08X %04X %08X %04X %08X %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
-				ntohl(cp->caddr), ntohs(cp->cport),
-				ntohl(cp->vaddr), ntohs(cp->vport),
-				ntohl(cp->daddr), ntohs(cp->dport),
+				ntohl(cp->caddr.ip), ntohs(cp->cport),
+				ntohl(cp->vaddr.ip), ntohs(cp->vport),
+				ntohl(cp->daddr.ip), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				ip_vs_origin_name(cp->flags),
 				(cp->timer.expires-jiffies)/HZ);
+#ifdef CONFIG_IP_VS_IPV6
+		else
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT " %04X " NIP6_FMT " %04X %-11s %-6s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.in6), ntohs(cp->cport),
+				NIP6(cp->vaddr.in6), ntohs(cp->vport),
+				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				ip_vs_origin_name(cp->flags),
+				(cp->timer.expires-jiffies)/HZ);
+#endif
 	}
 	return 0;
 }
-- 
1.5.4.5

