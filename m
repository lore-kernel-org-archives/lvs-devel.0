From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvsadm: support 64-bit stats and rates
Date: Fri,  6 Feb 2015 09:45:04 +0200
Message-ID: <1423208704-11918-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Chris Caputo <ccaputo@alt.net>

Prefer the new netlink attributes IPVS_SVC_ATTR_STATS64 and
IPVS_DEST_ATTR_STATS64 for 64-bit conn/packet/bps/cps/pps stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

Nothing is changed from previous RFC version.
Should be applied after the kernel patch is accepted.

 ipvsadm.c         | 42 ++++++++++++++---------------
 libipvs/ip_vs.h   | 28 ++++++++++++++++++-
 libipvs/libipvs.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 121 insertions(+), 29 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 162d4a2..a33ecfa 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1585,18 +1585,18 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 		}
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
-		print_largenum(se->stats.conns, format);
-		print_largenum(se->stats.inpkts, format);
-		print_largenum(se->stats.outpkts, format);
-		print_largenum(se->stats.inbytes, format);
-		print_largenum(se->stats.outbytes, format);
+		print_largenum(se->stats64.conns, format);
+		print_largenum(se->stats64.inpkts, format);
+		print_largenum(se->stats64.outpkts, format);
+		print_largenum(se->stats64.inbytes, format);
+		print_largenum(se->stats64.outbytes, format);
 	} else if (format & FMT_RATE) {
 		printf("%-33s", svc_name);
-		print_largenum(se->stats.cps, format);
-		print_largenum(se->stats.inpps, format);
-		print_largenum(se->stats.outpps, format);
-		print_largenum(se->stats.inbps, format);
-		print_largenum(se->stats.outbps, format);
+		print_largenum(se->stats64.cps, format);
+		print_largenum(se->stats64.inpps, format);
+		print_largenum(se->stats64.outpps, format);
+		print_largenum(se->stats64.inbps, format);
+		print_largenum(se->stats64.outbps, format);
 	} else {
 		printf("%s %s", svc_name, se->sched_name);
 		if (se->flags & (IP_VS_SVC_F_SCHED1 |
@@ -1646,19 +1646,19 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			       fwd_switch(e->conn_flags), e->weight);
 		} else if (format & FMT_STATS) {
 			printf("  -> %-28s", dname);
-			print_largenum(e->stats.conns, format);
-			print_largenum(e->stats.inpkts, format);
-			print_largenum(e->stats.outpkts, format);
-			print_largenum(e->stats.inbytes, format);
-			print_largenum(e->stats.outbytes, format);
+			print_largenum(e->stats64.conns, format);
+			print_largenum(e->stats64.inpkts, format);
+			print_largenum(e->stats64.outpkts, format);
+			print_largenum(e->stats64.inbytes, format);
+			print_largenum(e->stats64.outbytes, format);
 			printf("\n");
 		} else if (format & FMT_RATE) {
-			printf("  -> %-28s %8u %8u %8u", dname,
-			       e->stats.cps,
-			       e->stats.inpps,
-			       e->stats.outpps);
-			print_largenum(e->stats.inbps, format);
-			print_largenum(e->stats.outbps, format);
+			printf("  -> %-28s %8llu %8llu %8llu", dname,
+			       e->stats64.cps,
+			       e->stats64.inpps,
+			       e->stats64.outpps);
+			print_largenum(e->stats64.inbps, format);
+			print_largenum(e->stats64.outbps, format);
 			printf("\n");
 		} else if (format & FMT_THRESHOLDS) {
 			printf("  -> %-28s %-10u %-10u %-10u %-10u\n", dname,
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 5a42a0c..1bb2f74 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -195,6 +195,22 @@ struct ip_vs_stats_user
 	__u32			outbps;		/* current out byte rate */
 };
 
+/*
+ *	IPVS statistics object (for user space), 64-bit
+ */
+struct ip_vs_stats64 {
+	__u64			conns;		/* connections scheduled */
+	__u64			inpkts;		/* incoming packets */
+	__u64			outpkts;	/* outgoing packets */
+	__u64			inbytes;	/* incoming bytes */
+	__u64			outbytes;	/* outgoing bytes */
+
+	__u64			cps;		/* current connection rate */
+	__u64			inpps;		/* current in packet rate */
+	__u64			outpps;		/* current out packet rate */
+	__u64			inbps;		/* current in byte rate */
+	__u64			outbps;		/* current out byte rate */
+};
 
 /* The argument to IP_VS_SO_GET_INFO */
 struct ip_vs_getinfo {
@@ -253,6 +269,8 @@ struct ip_vs_service_entry {
 	union nf_inet_addr	addr;
 	char			pe_name[IP_VS_PENAME_MAXLEN];
 
+	/* statistics, 64-bit */
+	struct ip_vs_stats64	stats64;
 };
 
 struct ip_vs_dest_entry_kern {
@@ -289,6 +307,9 @@ struct ip_vs_dest_entry {
 	struct ip_vs_stats_user stats;
 	u_int16_t		af;
 	union nf_inet_addr	addr;
+
+	/* statistics, 64-bit */
+	struct ip_vs_stats64	stats64;
 };
 
 /* The argument to IP_VS_SO_GET_DESTS */
@@ -444,6 +465,8 @@ enum {
 
 	IPVS_SVC_ATTR_PE_NAME,		/* name of scheduler */
 
+	IPVS_SVC_ATTR_STATS64,		/* nested attribute for service stats */
+
 	__IPVS_SVC_ATTR_MAX,
 };
 
@@ -473,6 +496,8 @@ enum {
 
 	IPVS_DEST_ATTR_ADDR_FAMILY,	/* Address family of address */
 
+	IPVS_DEST_ATTR_STATS64,		/* nested attribute for dest stats */
+
 	__IPVS_DEST_ATTR_MAX,
 };
 
@@ -496,7 +521,8 @@ enum {
 /*
  * Attributes used to describe service or destination entry statistics
  *
- * Used inside nested attributes IPVS_SVC_ATTR_STATS and IPVS_DEST_ATTR_STATS
+ * Used inside nested attributes IPVS_SVC_ATTR_STATS, IPVS_DEST_ATTR_STATS,
+ * IPVS_SVC_ATTR_STATS64 and IPVS_DEST_ATTR_STATS64.
  */
 enum {
 	IPVS_STATS_ATTR_UNSPEC = 0,
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 0bfb428..05dd7f6 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -150,6 +150,21 @@ int ipvs_init(void)
 	return 0;
 }
 
+static void copy_stats_from_kern(struct ip_vs_stats64 *d,
+				 struct ip_vs_stats_user *s)
+{
+	d->conns = s->conns;
+	d->inpkts = s->inpkts;
+	d->outpkts = s->outpkts;
+	d->inbytes = s->inbytes;
+	d->outbytes = s->outbytes;
+	d->cps = s->cps;
+	d->inpps = s->inpps;
+	d->outpps = s->outpps;
+	d->inbps = s->inbps;
+	d->outbps = s->outbps;
+}
+
 #ifdef LIBIPVS_USE_NL
 static int ipvs_getinfo_parse_cb(struct nl_msg *msg, void *arg)
 {
@@ -545,7 +560,7 @@ nla_put_failure:
 }
 
 #ifdef LIBIPVS_USE_NL
-static int ipvs_parse_stats(struct ip_vs_stats_user *stats, struct nlattr *nla)
+static int ipvs_parse_stats(struct ip_vs_stats64 *stats, struct nlattr *nla)
 {
 	struct nlattr *attrs[IPVS_STATS_ATTR_MAX + 1];
 
@@ -579,6 +594,40 @@ static int ipvs_parse_stats(struct ip_vs_stats_user *stats, struct nlattr *nla)
 
 }
 
+static int ipvs_parse_stats64(struct ip_vs_stats64 *stats, struct nlattr *nla)
+{
+	struct nlattr *attrs[IPVS_STATS_ATTR_MAX + 1];
+
+	if (nla_parse_nested(attrs, IPVS_STATS_ATTR_MAX, nla,
+			     ipvs_stats_policy))
+		return -1;
+
+	if (!(attrs[IPVS_STATS_ATTR_CONNS] &&
+	      attrs[IPVS_STATS_ATTR_INPKTS] &&
+	      attrs[IPVS_STATS_ATTR_OUTPKTS] &&
+	      attrs[IPVS_STATS_ATTR_INBYTES] &&
+	      attrs[IPVS_STATS_ATTR_OUTBYTES] &&
+	      attrs[IPVS_STATS_ATTR_CPS] &&
+	      attrs[IPVS_STATS_ATTR_INPPS] &&
+	      attrs[IPVS_STATS_ATTR_OUTPPS] &&
+	      attrs[IPVS_STATS_ATTR_INBPS] &&
+	      attrs[IPVS_STATS_ATTR_OUTBPS]))
+		return -1;
+
+	stats->conns = nla_get_u64(attrs[IPVS_STATS_ATTR_CONNS]);
+	stats->inpkts = nla_get_u64(attrs[IPVS_STATS_ATTR_INPKTS]);
+	stats->outpkts = nla_get_u64(attrs[IPVS_STATS_ATTR_OUTPKTS]);
+	stats->inbytes = nla_get_u64(attrs[IPVS_STATS_ATTR_INBYTES]);
+	stats->outbytes = nla_get_u64(attrs[IPVS_STATS_ATTR_OUTBYTES]);
+	stats->cps = nla_get_u64(attrs[IPVS_STATS_ATTR_CPS]);
+	stats->inpps = nla_get_u64(attrs[IPVS_STATS_ATTR_INPPS]);
+	stats->outpps = nla_get_u64(attrs[IPVS_STATS_ATTR_OUTPPS]);
+	stats->inbps = nla_get_u64(attrs[IPVS_STATS_ATTR_INBPS]);
+	stats->outbps = nla_get_u64(attrs[IPVS_STATS_ATTR_OUTBPS]);
+
+	return 0;
+}
+
 static int ipvs_services_parse_cb(struct nl_msg *msg, void *arg)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(msg);
@@ -636,9 +685,15 @@ static int ipvs_services_parse_cb(struct nl_msg *msg, void *arg)
 	nla_memcpy(&flags, svc_attrs[IPVS_SVC_ATTR_FLAGS], sizeof(flags));
 	get->entrytable[i].flags = flags.flags & flags.mask;
 
-	if (ipvs_parse_stats(&(get->entrytable[i].stats),
-			     svc_attrs[IPVS_SVC_ATTR_STATS]) != 0)
-		return -1;
+	if (svc_attrs[IPVS_SVC_ATTR_STATS64]) {
+		if (ipvs_parse_stats64(&get->entrytable[i].stats64,
+				       svc_attrs[IPVS_SVC_ATTR_STATS64]) != 0)
+			return -1;
+	} else if (svc_attrs[IPVS_SVC_ATTR_STATS]) {
+		if (ipvs_parse_stats(&get->entrytable[i].stats64,
+				     svc_attrs[IPVS_SVC_ATTR_STATS]) != 0)
+			return -1;
+	}
 
 	get->entrytable[i].num_dests = 0;
 
@@ -702,6 +757,8 @@ struct ip_vs_get_services *ipvs_get_services(void)
 		       sizeof(struct ip_vs_service_entry_kern));
 		get->entrytable[i].af = AF_INET;
 		get->entrytable[i].addr.ip = get->entrytable[i].__addr_v4;
+		copy_stats_from_kern(&get->entrytable[i].stats64,
+				     &get->entrytable[i].stats);
 	}
 	free(getk);
 	return get;
@@ -796,9 +853,15 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
 	else
 		d->entrytable[i].af = d->af;
 
-	if (ipvs_parse_stats(&(d->entrytable[i].stats),
-			     dest_attrs[IPVS_DEST_ATTR_STATS]) != 0)
-		return -1;
+	if (dest_attrs[IPVS_DEST_ATTR_STATS64]) {
+		if (ipvs_parse_stats(&d->entrytable[i].stats64,
+				     dest_attrs[IPVS_DEST_ATTR_STATS64]) != 0)
+			return -1;
+	} else if (dest_attrs[IPVS_DEST_ATTR_STATS]) {
+		if (ipvs_parse_stats(&d->entrytable[i].stats64,
+				     dest_attrs[IPVS_DEST_ATTR_STATS]) != 0)
+			return -1;
+	}
 
 	i++;
 
@@ -900,6 +963,8 @@ ipvs_nl_dest_failure:
 		       sizeof(struct ip_vs_dest_entry_kern));
 		d->entrytable[i].af = AF_INET;
 		d->entrytable[i].addr.ip = d->entrytable[i].__addr_v4;
+		copy_stats_from_kern(&d->entrytable[i].stats64,
+				     &d->entrytable[i].stats);
 	}
 	free(dk);
 	return d;
@@ -1001,6 +1066,7 @@ ipvs_get_service_err2:
 	svc->af = AF_INET;
 	svc->addr.ip = svc->__addr_v4;
 	svc->pe_name[0] = '\0';
+	copy_stats_from_kern(&svc->stats64, &svc->stats);
 	return svc;
 out_err:
 	free(svc);
-- 
1.9.3

