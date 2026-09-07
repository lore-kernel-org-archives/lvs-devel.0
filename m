Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F0EC51D52E;
	Mon,  7 Sep 2026 18:35:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788806151; cv=none; b=UwUHyHjGMoz9YFrpIo4OMkdB+TyMC6FOBhhxRvqRFgrjZ4ApliKTv3tti0BhNFdlkMRCQi0BHgqvDlMKYng3s9H6DPdexQL4DbWwcvqL/5wS7Mt24bC7/fjucG6aFRUmRQdOFxagaDVAi6Yts6KoRuZWOu2kVCXjJpxGAuKnEHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788806151; c=relaxed/simple;
	bh=eTSbC4wmVeaHhc7RP1oeQbJK/bcaoh6D3L1D6LpV7rs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=JXfC0vC2zQPrht4r1j9wR8xfsIz0TIPL5XVJ5U+ku72aHXjPuRvkEiNJaQOuYWNMxGcVSQNzn6tdng8HUBK0+iq27D+CoMZOyhhG18wyuPSViDR6W3SHeBVtR30h8g2+FsoLxfZN3t+fFI87m4trrw/NMMjz0tVnPRL9r61nz5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=HId0inhh; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="HId0inhh"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A242E21CC4;
	Mon, 07 Sep 2026 21:35:34 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=EHAXLzW5
	FNhZY2x0SLXzIO2WtgTeKd8DnWD+TgKB03A=; b=HId0inhhhUHwSv2Hcbqv+VId
	FtkHs8BmNCJipOj3mwP3XCV7ThPw3/kOjGidmkGzoL4TKP5CUl+pQB3s83XyrA7w
	dJNnn7B2KrtJXFQY/wMAnGTsD0R9uAaFu1wWRt/wDT1m6G+YRqu+AkSEOMMYaGS4
	sEWMNG1cD3HQFNwF7fSPwm1INf7RTgQmEORgNN1+8FfTOT38n3TFST4hxV++0gLr
	mhLEj1BDGIWmmkqb62MqTe0Z2MtE0s31vram3hdhuQn1xAvFXqDxs7zmPtE/z6/z
	XgXJltrPeEwhfqvDjuLtnf2voOY+EeirGGU0G2sb7v61t4svjOQul4j6qajXl1BY
	meodUHEhIGP8FTbU5h/ZRQg5lIQm94+PhLZJjcL7fUiy12152NAGXDw0X0HFcncg
	AZQ70vtRX5TLbMTwQ07sGovrMB6MA0dF05bWHTH6jtUhTPuxSNsu5aNMK0SroSsb
	9ccrWCl+WWwshd6wq3nTJpSRPiFecAwFAPMOWVv5rhc5YZozyn+yjzXfbgN0dCJs
	ziLpKkSIc4xIlxh5tzUUjpgcB1pW0MeQ/x594HY+P2Qsbx6ee8SC1r4gfyrXkxfX
	A2cR0TtHcCQsGY0VrlE9CXQ40LV2t11Jc8OP5hRk4GEw/FOuoHMT2rQdAG+e1sWU
	TPskY+z5LUVls7GDVWI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 07 Sep 2026 21:35:34 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id EBCEF605A3;
	Mon,  7 Sep 2026 21:35:35 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 687IZSvf112622;
	Mon, 7 Sep 2026 21:35:28 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 687IZN6K112606;
	Mon, 7 Sep 2026 21:35:23 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Subject: [PATCH nf] ipvs: fix more races around the overload flag
Date: Mon,  7 Sep 2026 21:34:53 +0300
Message-ID: <20260907183453.112559-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that we still have races when the dest overload
thresholds are updated. If we narrow the range between
thresholds the lockless readers (ip_vs_bind_dest and
ip_vs_unbind_dest) may use old threshold values and
as result to skip the required flag change.

To solve the problem ip_vs_bind_dest() and ip_vs_unbind_dest()
will have the chance as before to change the overload
state not only at the exact threshold positions but
at any conn count below the lower and above the upper thresholds.
To make it work without entering the locked region for
every connection, we introduce l_threshold_val. Together with
u_threshold_val we will switch between two states:

1. not overloaded: where l_threshold_val is set to 0
to close the door for more ip_vs_unbind_dest() calls
to clear the overload state.

2. overloaded: where u_threshold_val is set to INT_MAX
to close the door for more ip_vs_bind_dest() calls
to set the overload state.

If a race occurs, multiple CPUs can repeat the state change
but this should be for short time window.

With the introduction of l_threshold_val the
IP_VS_DEST_F_OVERLOAD flag and the 'flags' field are not
needed anymore. We will use the ip_vs_dest_is_overloaded()
helper for all places that read the overload state.

Do not check IP_VS_DEST_CF_AVAILABLE in ip_vs_dh.c because
we do not hold reference to dest after it is removed and
rely on RCU to access the available dests.

To reduce the cacheline accesses while selecting destination,
keep the mostly used fields (weight and l_threshold_val)
at the first read-mostly cacheline together with the hash
nodes.

Fixes: 8f843441c4e7 ("ipvs: properly update the overload flag on dest edit")
Link: https://sashiko.dev/#/patchset/20260810190621.894119-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h              | 50 ++++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_conn.c  |  8 ++---
 net/netfilter/ipvs/ip_vs_ctl.c   | 38 ++++++++++++------------
 net/netfilter/ipvs/ip_vs_dh.c    | 16 ++--------
 net/netfilter/ipvs/ip_vs_fo.c    |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |  4 +--
 net/netfilter/ipvs/ip_vs_lblcr.c |  8 ++---
 net/netfilter/ipvs/ip_vs_lc.c    |  2 +-
 net/netfilter/ipvs/ip_vs_mh.c    |  2 +-
 net/netfilter/ipvs/ip_vs_nq.c    |  2 +-
 net/netfilter/ipvs/ip_vs_ovf.c   |  2 +-
 net/netfilter/ipvs/ip_vs_rr.c    |  2 +-
 net/netfilter/ipvs/ip_vs_sed.c   |  4 +--
 net/netfilter/ipvs/ip_vs_sh.c    |  2 +-
 net/netfilter/ipvs/ip_vs_twos.c  |  4 +--
 net/netfilter/ipvs/ip_vs_wlc.c   |  4 +--
 net/netfilter/ipvs/ip_vs_wrr.c   |  2 +-
 17 files changed, 76 insertions(+), 76 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index be3a6617adf4..e09b9598a476 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -36,9 +36,6 @@
 #define IP_VS_HDR_INVERSE	1
 #define IP_VS_HDR_ICMP		2
 
-/* Destination Server Flags */
-#define IP_VS_DEST_F_OVERLOAD	0x0002		/* server is overloaded */
-
 /* Destination Server Config Flags */
 #define IP_VS_DEST_CF_AVAILABLE	0x0001		/* server is available */
 
@@ -973,32 +970,43 @@ struct ip_vs_dest_dst {
  * and so on.
  */
 struct ip_vs_dest {
+	/* Cacheline for hash table nodes - read-mostly */
+
 	struct list_head	n_list;   /* for the dests in the service */
 	struct hlist_node	d_list;   /* for table with all the dests */
 
-	u16			af;		/* address family */
-	__be16			port;		/* port number of the server */
-	union nf_inet_addr	addr;		/* IP address of the server */
-	volatile unsigned int	flags;		/* dest status flags */
-	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
-	unsigned long		cflags;		/* config flags */
 	atomic_t		last_weight;	/* server latest weight */
+
+	/* connection thresholds */
+	u32			l_threshold_val;/* used lower threshold */
+	u32			u_threshold_val;/* used upper threshold */
+	/* 32/48 */
+	u32			l_threshold;	/* lower threshold */
+	u32			u_threshold;	/* upper threshold */
+
+	unsigned long		cflags;		/* config flags */
+
+	/* 44/64 */
+	atomic_t		conn_flags;	/* flags to copy to conn */
+
 	__u16			tun_type;	/* tunnel type */
 	__be16			tun_port;	/* tunnel port */
 	__u16			tun_flags;	/* tunnel flags */
 
-	refcount_t		refcnt;		/* reference counter */
-	struct ip_vs_stats      stats;          /* statistics */
-	unsigned long		idle_start;	/* start time, jiffies */
+	u16			af;		/* address family */
+	__be16			port;		/* port number of the server */
+	/* 60/80 */
+	union nf_inet_addr	addr;		/* IP address of the server */
 
-	/* connection counters and thresholds */
-	atomic_t		activeconns;	/* active connections */
+	/* connection counters */
 	atomic_t		totalconns;	/* total connections */
+	atomic_t		activeconns;	/* active connections */
 	atomic_t		persistconns;	/* persistent connections */
-	__u32			u_threshold;	/* upper threshold */
-	__u32			l_threshold;	/* lower threshold */
-	__u32			l_threshold_val;/* used lower threshold */
+
+	refcount_t		refcnt;		/* reference counter */
+	struct ip_vs_stats      stats;          /* statistics */
+	unsigned long		idle_start;	/* start time, jiffies */
 
 	/* for destination cache */
 	spinlock_t		dst_lock;	/* lock of dst_cache */
@@ -1915,7 +1923,13 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 		kfree(dest);
 }
 
-void ip_vs_dest_update_overload(struct ip_vs_dest *dest, int mode);
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload);
+
+/* Check if dest is in overloaded state */
+static inline bool ip_vs_dest_is_overloaded(const struct ip_vs_dest *dest)
+{
+	return READ_ONCE(dest->l_threshold_val);
+}
 
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1ff8cad39ab4..ce0883f259cb 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1150,8 +1150,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		if (!(flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
 		tc = atomic_inc_return(&dest->totalconns);
-		if (tc == READ_ONCE(dest->u_threshold))
-			ip_vs_dest_update_overload(dest, 1);
+		if (tc >= READ_ONCE(dest->u_threshold_val))
+			ip_vs_dest_update_overload(dest, true);
 	} else {
 		/* It is a persistent connection/template, so increase
 		   the persistent connection counter */
@@ -1243,8 +1243,8 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
 			atomic_dec(&dest->activeconns);
 		tc = atomic_fetch_dec(&dest->totalconns);
-		if (tc == READ_ONCE(dest->l_threshold_val))
-			ip_vs_dest_update_overload(dest, -1);
+		if (tc <= READ_ONCE(dest->l_threshold_val))
+			ip_vs_dest_update_overload(dest, false);
 	} else {
 		/* It is a persistent connection/template, so decrease
 		   the persistent connection counter */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8f9a8e491ad6..5de69404a5e0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1309,32 +1309,32 @@ void ip_vs_stats_free(struct ip_vs_stats *stats)
  * - conns reach u_threshold and exceed it: set the flag
  * - conns go below l_threshold (or 75% of u_threshold): clear the flag
  */
-static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, int mode)
+static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
 {
 	int conns;
 	u32 l, u;
 
 	lockdep_assert_held(&dest->dst_lock);
 	u = READ_ONCE(dest->u_threshold);
-	if (!u)
-		goto unset;
-	l = READ_ONCE(dest->l_threshold_val);
-	conns = atomic_read(&dest->totalconns);
-	if (conns >= (mode > 0 ? l : u)) {
-		dest->flags |= IP_VS_DEST_F_OVERLOAD;
-		return;
+	if (u) {
+		/* Low threshold defaults to 75% of upper threshold */
+		l = READ_ONCE(dest->l_threshold) ? : (u - (u >> 2));
+		conns = atomic_read(&dest->totalconns);
+		if (conns >= (overload ? l : u)) {
+			WRITE_ONCE(dest->u_threshold_val, INT_MAX);
+			WRITE_ONCE(dest->l_threshold_val, l);
+			return;
+		}
 	}
-	if (conns >= (mode < 0 ? u : l))
-		return;
 
-unset:
-	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+	WRITE_ONCE(dest->u_threshold_val, u ? : INT_MAX);
+	WRITE_ONCE(dest->l_threshold_val, 0);
 }
 
-void ip_vs_dest_update_overload(struct ip_vs_dest *dest, int mode)
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
 {
 	spin_lock_bh(&dest->dst_lock);
-	__ip_vs_dest_update_overload(dest, mode);
+	__ip_vs_dest_update_overload(dest, overload);
 	spin_unlock_bh(&dest->dst_lock);
 }
 
@@ -1406,15 +1406,13 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 
 	if (READ_ONCE(dest->u_threshold) != udest->u_threshold ||
 	    READ_ONCE(dest->l_threshold) != udest->l_threshold) {
+		bool overload;
+
 		spin_lock_bh(&dest->dst_lock);
 		WRITE_ONCE(dest->u_threshold, udest->u_threshold);
 		WRITE_ONCE(dest->l_threshold, udest->l_threshold);
-		/* Low threshold defaults to 75% of upper threshold */
-		WRITE_ONCE(dest->l_threshold_val,
-			   udest->l_threshold ? :
-			   (udest->u_threshold -
-			    (udest->u_threshold >> 2)));
-		__ip_vs_dest_update_overload(dest, 0);
+		overload = ip_vs_dest_is_overloaded(dest);
+		__ip_vs_dest_update_overload(dest, overload);
 		spin_unlock_bh(&dest->dst_lock);
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 43abed7a26a6..95e52950adbb 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -195,16 +195,6 @@ static int ip_vs_dh_dest_changed(struct ip_vs_service *svc,
 }
 
 
-/*
- *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
- *      consider that the server is overloaded here.
- */
-static inline int is_overloaded(struct ip_vs_dest *dest)
-{
-	return dest->flags & IP_VS_DEST_F_OVERLOAD;
-}
-
-
 /*
  *      Destination hashing scheduling
  */
@@ -219,10 +209,8 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	s = (struct ip_vs_dh_state *) svc->sched_data;
 	dest = ip_vs_dh_get(svc->af, s, &iph->daddr);
-	if (!dest ||
-	    !(dest->cflags & IP_VS_DEST_CF_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+	if (!dest || atomic_read(&dest->weight) <= 0 ||
+	    ip_vs_dest_is_overloaded(dest)) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_fo.c b/net/netfilter/ipvs/ip_vs_fo.c
index d657b47c6511..e07fa33f6d52 100644
--- a/net/netfilter/ipvs/ip_vs_fo.c
+++ b/net/netfilter/ipvs/ip_vs_fo.c
@@ -29,7 +29,7 @@ ip_vs_fo_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 * Find virtual server with highest weight and send it traffic
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!ip_vs_dest_is_overloaded(dest) &&
 		    atomic_read(&dest->weight) > hw) {
 			hweight = dest;
 			hw = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 693bcc82ccb7..bff109c1c959 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -414,7 +414,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 		if (atomic_read(&dest->weight) > 0) {
 			least = dest;
@@ -429,7 +429,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f53f05ceea36..c2853e07e787 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -166,7 +166,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry_rcu(e, &set->list, list) {
 		least = e->dest;
-		if (least->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(least))
 			continue;
 
 		if ((atomic_read(&least->weight) > 0) &&
@@ -181,7 +181,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
   nextstage:
 	list_for_each_entry_continue_rcu(e, &set->list, list) {
 		dest = e->dest;
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
@@ -577,7 +577,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 
 		if (atomic_read(&dest->weight) > 0) {
@@ -593,7 +593,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 18b976a7c4d2..9002f491bff6 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -38,7 +38,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if (ip_vs_dest_is_overloaded(dest) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 020863047562..d70b23aec5fe 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -80,7 +80,7 @@ static inline void generate_hash_secret(hsiphash_key_t *hash1,
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       ip_vs_dest_is_overloaded(dest);
 }
 
 /* Returns hash value for IPVS MH entry */
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index ada158c610ce..7cc28902086e 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -72,7 +72,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD ||
+		if (ip_vs_dest_is_overloaded(dest) ||
 		    !atomic_read(&dest->weight))
 			continue;
 
diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
index c5c67df80a0b..eaa3a7ae6efa 100644
--- a/net/netfilter/ipvs/ip_vs_ovf.c
+++ b/net/netfilter/ipvs/ip_vs_ovf.c
@@ -33,7 +33,7 @@ ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	*/
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		w = atomic_read(&dest->weight);
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if (ip_vs_dest_is_overloaded(dest) ||
 		    atomic_read(&dest->activeconns) > w ||
 		    w == 0)
 			continue;
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 4125ee561cdc..bd17cdd092f5 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -66,7 +66,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!ip_vs_dest_is_overloaded(dest) &&
 			    atomic_read(&dest->weight) > 0)
 				/* HIT */
 				goto out;
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 245a323c84cd..7925f4d28fce 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -75,7 +75,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!ip_vs_dest_is_overloaded(dest) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_sed_dest_overhead(least);
@@ -90,7 +90,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index cd67066e3b26..c24dd5cb7e47 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -73,7 +73,7 @@ struct ip_vs_sh_state {
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       ip_vs_dest_is_overloaded(dest);
 }
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_twos.c b/net/netfilter/ipvs/ip_vs_twos.c
index dbb7f5fd4688..86186122a1f0 100644
--- a/net/netfilter/ipvs/ip_vs_twos.c
+++ b/net/netfilter/ipvs/ip_vs_twos.c
@@ -52,7 +52,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Generate a random weight between [0,sum of all weights) */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD)) {
+		if (!ip_vs_dest_is_overloaded(dest)) {
 			weight = atomic_read(&dest->weight);
 			if (weight > 0) {
 				total_weight += weight;
@@ -75,7 +75,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Pick two weighted servers */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 
 		weight = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 9da445ca09a1..08e9e22f72bf 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -47,7 +47,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!ip_vs_dest_is_overloaded(dest) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_dest_conn_overhead(least);
@@ -62,7 +62,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (ip_vs_dest_is_overloaded(dest))
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 2dcff1040da5..fad69bae5a22 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -176,7 +176,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!ip_vs_dest_is_overloaded(dest) &&
 			    atomic_read(&dest->weight) >= mark->cw)
 				goto found;
 			if (dest == stop)
-- 
2.55.0


