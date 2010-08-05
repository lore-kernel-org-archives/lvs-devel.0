From: Simon Horman <horms@verge.net.au>
Subject: [rfc 11/13] [RFC 11/13] IPVS: Allow configuration of persistence engines
Date: Thu, 05 Aug 2010 20:48:06 +0900
Message-ID: <20100805115241.672373920@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0011-IPVS-Allow-configuration-of-persistence-engines.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Allow the persistence engine of a virtual service to be set, edited
and unset.

This feature only works with the netlink user-space interface.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/ip_vs.h          |    3 ++
 include/net/ip_vs.h            |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c |   45 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 6c79bd1..aa3ea41 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -326,6 +326,9 @@ enum {
 	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */
 
 	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
+
+	IPVS_SVC_ATTR_PE_NAME,		/* name of ct retriever */
+
 	__IPVS_SVC_ATTR_MAX,
 };
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0834aee..c4ce532 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -442,6 +442,7 @@ struct ip_vs_service_user_kern {
 
 	/* virtual service options */
 	char			*sched_name;
+	char			*pe_name;
 	unsigned		flags;		/* virtual service flags */
 	unsigned		timeout;	/* persistent timeout in sec */
 	u32			netmask;	/* persistent netmask */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d57cc4a..ccfc272 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1157,6 +1157,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 {
 	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
+	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
 
 	/* increase the module use count */
@@ -1170,6 +1171,16 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		goto out_err;
 	}
 
+	if (u->pe_name && *u->pe_name) {
+		pe = ip_vs_pe_get(u->pe_name);
+		if (pe == NULL) {
+			pr_info("persistence engine module ip_vs_pe_%s "
+				"not found\n", u->pe_name);
+			ret = -ENOENT;
+			goto out_err;
+		}
+	}
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
 		ret = -EINVAL;
@@ -1207,6 +1218,10 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		goto out_err;
 	sched = NULL;
 
+	/* Bind the ct retriever */
+	ip_vs_bind_pe(svc, pe);
+	pe = NULL;
+
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
 		atomic_inc(&ip_vs_ftpsvc_counter);
@@ -1238,6 +1253,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		kfree(svc);
 	}
 	ip_vs_scheduler_put(sched);
+	ip_vs_pe_put(pe);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -1253,6 +1269,7 @@ static int
 ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 {
 	struct ip_vs_scheduler *sched, *old_sched;
+	struct ip_vs_pe *pe = NULL, *old_pe = NULL;
 	int ret = 0;
 
 	/*
@@ -1265,6 +1282,17 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	}
 	old_sched = sched;
 
+	if (u->pe_name && *u->pe_name) {
+		pe = ip_vs_pe_get(u->pe_name);
+		if (pe == NULL) {
+			pr_info("persistence engine module ip_vs_pe_%s "
+				"not found\n", u->pe_name);
+			ret = -ENOENT;
+			goto out;
+		}
+		old_pe = pe;
+	}
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
 		ret = -EINVAL;
@@ -1316,12 +1344,17 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 		}
 	}
 
+	old_pe = svc->pe;
+	if (pe != old_pe) {
+		ip_vs_unbind_pe(svc);
+		ip_vs_bind_pe(svc, pe);
+	}
+
   out_unlock:
 	write_unlock_bh(&__ip_vs_svc_lock);
-#ifdef CONFIG_IP_VS_IPV6
   out:
-#endif
 	ip_vs_scheduler_put(old_sched);
+	ip_vs_pe_put(old_pe);
 	return ret;
 }
 
@@ -2553,6 +2586,8 @@ static const struct nla_policy ip_vs_svc_policy[IPVS_SVC_ATTR_MAX + 1] = {
 	[IPVS_SVC_ATTR_FWMARK]		= { .type = NLA_U32 },
 	[IPVS_SVC_ATTR_SCHED_NAME]	= { .type = NLA_NUL_STRING,
 					    .len = IP_VS_SCHEDNAME_MAXLEN },
+	[IPVS_SVC_ATTR_PE_NAME]		= { .type = NLA_NUL_STRING,
+					    .len = IP_VS_PENAME_MAXLEN },
 	[IPVS_SVC_ATTR_FLAGS]		= { .type = NLA_BINARY,
 					    .len = sizeof(struct ip_vs_flags) },
 	[IPVS_SVC_ATTR_TIMEOUT]		= { .type = NLA_U32 },
@@ -2629,6 +2664,8 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	}
 
 	NLA_PUT_STRING(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name);
+	if (svc->pe)
+		NLA_PUT_STRING(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name);
 	NLA_PUT(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
 	NLA_PUT_U32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ);
 	NLA_PUT_U32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask);
@@ -2746,12 +2783,13 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 
 	/* If a full entry was requested, check for the additional fields */
 	if (full_entry) {
-		struct nlattr *nla_sched, *nla_flags, *nla_timeout,
+		struct nlattr *nla_sched, *nla_pe, *nla_flags, *nla_timeout,
 			      *nla_netmask;
 		struct ip_vs_flags flags;
 		struct ip_vs_service *svc;
 
 		nla_sched = attrs[IPVS_SVC_ATTR_SCHED_NAME];
+		nla_pe = attrs[IPVS_SVC_ATTR_PE_NAME];
 		nla_flags = attrs[IPVS_SVC_ATTR_FLAGS];
 		nla_timeout = attrs[IPVS_SVC_ATTR_TIMEOUT];
 		nla_netmask = attrs[IPVS_SVC_ATTR_NETMASK];
@@ -2777,6 +2815,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 		usvc->flags = (usvc->flags & ~flags.mask) |
 			      (flags.flags & flags.mask);
 		usvc->sched_name = nla_data(nla_sched);
+		usvc->pe_name = nla_pe ? nla_data(nla_pe) : NULL;
 		usvc->timeout = nla_get_u32(nla_timeout);
 		usvc->netmask = nla_get_u32(nla_netmask);
 	}
-- 
1.7.1


