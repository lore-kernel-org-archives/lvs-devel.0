From: Simon Horman <horms@verge.net.au>
Subject: [rfc 10/13] [RFC 10/13] IPVS: management of persistence engine modules
Date: Thu, 05 Aug 2010 20:48:05 +0900
Message-ID: <20100805115241.482096330@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0010-IPVS-management-of-persistence-engine-modules.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This is based heavily on the scheduler management code

Signed-off-by: Simon Horman <horms@verge.net.au>

v0.4
* Export register_ip_vs_pe and unregister_ip_vs_pe
* Use one line comment format for one line comments.
* Only use at most one blank line consecutively
---
 include/net/ip_vs.h           |    6 ++
 net/netfilter/ipvs/Makefile   |    2 +-
 net/netfilter/ipvs/ip_vs_pe.c |  147 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 1 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_pe.c

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cf1f633..0834aee 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -831,6 +831,12 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb);
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_protocol *pp);
 
+void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
+void ip_vs_unbind_pe(struct ip_vs_service *svc);
+int register_ip_vs_pe(struct ip_vs_pe *pe);
+int unregister_ip_vs_pe(struct ip_vs_pe *pe);
+extern struct ip_vs_pe *ip_vs_pe_get(const char *name);
+extern void ip_vs_pe_put(struct ip_vs_pe *pe);
 
 /*
  *      IPVS control data and functions (from ip_vs_ctl.c)
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index e3baefd..53de6bd 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -11,7 +11,7 @@ ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_SCTP) += ip_vs_proto_sctp.o
 
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
-		ip_vs_est.o ip_vs_proto.o 				   \
+		ip_vs_est.o ip_vs_proto.o ip_vs_pe.o		   \
 		$(ip_vs_proto-objs-y)
 
 
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
new file mode 100644
index 0000000..3842928
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -0,0 +1,147 @@
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+#include <asm/string.h>
+#include <linux/kmod.h>
+#include <linux/sysctl.h>
+
+#include <net/ip_vs.h>
+
+/* IPVS pe list */
+static LIST_HEAD(ip_vs_pe);
+
+/* lock for service table */
+static DEFINE_RWLOCK(__ip_vs_pe_lock);
+
+/* Bind a service with a pe */
+void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
+{
+	svc->pe = pe;
+}
+
+/* Unbind a service from its pe */
+void ip_vs_unbind_pe(struct ip_vs_service *svc)
+{
+	svc->pe = NULL;
+}
+
+/* Get pe in the pe list by name */
+static struct ip_vs_pe *
+ip_vs_pe_getbyname(const char *pe_name)
+{
+	struct ip_vs_pe *pe;
+
+	IP_VS_DBG(2, "%s(): pe_name \"%s\"\n", __func__,
+		  pe_name);
+
+	read_lock_bh(&__ip_vs_pe_lock);
+
+	list_for_each_entry(pe, &ip_vs_pe, n_list) {
+		/* Test and get the modules atomically */
+		if (pe->module &&
+		    !try_module_get(pe->module)) {
+			/* This pe is just deleted */
+			continue;
+		}
+		if (strcmp(pe_name, pe->name)==0) {
+			/* HIT */
+			read_unlock_bh(&__ip_vs_pe_lock);
+			return pe;
+		}
+		if (pe->module)
+			module_put(pe->module);
+	}
+
+	read_unlock_bh(&__ip_vs_pe_lock);
+	return NULL;
+}
+
+/* Lookup pe and try to load it if it doesn't exist */
+struct ip_vs_pe *ip_vs_pe_get(const char *name)
+{
+	struct ip_vs_pe *pe;
+
+	/* Search for the pe by name */
+	pe = ip_vs_pe_getbyname(name);
+
+	/* If pe not found, load the module and search again */
+	if (!pe) {
+		request_module("ip_vs_pe_%s", name);
+		pe = ip_vs_pe_getbyname(name);
+	}
+
+	return pe;
+}
+
+void ip_vs_pe_put(struct ip_vs_pe *pe)
+{
+	if (pe && pe->module)
+		module_put(pe->module);
+}
+
+/* Register a pe in the pe list */
+int register_ip_vs_pe(struct ip_vs_pe *pe)
+{
+	struct ip_vs_pe *tmp;
+
+	/* increase the module use count */
+	ip_vs_use_count_inc();
+
+	write_lock_bh(&__ip_vs_pe_lock);
+
+	if (!list_empty(&pe->n_list)) {
+		write_unlock_bh(&__ip_vs_pe_lock);
+		ip_vs_use_count_dec();
+		pr_err("%s(): [%s] pe already linked\n",
+		       __func__, pe->name);
+		return -EINVAL;
+	}
+
+	/* Make sure that the pe with this name doesn't exist
+	 * in the pe list.
+	 */
+	list_for_each_entry(tmp, &ip_vs_pe, n_list) {
+		if (strcmp(tmp->name, pe->name) == 0) {
+			write_unlock_bh(&__ip_vs_pe_lock);
+			ip_vs_use_count_dec();
+			pr_err("%s(): [%s] pe already existed "
+			       "in the system\n", __func__, pe->name);
+			return -EINVAL;
+		}
+	}
+	/* Add it into the d-linked pe list */
+	list_add(&pe->n_list, &ip_vs_pe);
+	write_unlock_bh(&__ip_vs_pe_lock);
+
+	pr_info("[%s] pe registered.\n", pe->name);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(register_ip_vs_pe);
+
+/* Unregister a pe from the pe list */
+int unregister_ip_vs_pe(struct ip_vs_pe *pe)
+{
+	write_lock_bh(&__ip_vs_pe_lock);
+	if (list_empty(&pe->n_list)) {
+		write_unlock_bh(&__ip_vs_pe_lock);
+		pr_err("%s(): [%s] pe is not in the list. failed\n",
+		       __func__, pe->name);
+		return -EINVAL;
+	}
+
+	/* Remove it from the d-linked pe list */
+	list_del(&pe->n_list);
+	write_unlock_bh(&__ip_vs_pe_lock);
+
+	/* decrease the module use count */
+	ip_vs_use_count_dec();
+
+	pr_info("[%s] pe unregistered.\n", pe->name);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(unregister_ip_vs_pe);
-- 
1.7.1


