From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 24 May 2013 13:09:35 +0100
Message-ID: <20130524120935.GL264@eldamar.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="98e8jtXdkpgskNou"
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org


--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I've added some features that I needed for our purposes to LVS, and I'd
like to submit a patch, in case they might be useful to other users.

The patch is against the Ubuntu 12.04 kernel (3.2.0).

The patch adds three features:

1.  Sloppy TCP handling.  When enabled (net.ipv4.vs.sloppy_tcp=1,
default 0), it allows IPVS to create a TCP connection state on any TCP
packet, not just a SYN.  This allows connections to fail over to a
different director (our plan is to run multiple directors active-active)
without being reset.

2. SH rebalancing.  When enabled (net.ipv4.vs.sh_rebalance=1, default
0), virtual servers using SH (or SHP --- see below) scheduling will
retry the realserver selection if the realserver selected the first time
round is unavailable (e.g., because it has weight 0).  This allows
realservers to be paused on SH(P) virtual servers by setting the weight
to 0.

3. SHP (SH + port) scheduler.  This is a clone of the SH code, but
hacked to also take the port number (TCP, UDP, SCTP) into account.  This
may seem no different to round-robin, but in our scenario, if a
connection is failed over to a different director, this guarantees that
it will continue being forwarded to the same realserver.


Alex


--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Description: ipvs.patch
Content-Disposition: attachment; filename="ocado-ipvs.patch"

diff -Nupr linux-source-3.2.0/include/net/ip_vs.h linux-source-3.2.0-patched/include/net/ip_vs.h
--- linux-source-3.2.0/include/net/ip_vs.h	2012-01-04 23:55:44.000000000 +0000
+++ linux-source-3.2.0-patched/include/net/ip_vs.h	2013-05-17 14:44:58.000000000 +0100
@@ -871,6 +871,8 @@ struct netns_ipvs {
 	int			sysctl_sync_ver;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
+	int			sysctl_sloppy_tcp;
+	int			sysctl_sh_rebalance;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
 	int			sysctl_nat_icmp_send;
@@ -911,6 +913,8 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
+#define DEFAULT_SLOPPY_TCP	0
+#define DEFAULT_SH_REBALANCE	0
 
 #ifdef CONFIG_SYSCTL
 
@@ -929,6 +933,16 @@ static inline int sysctl_sync_ver(struct
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sloppy_tcp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sloppy_tcp;
+}
+
+static inline int sysctl_sh_rebalance(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sh_rebalance;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -946,6 +960,16 @@ static inline int sysctl_sync_ver(struct
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sloppy_tcp(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SLOPPY_TCP;
+}
+
+static inline int sysctl_sh_rebalance(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SH_REBALANCE;
+}
+
 #endif
 
 /*
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/Kconfig linux-source-3.2.0-patched/net/netfilter/ipvs/Kconfig
--- linux-source-3.2.0/net/netfilter/ipvs/Kconfig	2012-01-04 23:55:44.000000000 +0000
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/Kconfig	2013-05-17 14:44:58.000000000 +0100
@@ -206,6 +206,16 @@ config	IP_VS_SH
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config	IP_VS_SHP
+	tristate "layer 4 source hashing scheduling"
+	---help---
+	  The source hashing scheduling algorithm assigns network
+	  connections to the servers through looking up a statically assigned
+	  hash table by their source IP addresses and ports.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
 config	IP_VS_SED
 	tristate "shortest expected delay scheduling"
 	---help---
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/Makefile linux-source-3.2.0-patched/net/netfilter/ipvs/Makefile
--- linux-source-3.2.0/net/netfilter/ipvs/Makefile	2012-01-04 23:55:44.000000000 +0000
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/Makefile	2013-05-17 14:44:58.000000000 +0100
@@ -30,6 +30,7 @@ obj-$(CONFIG_IP_VS_LBLC) += ip_vs_lblc.o
 obj-$(CONFIG_IP_VS_LBLCR) += ip_vs_lblcr.o
 obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
 obj-$(CONFIG_IP_VS_SH) += ip_vs_sh.o
+obj-$(CONFIG_IP_VS_SHP) += ip_vs_shp.o
 obj-$(CONFIG_IP_VS_SED) += ip_vs_sed.o
 obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
 
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/ip_vs_ctl.c linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_ctl.c
--- linux-source-3.2.0/net/netfilter/ipvs/ip_vs_ctl.c	2012-09-26 22:32:28.000000000 +0100
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_ctl.c	2013-05-17 14:44:58.000000000 +0100
@@ -1730,6 +1730,18 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "sloppy_tcp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sh_rebalance",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "expire_quiescent_template",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3657,6 +3669,8 @@ int __net_init ip_vs_control_net_init_sy
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
+	tbl[idx++].data = &ipvs->sysctl_sloppy_tcp;
+	tbl[idx++].data = &ipvs->sysctl_sh_rebalance;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
 	ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
 	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/ip_vs_proto_tcp.c linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- linux-source-3.2.0/net/netfilter/ipvs/ip_vs_proto_tcp.c	2012-01-04 23:55:44.000000000 +0000
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_proto_tcp.c	2013-05-17 14:44:58.000000000 +0100
@@ -49,7 +49,7 @@ tcp_conn_schedule(int af, struct sk_buff
 	}
 	net = skb_net(skb);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
-	if (th->syn &&
+	if ((sysctl_sloppy_tcp(net_ipvs(net)) || th->syn) &&
 	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
 				     &iph.daddr, th->dest))) {
 		int ignored;
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/ip_vs_sh.c linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_sh.c
--- linux-source-3.2.0/net/netfilter/ipvs/ip_vs_sh.c	2012-01-04 23:55:44.000000000 +0000
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_sh.c	2013-05-17 14:44:58.000000000 +0100
@@ -65,7 +65,7 @@ struct ip_vs_sh_bucket {
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr, int offset)
 {
 	__be32 addr_fold = addr->ip;
 
@@ -74,7 +74,7 @@ static inline unsigned ip_vs_sh_hashkey(
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	return (offset + ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
 }
 
 
@@ -83,9 +83,9 @@ static inline unsigned ip_vs_sh_hashkey(
  */
 static inline struct ip_vs_dest *
 ip_vs_sh_get(int af, struct ip_vs_sh_bucket *tbl,
-	     const union nf_inet_addr *addr)
+	     const union nf_inet_addr *addr, int offset)
 {
-	return (tbl[ip_vs_sh_hashkey(af, addr)]).dest;
+	return (tbl[ip_vs_sh_hashkey(af, addr, offset)]).dest;
 }
 
 
@@ -211,14 +211,36 @@ ip_vs_sh_schedule(struct ip_vs_service *
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_bucket *tbl;
 	struct ip_vs_iphdr iph;
+	int offset;
+	int found;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
 	tbl = (struct ip_vs_sh_bucket *)svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr);
-	if (!dest
+	if(sysctl_sh_rebalance(net_ipvs(svc->net))) {
+		found = 0;
+		for(offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+			dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr, offset);
+			if(!dest
+			   || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
+			   || atomic_read(&dest->weight) <= 0
+			   || is_overloaded(dest)) {
+				IP_VS_DBG_BUF(6, "SH: Selected unavailable server %s:%d, retrying with offset %d\n",
+		      			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+					      ntohs(dest->port), offset);
+			} else {
+				found = 1;
+				break;
+			}
+		}
+	} else {
+		dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr, 0);
+		found = 1;
+	}
+	if (!found
+	    || !dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
 	    || is_overloaded(dest)) {
diff -Nupr linux-source-3.2.0/net/netfilter/ipvs/ip_vs_shp.c linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_shp.c
--- linux-source-3.2.0/net/netfilter/ipvs/ip_vs_shp.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-source-3.2.0-patched/net/netfilter/ipvs/ip_vs_shp.c	2013-05-17 14:45:09.000000000 +0100
@@ -0,0 +1,299 @@
+/*
+ * IPVS:        SHP scheduling module
+ *
+ * Authors:     Alexander Frolkin <avf@eldamar.org.uk>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Changes:
+ *
+ */
+
+/*
+ * This is simply the SH module but hacked to also include the source port
+ * in the hash calculation.
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/ip.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+
+#include <net/ip_vs.h>
+
+#include <net/tcp.h>
+#include <linux/udp.h>
+#include <linux/sctp.h>
+
+/*
+ *      IPVS SHP bucket
+ */
+struct ip_vs_shp_bucket {
+	struct ip_vs_dest       *dest;          /* real server (cache) */
+};
+
+/*
+ *     for IPVS SHP entry hash table
+ */
+#ifndef CONFIG_IP_VS_SHP_TAB_BITS
+#define CONFIG_IP_VS_SHP_TAB_BITS        8
+#endif
+#define IP_VS_SHP_TAB_BITS               CONFIG_IP_VS_SHP_TAB_BITS
+#define IP_VS_SHP_TAB_SIZE               (1 << IP_VS_SHP_TAB_BITS)
+#define IP_VS_SHP_TAB_MASK               (IP_VS_SHP_TAB_SIZE - 1)
+
+
+/*
+ *	Returns hash value for IPVS SHP entry
+ */
+static inline unsigned ip_vs_shp_hashkey(int af, const union nf_inet_addr *addr, unsigned int port, int offset)
+{
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+	return (offset + (port + ntohl(addr_fold))*2654435761UL) & IP_VS_SHP_TAB_MASK;
+}
+
+
+/*
+ *      Get ip_vs_dest associated with supplied parameters.
+ */
+static inline struct ip_vs_dest *
+ip_vs_shp_get(int af, struct ip_vs_shp_bucket *tbl,
+	     const union nf_inet_addr *addr, unsigned int port, int offset)
+{
+	return (tbl[ip_vs_shp_hashkey(af, addr, port, offset)]).dest;
+}
+
+
+/*
+ *      Assign all the hash buckets of the specified table with the service.
+ */
+static int
+ip_vs_shp_assign(struct ip_vs_shp_bucket *tbl, struct ip_vs_service *svc)
+{
+	int i;
+	struct ip_vs_shp_bucket *b;
+	struct list_head *p;
+	struct ip_vs_dest *dest;
+
+	b = tbl;
+	p = &svc->destinations;
+	for (i=0; i<IP_VS_SHP_TAB_SIZE; i++) {
+		if (list_empty(p)) {
+			b->dest = NULL;
+		} else {
+			if (p == &svc->destinations)
+				p = p->next;
+
+			dest = list_entry(p, struct ip_vs_dest, n_list);
+			atomic_inc(&dest->refcnt);
+			b->dest = dest;
+
+			p = p->next;
+		}
+		b++;
+	}
+	return 0;
+}
+
+
+/*
+ *      Flush all the hash buckets of the specified table.
+ */
+static void ip_vs_shp_flush(struct ip_vs_shp_bucket *tbl)
+{
+	int i;
+	struct ip_vs_shp_bucket *b;
+
+	b = tbl;
+	for (i=0; i<IP_VS_SHP_TAB_SIZE; i++) {
+		if (b->dest) {
+			atomic_dec(&b->dest->refcnt);
+			b->dest = NULL;
+		}
+		b++;
+	}
+}
+
+
+static int ip_vs_shp_init_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_shp_bucket *tbl;
+
+	/* allocate the SHP table for this service */
+	tbl = kmalloc(sizeof(struct ip_vs_shp_bucket)*IP_VS_SHP_TAB_SIZE,
+		      GFP_ATOMIC);
+	if (tbl == NULL)
+		return -ENOMEM;
+
+	svc->sched_data = tbl;
+	IP_VS_DBG(6, "SHP hash table (memory=%Zdbytes) allocated for "
+		  "current service\n",
+		  sizeof(struct ip_vs_shp_bucket)*IP_VS_SHP_TAB_SIZE);
+
+	/* assign the hash buckets with the updated service */
+	ip_vs_shp_assign(tbl, svc);
+
+	return 0;
+}
+
+
+static int ip_vs_shp_done_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_shp_bucket *tbl = svc->sched_data;
+
+	/* got to clean up hash buckets here */
+	ip_vs_shp_flush(tbl);
+
+	/* release the table itself */
+	kfree(svc->sched_data);
+	IP_VS_DBG(6, "SHP hash table (memory=%Zdbytes) released\n",
+		  sizeof(struct ip_vs_shp_bucket)*IP_VS_SHP_TAB_SIZE);
+
+	return 0;
+}
+
+
+static int ip_vs_shp_update_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_shp_bucket *tbl = svc->sched_data;
+
+	/* got to clean up hash buckets here */
+	ip_vs_shp_flush(tbl);
+
+	/* assign the hash buckets with the updated service */
+	ip_vs_shp_assign(tbl, svc);
+
+	return 0;
+}
+
+
+/*
+ *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
+ *      consider that the server is overloaded here.
+ */
+static inline int is_overloaded(struct ip_vs_dest *dest)
+{
+	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+}
+
+
+/*
+ *      Source Hashing scheduling
+ */
+static struct ip_vs_dest *
+ip_vs_shp_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_shp_bucket *tbl;
+	struct ip_vs_iphdr iph;
+	struct tcphdr _tcph, *th;
+	struct udphdr _udph, *uh;
+	sctp_sctphdr_t _sctph, *sh;
+	unsigned int port;
+	int offset;
+	int found;
+
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+
+	IP_VS_DBG(6, "ip_vs_shp_schedule(): Scheduling...\n");
+
+	switch(svc->protocol) {
+		case IPPROTO_TCP:
+			th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
+			port = ntohs(th->source);
+			break;
+		case IPPROTO_UDP:
+			uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
+			port = ntohs(uh->source);
+			break;
+		case IPPROTO_SCTP:
+			sh = skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
+			port = ntohs(sh->source);
+			break;
+		default:
+			port = 0;
+	}
+
+	tbl = (struct ip_vs_shp_bucket *)svc->sched_data;
+	if(sysctl_sh_rebalance(net_ipvs(svc->net))) {
+		found = 0;
+		for(offset = 0; offset < IP_VS_SHP_TAB_SIZE; offset++) {
+			dest = ip_vs_shp_get(svc->af, tbl, &iph.saddr, port, offset);
+			if(!dest
+			   || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
+			   || atomic_read(&dest->weight) <= 0
+			   || is_overloaded(dest)) {
+				IP_VS_DBG_BUF(6, "SHP: Selected unavailable server %s:%d, retrying with offset %d\n",
+		      			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+					      ntohs(dest->port), offset);
+			} else {
+				found = 1;
+				break;
+			}
+		}
+	} else {
+		dest = ip_vs_shp_get(svc->af, tbl, &iph.saddr, port, 0);
+		found = 1;
+	}
+	if (!found
+	    || !dest
+	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
+	    || atomic_read(&dest->weight) <= 0
+	    || is_overloaded(dest)) {
+		ip_vs_scheduler_err(svc, "no destination available");
+		return NULL;
+	}
+
+	IP_VS_DBG_BUF(6, "SHP: source IP address %s --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      ntohs(dest->port));
+
+	return dest;
+}
+
+
+/*
+ *      IPVS SHP Scheduler structure
+ */
+static struct ip_vs_scheduler ip_vs_shp_scheduler =
+{
+	.name =			"shp",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list	 =		LIST_HEAD_INIT(ip_vs_shp_scheduler.n_list),
+	.init_service =		ip_vs_shp_init_svc,
+	.done_service =		ip_vs_shp_done_svc,
+	.update_service =	ip_vs_shp_update_svc,
+	.schedule =		ip_vs_shp_schedule,
+};
+
+
+static int __init ip_vs_shp_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_shp_scheduler);
+}
+
+
+static void __exit ip_vs_shp_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_shp_scheduler);
+}
+
+
+module_init(ip_vs_shp_init);
+module_exit(ip_vs_shp_cleanup);
+MODULE_LICENSE("GPL");

--98e8jtXdkpgskNou--
