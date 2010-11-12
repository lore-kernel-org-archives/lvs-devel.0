From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 3/9] IPVS: Add persistence engine to connection entry
Date: Fri, 12 Nov 2010 08:34:55 +0100
Message-ID: <1289547301-28015-3-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Simon Horman <horms@verge.net.au>

The dest of a connection may not exist if it has been created as the result
of connection synchronisation. But in order for connection entries for
templates with persistence engine data created through connection
synchronisation to be valid access to the persistence engine pointer is
required.  So add the persistence engine to the connection itself.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |   16 ++++++++++++++--
 net/netfilter/ipvs/ip_vs_conn.c |   19 ++++++++++---------
 net/netfilter/ipvs/ip_vs_ctl.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_pe.c   |   14 ++++----------
 4 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1cc1c36..a6421e6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -423,6 +423,7 @@ struct ip_vs_conn {
 	struct ip_vs_seq        in_seq;         /* incoming seq. struct */
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
 
+	const struct ip_vs_pe	*pe;
 	char			*pe_data;
 	__u8			pe_data_len;
 };
@@ -815,8 +816,19 @@ void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
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
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b64e0b2..1d5cead 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -176,8 +176,8 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
 			      NULL, 0, &p);
 
-	if (cp->dest && cp->dest->svc->pe) {
-		p.pe = cp->dest->svc->pe;
+	if (cp->pe) {
+		p.pe = cp->pe;
 		p.pe_data = cp->pe_data;
 		p.pe_data_len = cp->pe_data_len;
 	}
@@ -765,6 +765,7 @@ static void ip_vs_conn_expire(unsigned long data)
 		if (cp->flags & IP_VS_CONN_F_NFCT)
 			ip_vs_conn_drop_conntrack(cp);
 
+		ip_vs_pe_put(cp->pe);
 		kfree(cp->pe_data);
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
@@ -827,7 +828,9 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	cp->fwmark         = fwmark;
-	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe_data) {
+	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe) {
+		ip_vs_pe_get(p->pe);
+		cp->pe = p->pe;
 		cp->pe_data = p->pe_data;
 		cp->pe_data_len = p->pe_data_len;
 	}
@@ -959,15 +962,13 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
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
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0129b52..a5bd002 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1139,7 +1139,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 
 	if (u->pe_name && *u->pe_name) {
-		pe = ip_vs_pe_get(u->pe_name);
+		pe = ip_vs_pe_getbyname(u->pe_name);
 		if (pe == NULL) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);
@@ -1250,7 +1250,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	old_sched = sched;
 
 	if (u->pe_name && *u->pe_name) {
-		pe = ip_vs_pe_get(u->pe_name);
+		pe = ip_vs_pe_getbyname(u->pe_name);
 		if (pe == NULL) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index baab44f..cf549a0 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -30,7 +30,7 @@ void ip_vs_unbind_pe(struct ip_vs_service *svc)
 
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
