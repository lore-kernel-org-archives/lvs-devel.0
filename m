From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 09/12] [PATCH 09/12] IPVS: management of persistence engine modules
Date: Fri, 01 Oct 2010 23:35:26 +0900
Message-ID: <20101001143942.466778963@akiko.akashicho.tokyo.vergenet.net>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0009-IPVS-management-of-persistence-engine-modules.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This is based heavily on the scheduler management code

Signed-off-by: Simon Horman <horms@verge.net.au>

---

v0.4
* Export register_ip_vs_pe and unregister_ip_vs_pe
* Use one line comment format for one line comments.
* Only use at most one blank line consecutively

v1
* As suggested by Stephen Hemminger
  - Convert __ip_vs_pe_lock from a rwlock to a spinlock.
    This code isn't performance-critical, so there is no need for RCU.
  - Rename __ip_vs_pe_lock as ip_vs_pe_lock
* Stephen also suggested open-coding ip_vs_{un,}bind_pe()
  as they are very short. But I would prefer to keep them as they are used
  along side ip_vs_{un,}bind_scheduler which are too long to be open-coded.

v2
* Update for recent addition of ip_vs_nfct.c
* Trivial rediff

Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-01 22:27:32.000000000 +0900
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-01 22:30:16.000000000 +0900
@@ -795,6 +795,12 @@ extern int ip_vs_app_pkt_in(struct ip_vs
 extern int ip_vs_app_init(void);
 extern void ip_vs_app_cleanup(void);
 
+void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
+void ip_vs_unbind_pe(struct ip_vs_service *svc);
+int register_ip_vs_pe(struct ip_vs_pe *pe);
+int unregister_ip_vs_pe(struct ip_vs_pe *pe);
+extern struct ip_vs_pe *ip_vs_pe_get(const char *name);
+extern void ip_vs_pe_put(struct ip_vs_pe *pe);
 
 /*
  *	IPVS protocol functions (from ip_vs_proto.c)
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_pe.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_pe.c	2010-10-01 22:30:16.000000000 +0900
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
+static DEFINE_SPINLOCK(ip_vs_pe_lock);
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
+	spin_lock_bh(&ip_vs_pe_lock);
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
+			spin_unlock_bh(&ip_vs_pe_lock);
+			return pe;
+		}
+		if (pe->module)
+			module_put(pe->module);
+	}
+
+	spin_unlock_bh(&ip_vs_pe_lock);
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
+	spin_lock_bh(&ip_vs_pe_lock);
+
+	if (!list_empty(&pe->n_list)) {
+		spin_unlock_bh(&ip_vs_pe_lock);
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
+			spin_unlock_bh(&ip_vs_pe_lock);
+			ip_vs_use_count_dec();
+			pr_err("%s(): [%s] pe already existed "
+			       "in the system\n", __func__, pe->name);
+			return -EINVAL;
+		}
+	}
+	/* Add it into the d-linked pe list */
+	list_add(&pe->n_list, &ip_vs_pe);
+	spin_unlock_bh(&ip_vs_pe_lock);
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
+	spin_lock_bh(&ip_vs_pe_lock);
+	if (list_empty(&pe->n_list)) {
+		spin_unlock_bh(&ip_vs_pe_lock);
+		pr_err("%s(): [%s] pe is not in the list. failed\n",
+		       __func__, pe->name);
+		return -EINVAL;
+	}
+
+	/* Remove it from the d-linked pe list */
+	list_del(&pe->n_list);
+	spin_unlock_bh(&ip_vs_pe_lock);
+
+	/* decrease the module use count */
+	ip_vs_use_count_dec();
+
+	pr_info("[%s] pe unregistered.\n", pe->name);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(unregister_ip_vs_pe);
Index: lvs-test-2.6/net/netfilter/ipvs/Makefile
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/Makefile	2010-10-01 22:30:26.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/Makefile	2010-10-01 22:30:59.000000000 +0900
@@ -14,7 +14,7 @@ ip_vs-extra_objs-$(CONFIG_IP_VS_NFCT) +=
 
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
-		ip_vs_est.o ip_vs_proto.o 				   \
+		ip_vs_est.o ip_vs_proto.o ip_vs_pe.o			   \
 		$(ip_vs_proto-objs-y) $(ip_vs-extra_objs-y)
 
 

