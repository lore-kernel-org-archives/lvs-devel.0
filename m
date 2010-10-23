From: Simon Horman <horms@verge.net.au>
Subject: [patch 4/9] IPVS: Add persistence engine to connection entry
Date: Sun, 24 Oct 2010 00:26:30 +0900
Message-ID: <20101023153020.447110221@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-conn-pe-2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

The dest of a connection may not exist if it has been created as the result
of connection synchronisation. But in order for connection entries for
templates with persistence engine data created through connection
synchronisation to be valid access to the persistence engine pointer is
required.  So add the persistence engine to the connection itself.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-15 08:12:46.000000000 +0900
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-15 08:14:35.000000000 +0900
@@ -421,6 +421,7 @@ struct ip_vs_conn {
 	struct ip_vs_seq        in_seq;         /* incoming seq. struct */
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
 
+	const struct ip_vs_pe	*pe;
 	char			*pe_data;
 	__u8			pe_data_len;
 };
@@ -801,8 +802,19 @@ void ip_vs_bind_pe(struct ip_vs_service
 void ip_vs_unbind_pe(struct ip_vs_service *svc);
 int register_ip_vs_pe(struct ip_vs_pe *pe);
 int unregister_ip_vs_pe(struct ip_vs_pe *pe);
-extern struct ip_vs_pe *ip_vs_pe_get(const char *name);
-extern void ip_vs_pe_put(struct ip_vs_pe *pe);
+struct ip_vs_pe *ip_vs_pe_getbyname(const char *name);
+
+static inline void ip_vs_pe_get(const struct ip_vs_pe *pe)
+{
+	if (pe && pe->module)
+		__module_get(pe->module);
+}
+
+static inline void ip_vs_pe_put(const struct ip_vs_pe *pe)
+{
+	if (pe && pe->module)
+		module_put(pe->module);
+}
 
 /*
  *	IPVS protocol functions (from ip_vs_proto.c)
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-15 08:12:46.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-15 08:12:51.000000000 +0900
@@ -176,8 +176,8 @@ static unsigned int ip_vs_conn_hashkey_c
 	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
 			      NULL, 0, &p);
 
-	if (cp->dest && cp->dest->svc->pe) {
-		p.pe = cp->dest->svc->pe;
+	if (cp->pe) {
+		p.pe = cp->pe;
 		p.pe_data = cp->pe_data;
 		p.pe_data_len = cp->pe_data_len;
 	}
@@ -763,6 +763,7 @@ static void ip_vs_conn_expire(unsigned l
 		if (cp->flags & IP_VS_CONN_F_NFCT)
 			ip_vs_conn_drop_conntrack(cp);
 
+		ip_vs_pe_put(cp->pe);
 		kfree(cp->pe_data);
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
@@ -824,7 +825,9 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 			&cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
-	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe_data) {
+	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe) {
+		ip_vs_pe_get(p->pe);
+		cp->pe = p->pe;
 		cp->pe_data = p->pe_data;
 		cp->pe_data_len = p->pe_data_len;
 	}
@@ -956,15 +959,13 @@ static int ip_vs_conn_seq_show(struct se
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
-		if (cp->dest && cp->pe_data &&
-		    cp->dest->svc->pe->show_pe_data) {
+		if (cp->pe_data) {
 			pe_data[0] = ' ';
-			len = strlen(cp->dest->svc->pe->name);
-			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
+			len = strlen(cp->pe->name);
+			memcpy(pe_data + 1, cp->pe->name, len);
 			pe_data[len + 1] = ' ';
 			len += 2;
-			len += cp->dest->svc->pe->show_pe_data(cp,
-							       pe_data + len);
+			len += cp->pe->show_pe_data(cp, pe_data + len);
 		}
 		pe_data[len] = '\0';
 
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_pe.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_pe.c	2010-10-15 08:12:46.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_pe.c	2010-10-15 08:12:51.000000000 +0900
@@ -30,7 +30,7 @@ void ip_vs_unbind_pe(struct ip_vs_servic
 
 /* Get pe in the pe list by name */
 static struct ip_vs_pe *
-ip_vs_pe_getbyname(const char *pe_name)
+__ip_vs_pe_getbyname(const char *pe_name)
 {
 	struct ip_vs_pe *pe;
 
@@ -60,28 +60,22 @@ ip_vs_pe_getbyname(const char *pe_name)
 }
 
 /* Lookup pe and try to load it if it doesn't exist */
-struct ip_vs_pe *ip_vs_pe_get(const char *name)
+struct ip_vs_pe *ip_vs_pe_getbyname(const char *name)
 {
 	struct ip_vs_pe *pe;
 
 	/* Search for the pe by name */
-	pe = ip_vs_pe_getbyname(name);
+	pe = __ip_vs_pe_getbyname(name);
 
 	/* If pe not found, load the module and search again */
 	if (!pe) {
 		request_module("ip_vs_pe_%s", name);
-		pe = ip_vs_pe_getbyname(name);
+		pe = __ip_vs_pe_getbyname(name);
 	}
 
 	return pe;
 }
 
-void ip_vs_pe_put(struct ip_vs_pe *pe)
-{
-	if (pe && pe->module)
-		module_put(pe->module);
-}
-
 /* Register a pe in the pe list */
 int register_ip_vs_pe(struct ip_vs_pe *pe)
 {
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-15 08:12:46.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-15 08:12:51.000000000 +0900
@@ -1149,7 +1149,7 @@ ip_vs_add_service(struct ip_vs_service_u
 	}
 
 	if (u->pe_name && *u->pe_name) {
-		pe = ip_vs_pe_get(u->pe_name);
+		pe = ip_vs_pe_getbyname(u->pe_name);
 		if (pe == NULL) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);
@@ -1260,7 +1260,7 @@ ip_vs_edit_service(struct ip_vs_service
 	old_sched = sched;
 
 	if (u->pe_name && *u->pe_name) {
-		pe = ip_vs_pe_get(u->pe_name);
+		pe = ip_vs_pe_getbyname(u->pe_name);
 		if (pe == NULL) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);

