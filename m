From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 18/25] IPVS: Convert procfs files for IPv6 entry output
Date: Mon,  1 Sep 2008 14:56:15 +0200
Message-ID: <1220273782-19901-19-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=rBcbMZG1KX9EpqLpxp6/RnftYyE=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=uPIze0eH4GM297g8AZ/VKDoqUNFeBslGH6l+aYi1
	d/qJmCPgxMOjZH1uS3pXLeFUt7AZQ0dQIVknS1+z3bQDtA==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Correctly output IPv6 connection/service/dest entries in procfs files.

Signed-off-by: Vince Busam <vbusam@google.com>

 2 files changed, 69 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 2f5c4d8..7f33171 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -814,8 +814,20 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 	else {
 		const struct ip_vs_conn *cp = v;
 
-		seq_printf(seq,
-			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT " %04X " NIP6_FMT " %04X %-11s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.in6), ntohs(cp->cport),
+				NIP6(cp->vaddr.in6), ntohs(cp->vport),
+				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				(cp->timer.expires-jiffies)/HZ);
+		else
+#endif
+			seq_printf(seq,
+				"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
@@ -863,8 +875,23 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 	else {
 		const struct ip_vs_conn *cp = v;
 
-		seq_printf(seq,
-			"%-3s %08X %04X %08X %04X %08X %04X %-11s %-6s %7lu\n",
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			seq_printf(seq,
+				"%-3s " NIP6_FMT " %04X " NIP6_FMT
+				" %04X " NIP6_FMT " %04X %-11s %-6s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				NIP6(cp->caddr.in6), ntohs(cp->cport),
+				NIP6(cp->vaddr.in6), ntohs(cp->vport),
+				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				ip_vs_origin_name(cp->flags),
+				(cp->timer.expires-jiffies)/HZ);
+		else
+#endif
+			seq_printf(seq,
+				"%-3s %08X %04X %08X %04X "
+				"%08X %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 3dae1d9..fe17504 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1792,15 +1792,25 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
 
-		if (iter->table == ip_vs_svc_table)
-			seq_printf(seq, "%s  %08X:%04X %s ",
-				   ip_vs_proto_name(svc->protocol),
-				   ntohl(svc->addr.ip),
-				   ntohs(svc->port),
-				   svc->scheduler->name);
-		else
+		if (iter->table == ip_vs_svc_table) {
+#ifdef CONFIG_IP_VS_IPV6
+			if (svc->af == AF_INET6)
+				seq_printf(seq, "%s  [" NIP6_FMT "]:%04X %s ",
+					   ip_vs_proto_name(svc->protocol),
+					   NIP6(svc->addr.in6),
+					   ntohs(svc->port),
+					   svc->scheduler->name);
+			else
+#endif
+				seq_printf(seq, "%s  %08X:%04X %s ",
+					   ip_vs_proto_name(svc->protocol),
+					   ntohl(svc->addr.ip),
+					   ntohs(svc->port),
+					   svc->scheduler->name);
+		} else {
 			seq_printf(seq, "FWM  %08X %s ",
 				   svc->fwmark, svc->scheduler->name);
+		}
 
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
 			seq_printf(seq, "persistent %d %08X\n",
@@ -1810,13 +1820,27 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 			seq_putc(seq, '\n');
 
 		list_for_each_entry(dest, &svc->destinations, n_list) {
-			seq_printf(seq,
-				   "  -> %08X:%04X      %-7s %-6d %-10d %-10d\n",
-				   ntohl(dest->addr.ip), ntohs(dest->port),
-				   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
-				   atomic_read(&dest->weight),
-				   atomic_read(&dest->activeconns),
-				   atomic_read(&dest->inactconns));
+#ifdef CONFIG_IP_VS_IPV6
+			if (dest->af == AF_INET6)
+				seq_printf(seq,
+					   "  -> [" NIP6_FMT "]:%04X"
+					   "      %-7s %-6d %-10d %-10d\n",
+					   NIP6(dest->addr.in6), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+			else
+#endif
+				seq_printf(seq,
+					   "  -> %08X:%04X      "
+					   "%-7s %-6d %-10d %-10d\n",
+					   ntohl(dest->addr.ip), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+
 		}
 	}
 	return 0;
-- 
1.5.4.5

