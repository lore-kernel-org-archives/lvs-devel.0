From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 12/12] IPVS: sip persistence engine
Date: Sun, 22 Aug 2010 21:45:09 +0900
Message-ID: <20100822124900.857987553@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_pe_sip.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Add the SIP callid as a key for persistence.

This allows multiple connections from the same IP address to be
differentiated on the basis of the callid.

When used in conjunction with the persistence mask, it allows connections
from different  IP addresses to be aggregated on the basis of the callid.

It is envisaged that a persistence mask of 0.0.0.0 will be a useful
setting.  That is, ignore the source IP address when checking for
persistence.

It is envisaged that this option will be used in conjunction with
one-packet scheduling.

This only works with UDP and cannot be made to work with TCP
within the current framework.

Signed-off-by: Simon Horman <horms@verge.net.au>

v1
* Use buf[] instead of poiter arithmetic in ip_vs_dbg_callid()
  As suggested by Jan Engelhardt
Index: nf-next-2.6/net/netfilter/ipvs/Kconfig
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/Kconfig	2010-08-04 16:58:26.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/Kconfig	2010-08-20 22:34:19.000000000 +0900
@@ -247,4 +247,11 @@ config	IP_VS_FTP
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config	IP_VS_PE_SIP
+	tristate "SIP persistence engine"
+        depends on IP_VS_PROTO_UDP
+	depends on NF_CONNTRACK_SIP
+	---help---
+	  Allow persistence based on the SIP Call-ID
+
 endif # IP_VS
Index: nf-next-2.6/net/netfilter/ipvs/Makefile
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/Makefile	2010-08-20 21:57:56.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/Makefile	2010-08-20 22:34:19.000000000 +0900
@@ -32,3 +32,6 @@ obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
 
 # IPVS application helpers
 obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
+
+# IPVS connection template retrievers
+obj-$(CONFIG_IP_VS_PE_SIP) += ip_vs_pe_sip.o
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_pe_sip.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_pe_sip.c	2010-08-20 22:35:12.000000000 +0900
@@ -0,0 +1,167 @@
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include <net/ip_vs.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <linux/netfilter/nf_conntrack_sip.h>
+
+static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
+				    const char *callid, size_t callid_len,
+				    int *idx)
+{
+	size_t len = min(min(callid_len, (size_t)64), buf_len - *idx - 1);
+	memcpy(buf + *idx, callid, len);
+	buf[*idx+len] = '\0';
+	*idx += len + 1;
+	return buf + *idx - len;
+}
+
+#define IP_VS_DEBUG_CALLID(callid, len)					\
+	ip_vs_dbg_callid(ip_vs_dbg_buf, sizeof(ip_vs_dbg_buf),		\
+			 callid, len, &ip_vs_dbg_idx)
+
+static int get_callid(const char *dptr, unsigned int dataoff,
+		      unsigned int datalen,
+		      unsigned int *matchoff, unsigned int *matchlen)
+{
+	/* Find callid */
+	while (1) {
+		int ret = ct_sip_get_header(NULL, dptr, dataoff, datalen,
+					    SIP_HDR_CALL_ID, matchoff,
+					    matchlen);
+		if (ret > 0)
+			break;
+		if (!ret)
+			return 0;
+		dataoff += *matchoff;
+	}
+
+	/* Empty callid is useless */
+	if (!*matchlen)
+		return -EINVAL;
+
+	/* Too large is useless */
+	if (*matchlen > IP_VS_PEDATA_MAXLEN)
+		return -EINVAL;
+
+	/* SIP headers are always followed by a line terminator */
+	if (*matchoff + *matchlen == datalen)
+		return -EINVAL;
+
+	/* RFC 2543 allows lines to be terminated with CR, LF or CRLF,
+	 * RFC 3261 allows only CRLF, we support both. */
+	if (*(dptr + *matchoff + *matchlen) != '\r' &&
+	    *(dptr + *matchoff + *matchlen) != '\n')
+		return -EINVAL;
+
+	IP_VS_DBG_BUF(9, "SIP callid %s (%d bytes)\n",
+		      IP_VS_DEBUG_CALLID(dptr + *matchoff, *matchlen),
+		      *matchlen);
+	return 0;
+}
+
+static int
+ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
+{
+	struct ip_vs_iphdr iph;
+	unsigned int dataoff, datalen, matchoff, matchlen;
+	const char *dptr;
+
+	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
+
+	/* Only useful with UDP */
+	if (iph.protocol != IPPROTO_UDP)
+		return -EINVAL;
+
+	/* No Data ? */
+	dataoff = iph.len + sizeof(struct udphdr);
+	if (dataoff >= skb->len)
+		return -EINVAL;
+
+	dptr = skb->data + dataoff;
+	datalen = skb->len - dataoff;
+
+	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
+		return -EINVAL;
+
+	p->pe_data = kmalloc(matchlen, GFP_KERNEL);
+	if (!p->pe_data)
+		return -ENOMEM;
+
+	/* N.B: pe_data is only set on success,
+	 * this alows fallback to the default persistance logic on failure
+	 */
+	memcpy(p->pe_data, dptr + matchoff, matchlen);
+	p->pe_data_len = matchlen;
+
+	return 0;
+}
+
+static bool ip_vs_sip_ct_match(const struct ip_vs_conn_param *p,
+				  struct ip_vs_conn *ct)
+
+{
+	bool ret = 0;
+
+	if (ct->af == p->af &&
+	    ip_vs_addr_equal(p->af, p->caddr, &ct->caddr) &&
+	    /* protocol should only be IPPROTO_IP if
+	     * d_addr is a fwmark */
+	    ip_vs_addr_equal(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
+			     p->vaddr, &ct->vaddr) &&
+	    ct->vport == p->vport &&
+	    ct->flags & IP_VS_CONN_F_TEMPLATE &&
+	    ct->protocol == p->protocol &&
+	    ct->pe_data && ct->pe_data_len == p->pe_data_len &&
+	    !strnicmp(ct->pe_data, p->pe_data, p->pe_data_len))
+		ret = 1;
+
+	IP_VS_DBG_BUF(9, "SIP template match %s %s->%s:%d %s\n",
+		      ip_vs_proto_name(p->protocol),
+		      IP_VS_DEBUG_CALLID(p->pe_data, p->pe_data_len),
+		      IP_VS_DBG_ADDR(p->af, p->vaddr), ntohs(p->vport),
+		      ret ? "hit" : "not hit");
+
+	return ret;
+}
+
+static u32 ip_vs_sip_hashkey_raw(const struct ip_vs_conn_param *p,
+				 u32 initval)
+{
+	return jhash(p->pe_data, p->pe_data_len, initval);
+}
+
+static int ip_vs_sip_show_pe_data(const struct ip_vs_conn *cp, char *buf)
+{
+	memcpy(buf, cp->pe_data, cp->pe_data_len);
+	return cp->pe_data_len;
+}
+
+static struct ip_vs_pe ip_vs_sip_pe =
+{
+	.name =			"sip",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_sip_pe.n_list),
+	.fill_param =		ip_vs_sip_fill_param,
+	.ct_match =		ip_vs_sip_ct_match,
+	.hashkey_raw =		ip_vs_sip_hashkey_raw,
+	.show_pe_data =	ip_vs_sip_show_pe_data,
+};
+
+static int __init ip_vs_sip_init(void)
+{
+	return register_ip_vs_pe(&ip_vs_sip_pe);
+}
+
+static void __exit ip_vs_sip_cleanup(void)
+{
+	unregister_ip_vs_pe(&ip_vs_sip_pe);
+}
+
+module_init(ip_vs_sip_init);
+module_exit(ip_vs_sip_cleanup);
+MODULE_LICENSE("GPL");

