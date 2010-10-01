From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 08/12] [PATCH 08/12] IPVS: Add persistence engine data to /proc/net/ip_vs_conn
Date: Fri, 01 Oct 2010 23:35:25 +0900
Message-ID: <20101001143942.382352880@akiko.akashicho.tokyo.vergenet.net>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline; filename=0008-IPVS-Add-persistence-engine-data-to-proc-net-ip_vs_c.patch
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This shouldn't break compatibility with userspace as the new data
is at the end of the line.

I have confirmed that this doesn't break ipvsadm, the main (only?)
user-space user of this data.

Signed-off-by: Simon Horman <horms@verge.net.au>

---

* Jan Engelhardt suggested using netlink to do this, but it seems like
  overkill to me. I'm willing to be convinced otherwise.

v2
* Trivial rediff

Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-01 22:27:17.000000000 +0900
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-01 22:27:32.000000000 +0900
@@ -571,6 +571,7 @@ struct ip_vs_pe {
 	bool (*ct_match)(const struct ip_vs_conn_param *p,
 			 struct ip_vs_conn *ct);
 	u32 (*hashkey_raw)(const struct ip_vs_conn_param *p, u32 initval);
+	int (*show_pe_data)(const struct ip_vs_conn *cp, char *buf);
 };
 
 /*
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:27:17.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:27:32.000000000 +0900
@@ -938,30 +938,44 @@ static int ip_vs_conn_seq_show(struct se
 
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

