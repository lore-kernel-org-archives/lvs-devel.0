From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 21/26] IPVS: Make proc/net files output IPv6 entries correctly.
Date: Wed, 11 Jun 2008 19:12:04 +0200
Message-ID: <1213204329-10973-22-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204340; bh=uu8F371O2a1bkx7fa/t6xNPXVZI=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=TUSqK/Y0BmkMpWz/PBGBuIMogZQdCbQREsEwW1LI
	/T15170SJ2PIP73lcUgeIYgUjAEJczeNL5f44l0xyqQK3A==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Add support for IPv6 entry output to ip_vs_conn_seq_show() and
ip_vs_conn_sync_seq_show() proc/net file handlers.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 30e1ad2..ea0fd77 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1032,14 +1032,26 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
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
+				ntohl(cp->caddr.v4), ntohs(cp->cport),
+				ntohl(cp->vaddr.v4), ntohs(cp->vport),
+				ntohl(cp->daddr.v4), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ);
+#ifdef CONFIG_IP_VS_IPV6
+		else
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT " %04X " NIP6_FMT " %04X %-11s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.v6), ntohs(cp->cport),
+				NIP6(cp->vaddr.v6), ntohs(cp->vport),
+				NIP6(cp->daddr.v6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				(cp->timer.expires-jiffies)/HZ);
+#endif
 	}
 	return 0;
 }
@@ -1081,15 +1093,28 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
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
+				ntohl(cp->caddr.v4), ntohs(cp->cport),
+				ntohl(cp->vaddr.v4), ntohs(cp->vport),
+				ntohl(cp->daddr.v4), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				ip_vs_origin_name(cp->flags),
 				(cp->timer.expires-jiffies)/HZ);
+#ifdef CONFIG_IP_VS_IPV6
+		else
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT " %04X " NIP6_FMT " %04X %-11s %-6s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.v6), ntohs(cp->cport),
+				NIP6(cp->vaddr.v6), ntohs(cp->vport),
+				NIP6(cp->daddr.v6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				ip_vs_origin_name(cp->flags),
+				(cp->timer.expires-jiffies)/HZ);
+#endif
 	}
 	return 0;
 }
-- 
1.5.3.6

