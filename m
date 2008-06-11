From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 25/26] IPVS: Add support for IPv6 entry output in procfs files.
Date: Wed, 11 Jun 2008 19:12:08 +0200
Message-ID: <1213204329-10973-26-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=A7wQSDhFDLbcIfSxXVL3440xTHw=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=Alz5lAZsJvhSV3T4ZYcFY+MV3FWSZ0oiqy8RbIvd
	iGNxxbArBzZ+MRR9mYw+htUGVkZhjqZhP9dWoyUQy6eZqg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Add support for procfs output of IPv6 service and connection entries.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 388278a..c6b737c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2104,15 +2104,26 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
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
+					   ntohl(svc->addr.v4),
+					   ntohs(svc->port),
+					   svc->scheduler->name);
+			} else if (svc->af == AF_INET6) {
+#ifdef CONFIG_IP_VS_IPV6
+				seq_printf(seq, "%s  [" NIP6_FMT "]:%04X %s ",
+					   ip_vs_proto_name(svc->protocol),
+					   NIP6(svc->addr.v6),
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
@@ -2122,13 +2133,24 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
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
+					   ntohl(dest->addr.v4), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+#ifdef CONFIG_IP_VS_IPV6
+			else if (dest->af == AF_INET6)
+				seq_printf(seq,
+					   "  -> [" NIP6_FMT "]:%04X      %-7s %-6d %-10d %-10d\n",
+					   NIP6(dest->addr.v6), ntohs(dest->port),
+					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+					   atomic_read(&dest->weight),
+					   atomic_read(&dest->activeconns),
+					   atomic_read(&dest->inactconns));
+#endif
 		}
 	}
 	return 0;
-- 
1.5.3.6

