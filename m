From: Simon Horman <horms@verge.net.au>
Subject: [rfc 09/13] [RFC 09/13] IPVS: Add persistence engine data to /proc/net/ip_vs_conn
Date: Thu, 05 Aug 2010 20:48:04 +0900
Message-ID: <20100805115241.289541021@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline; filename=0009-IPVS-Add-persistence-engine-data-to-proc-net-ip_vs_c.patch
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This shouldn't break compatibility with userspace as the new data
is at the end of the line.

I have confirmed that this doesn't break ipvsadm, the main (only?)
user-space user of this data.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_conn.c |   24 +++++++++++++++++++-----
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d072068..cf1f633 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -569,6 +569,7 @@ struct ip_vs_pe {
 	bool (*ct_match)(const struct ip_vs_conn_param *p,
 			 struct ip_vs_conn *ct);
 	u32 (*hashkey_raw)(const struct ip_vs_conn_param *p, u32 initval);
+	int (*show_pe_data)(const struct ip_vs_conn *cp, char *buf);
 };
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 59e6903..db5e0fd 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -921,30 +921,44 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
-   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
+   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires PEName PEData\n");
 	else {
 		const struct ip_vs_conn *cp = v;
+		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
+		size_t len = 0;
+
+		if (cp->dest->svc->pe && cp->dest->svc->pe->show_pe_data) {
+			pe_data[0] = ' ';
+			len = strlen(cp->dest->svc->pe->name);
+			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
+			pe_data[len + 1] = ' ';
+			len += 2;
+			len += cp->dest->svc->pe->show_pe_data(cp,
+							       pe_data + len);
+		}
+		pe_data[len] = '\0';
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %7lu\n",
+			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X "
+				"%pI6 %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
 				&cp->daddr.in6, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
-				(cp->timer.expires-jiffies)/HZ);
+				(cp->timer.expires-jiffies)/HZ, pe_data);
 		else
 #endif
 			seq_printf(seq,
 				"%-3s %08X %04X %08X %04X"
-				" %08X %04X %-11s %7lu\n",
+				" %08X %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
 				ntohl(cp->daddr.ip), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
-				(cp->timer.expires-jiffies)/HZ);
+				(cp->timer.expires-jiffies)/HZ, pe_data);
 	}
 	return 0;
 }
-- 
1.7.1


