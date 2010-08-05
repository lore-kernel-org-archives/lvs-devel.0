From: Simon Horman <horms@verge.net.au>
Subject: [rfc 13/13] [RFC 13/13] IPVS: sip persistence engine
Date: Thu, 05 Aug 2010 20:48:08 +0900
Message-ID: <20100805115242.056724322@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0013-IPVS-sip-persistence-engine.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

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
---
 net/netfilter/ipvs/Kconfig        |    7 ++
 net/netfilter/ipvs/Makefile       |    3 +
 net/netfilter/ipvs/ip_vs_pe_sip.c |  167 +++++++++++++++++++++++++++++++++++++
 3 files changed, 177 insertions(+), 0 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_pe_sip.c

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index be10f65..f7c5679 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
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
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index 53de6bd..19da19c 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -32,3 +32,6 @@ obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
 
 # IPVS application helpers
 obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
+
+# IPVS connection template retrievers
+obj-$(CONFIG_IP_VS_PE_SIP) += ip_vs_pe_sip.o
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
new file mode 100644
index 0000000..757d7fa
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
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
+	*(buf + *idx + len) = '\0';
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
-- 
1.7.1


