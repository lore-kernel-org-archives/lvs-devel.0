From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 15/24] IPVS: Add support for IPv6 entry output in procfs files
Date: Wed, 20 Aug 2008 18:15:22 +0200
Message-ID: <1219248931-15064-16-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248944; bh=MUf3OG2lZf08rOvyXYRkPfgaVXU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=jU3SNiqHq9JTuAkAmoxJDYXuEMwdW1XhfYkv73lx
	vKWCmvwWdDZZnXBrnz2nNcGjE2XxNLTM8xOnsZC8am6OFg==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add support for procfs output of IPv6 service and connection entries.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index efa34fb..e793d82 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1611,6 +1611,7 @@ static struct ctl_table vs_vars[] = {
 
 const struct ctl_path net_vs_ctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
+	/* TODO IPv6: possible to move / duplicate this? */
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
 	{ .procname = "vs", },
 	{ }
@@ -1751,15 +1752,26 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
 
-		if (iter->table == ip_vs_svc_table)
-			seq_printf(seq, "%s  %08X:%04X %s ",
-				   ip_vs_proto_name(svc->protocol),
-				   ntohl(svc->addr),
-				   ntohs(svc->port),
-				   svc->scheduler->name);
-		else
+		if (iter->table == ip_vs_svc_table) {
+			if (svc->af == AF_INET) {
+				seq_printf(seq, "%s  %08X:%04X %s ",
+					   ip_vs_proto_name(svc->protocol),
+					   ntohl(svc->addr.ip),
+					   ntohs(svc->port),
+					   svc->scheduler->name);
+			} else if (svc->af == AF_INET6) {
+#ifdef CONFIG_IP_VS_IPV6
+				seq_printf(seq, "%s  [" NIP6_FMT "]:%04X %s ",
+					   ip_vs_proto_name(svc->protocol),
+					   NIP6(svc->addr.in6),
+					   ntohs(svc->port),
+					   svc->scheduler->name);
+#endif
+			}
+		} else {
 			seq_printf(seq, "FWM  %08X %s ",
 				   svc->fwmark, svc->scheduler->name);
+		}
 
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
 			seq_printf(seq, "persistent %d %08X\n",
@@ -1769,13 +1781,24 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 			seq_putc(seq, '\n');
 
 		list_for_each_entry(dest, &svc->destinations, n_list) {
-			seq_printf(seq,
-				   "  -> %08X:%04X      %-7s %-6d %-10d %-10d\n",
-				   ntohl(dest->addr), ntohs(dest->port),
-				   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
-				   atomic_read(&dest->weight),
-				   atomic_read(&dest->activeconns),
-				   atomic_read(&dest->inactconns));
+			if (dest->af == AF_INET)
+				seq_printf(seq,
+					   "  -> %08X:%04X      %-7s %-6d %-10d %-10d\n",
+					   ntohl(dest->addr.ip), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+#ifdef CONFIG_IP_VS_IPV6
+			else if (dest->af == AF_INET6)
+				seq_printf(seq,
+					   "  -> [" NIP6_FMT "]:%04X      %-7s %-6d %-10d %-10d\n",
+					   NIP6(dest->addr.in6), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+#endif
 		}
 	}
 	return 0;
-- 
1.5.4.5

