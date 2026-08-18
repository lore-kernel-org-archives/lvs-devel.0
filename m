Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05CDB376A16;
	Tue, 18 Aug 2026 20:17:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787084248; cv=none; b=QewTUSe8vlqVxvwyBDm+9dBNDBRxnBdehBPA97ArhBe7SVJUt0N3Nonx07wRelYR/p6u+MsG2NB+vdUEorT8kgMdhgJ7PyD4KhDNyxfXyf+ychxRDL5CuIceMLgtqOMZ/NbLDWQsOkdM0Lk+AaX/7BNFkRmPranj3ZPbwhO5HjY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787084248; c=relaxed/simple;
	bh=JpHHj35FkGBLiU/LWm6Hzh64bz7NqhwxKdzb3VX0EOI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pF3fM2AM2JQVq4QK1FzHFt8hdMj6pBDfNXCe4fsq5NvCWxhqQwyTpU3FBv4N1xRQCGnaaV0Dnxdlr1CO+SoFpz4NOs3682Ch/wS9XYin97eScRha3BSSot2w7592mOtzKMBqD1VPm5Jcrz4aOXqcxAYAk7ov+cAY+BQW459EdF0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=5IvFN7+w; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="5IvFN7+w"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2489221DBF;
	Tue, 18 Aug 2026 23:17:13 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=m+dvpQnJxszAtsaLlh834Lb4G8Qek8B1GHTn5sF2l18=; b=5IvFN7+wB4cy
	YC0vt+gwhGlCbC5AReOvrP6KpJfX25upRxRflELip0mgYY6Ce/gIdSdSsGKwKsj4
	c189+odEYH8ZqaVOYFU0W7Ch5Wdi9hnxlm2gFWbuUGdCgIYau3RBy7ZIp6yaFBr5
	rGGR2Vrc/yo8zjbeAQWG887L3XpuwiDcm9bsCLmHvCFdzCPpr+mRyWzpinxh4f5F
	z8iUP3jzDOUaotFn1GAYpBI4fylbGRscuzyh3BH30wRDdC7J+nOU5LXGCBVVNcNN
	LJlQTqOeNCjFySIHvqzD9p/CIao6biPJyyEv1ocep45LvzOZ9MGgdRy2+anJFLVn
	czBD7hnna6Lh8xV7/Y+jyOmzz105VK2gVjus2SRbGfzH4bqw229UwvWMpVo6uolu
	vmxKv0wEQyfYXIX/pyGWOjOEPqZnAtDcF6Ew07BIqSO+wrlE3IwugQVRdAbs6rSP
	t4P9Jlk2I0UGFDZYV8OsCs2ay3iyDDwdWvJKCtQN2tswcRO86/RaUMnvtNm/dA33
	98UW2XBivnJ/K4lVwYtZBioKYMWbnY29HgokYcW3eaOMuNokpgy51Xhu6GdFkdUS
	RQg4FX+iHDiR34rtxTWU1z4tGoBi2sh1bnOi/NV5WW5gfdFpoJcyQNARaZ0SeSXK
	SLjlBuLeXE0+tJj957ww59Ond6cjxjg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 18 Aug 2026 23:17:13 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 37D9E61DD5;
	Tue, 18 Aug 2026 23:17:15 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67IKH4Js121476;
	Tue, 18 Aug 2026 23:17:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 67IKH4T1121474;
	Tue, 18 Aug 2026 23:17:04 +0300
From: Julian Anastasov <ja@ssi.bg>
To: stable@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org
Subject: [PATCH -stable 1/1] ipvs: separate destination availability state
Date: Tue, 18 Aug 2026 23:16:38 +0300
Message-ID: <20260818201638.121446-2-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260818201638.121446-1-ja@ssi.bg>
References: <20260818201638.121446-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>

commit cdcc4e46180df8161f4d2f3c6fd6beaf6990133d upstream.

IPVS configuration paths update destination availability while connection
accounting updates destination overload state. The two independent states
share dest->flags, so their read-modify-write updates can race and lose one
another.

Keep OVERLOAD in flags, where the preceding patch serializes its updates
with dst_lock, and move AVAILABLE to cflags. This keeps configuration-
controlled availability out of the scheduler hot cacheline until a
scheduler needs to check it. It also prevents availability updates from
clobbering overload state.

The destination status bits are not exposed through the IPVS sockopt or
netlink interfaces, so keep their definitions in the internal IPVS header.

Readers can still observe stale destination state; this does not provide a
cross-field snapshot.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Link: https://lore.kernel.org/all/8913381c-1e02-35c7-0ec4-61de5a12fd35@ssi.bg/
Assisted-by: Claude-Code:GLM-5.2
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
(cherry picked from commit cdcc4e46180df8161f4d2f3c6fd6beaf6990133d)
[ Julian: Backport by removing the hunks from ip_vs_xmit.c ]
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h              | 7 +++++++
 include/uapi/linux/ip_vs.h       | 6 ------
 net/netfilter/ipvs/ip_vs_conn.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c  | 6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c   | 4 ++--
 net/netfilter/ipvs/ip_vs_dh.c    | 4 ++--
 net/netfilter/ipvs/ip_vs_lblc.c  | 2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
 8 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b65009a226e0..94dfc3a265ee 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -34,6 +34,12 @@
 #define IP_VS_HDR_INVERSE	1
 #define IP_VS_HDR_ICMP		2
 
+/* Destination Server Flags */
+#define IP_VS_DEST_F_OVERLOAD	0x0002		/* server is overloaded */
+
+/* Destination Server Config Flags */
+#define IP_VS_DEST_CF_AVAILABLE	0x0001		/* server is available */
+
 /* Generic access of ipvs struct */
 static inline struct netns_ipvs *net_ipvs(struct net* net)
 {
@@ -725,6 +731,7 @@ struct ip_vs_dest {
 	volatile unsigned int	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
+	unsigned long		cflags;		/* config flags */
 	atomic_t		last_weight;	/* server latest weight */
 	__u16			tun_type;	/* tunnel type */
 	__be16			tun_port;	/* tunnel port */
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 1ed234e7f251..2c37c6ac7525 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -28,12 +28,6 @@
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
 
-/*
- *      Destination Server Flags
- */
-#define IP_VS_DEST_F_AVAILABLE	0x0001		/* server is available */
-#define IP_VS_DEST_F_OVERLOAD	0x0002		/* server is overloaded */
-
 /*
  *      IPVS sync daemon states
  */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index e42fed876596..7da11628073b 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -759,7 +759,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest)
 	 * Checking the dest server status.
 	 */
 	if ((dest == NULL) ||
-	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
+	    !(dest->cflags & IP_VS_DEST_CF_AVAILABLE) ||
 	    expire_quiescent_template(ipvs, dest) ||
 	    (cdest && (dest != cdest))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
@@ -1408,7 +1408,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 				continue;
 
 			dest = cp->dest;
-			if (!dest || (dest->flags & IP_VS_DEST_F_AVAILABLE))
+			if (!dest || (dest->cflags & IP_VS_DEST_CF_AVAILABLE))
 				continue;
 
 			if (atomic_read(&cp->n_control))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d121ea3d16bc..1f62ca2f7330 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -124,7 +124,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 	struct ip_vs_dest *dest = cp->dest;
 	struct netns_ipvs *ipvs = cp->ipvs;
 
-	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (dest && (dest->cflags & IP_VS_DEST_CF_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
 		struct ip_vs_service *svc;
 
@@ -160,7 +160,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 	struct ip_vs_dest *dest = cp->dest;
 	struct netns_ipvs *ipvs = cp->ipvs;
 
-	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (dest && (dest->cflags & IP_VS_DEST_CF_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
 		struct ip_vs_service *svc;
 
@@ -2030,7 +2030,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	}
 
 	/* Check the server status */
-	if (cp && cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (cp && cp->dest && !(cp->dest->cflags & IP_VS_DEST_CF_AVAILABLE)) {
 		/* the destination server is not available */
 		if (sysctl_expire_nodest_conn(ipvs)) {
 			bool old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5dea5a14e85f..c0257ef4d8b0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1058,7 +1058,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	}
 
 	/* set the dest status flags */
-	dest->flags |= IP_VS_DEST_F_AVAILABLE;
+	dest->cflags |= IP_VS_DEST_CF_AVAILABLE;
 
 	if (READ_ONCE(dest->u_threshold) != udest->u_threshold ||
 	    READ_ONCE(dest->l_threshold) != udest->l_threshold) {
@@ -1325,7 +1325,7 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 				struct ip_vs_dest *dest,
 				int svcupd)
 {
-	dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
+	dest->cflags &= ~IP_VS_DEST_CF_AVAILABLE;
 
 	/*
 	 *  Remove it from the d-linked destination list.
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f4c231f4a0..f04d2530a093 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -220,8 +220,8 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	s = (struct ip_vs_dh_state *) svc->sched_data;
 	dest = ip_vs_dh_get(svc->af, s, &iph->daddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
+	if (!dest ||
+	    !(dest->cflags & IP_VS_DEST_CF_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
 	    || is_overloaded(dest)) {
 		ip_vs_scheduler_err(svc, "no destination available");
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 156181a3bacd..9bb1e05063dc 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -503,7 +503,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		 */
 
 		dest = en->dest;
-		if ((dest->flags & IP_VS_DEST_F_AVAILABLE) &&
+		if ((dest->cflags & IP_VS_DEST_CF_AVAILABLE) &&
 		    atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
 			goto out;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index a021e6aba3d7..1a53c1254fe5 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -170,8 +170,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-		if ((atomic_read(&least->weight) > 0)
-		    && (least->flags & IP_VS_DEST_F_AVAILABLE)) {
+		if ((atomic_read(&least->weight) > 0) &&
+		    (least->cflags & IP_VS_DEST_CF_AVAILABLE)) {
 			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
@@ -187,8 +187,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 
 		doh = ip_vs_dest_conn_overhead(dest);
 		if (((__s64)loh * atomic_read(&dest->weight) >
-		     (__s64)doh * atomic_read(&least->weight))
-		    && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+		     (__s64)doh * atomic_read(&least->weight)) &&
+		    (dest->cflags & IP_VS_DEST_CF_AVAILABLE)) {
 			least = dest;
 			loh = doh;
 		}
-- 
2.55.0


