Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [207.46.229.174])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 1F2DE13D53C;
	Tue,  7 Jul 2026 08:57:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=207.46.229.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783414677; cv=none; b=qL0RAcoPIIw9k1vZd2+ECAkG+z0MUwckpDn8KS7MIoicuiHhZB/YgnecVG1HouhD8/M0wbIdStZtCSI+GqrEl+apep3B+TEBfvPnKoLUjuv9uJqxfj0GxNJEj8AFD+ecqE/85cE72R2i899eMf7+zK9EUEUwwvKFrPM8BRTePU0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783414677; c=relaxed/simple;
	bh=/gwlNN+QyxJhs4bO+s+BTCthGDCrR/0tjmfMPYg48Us=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Z6BZkLLSnh8W5Vt7qmN72kxKbvGYCpGSfyzbjpemOC9PhAs6IbokVwHwK6b703jTfk+BN3cqeCGfz+lQ5GfAOugVk9K4946/oyBJmxSodpyDXnt+VGf37SGeylqbdG+jSI4YEbmbcAKcyqqri0Mfvj5370CCeldRhvnrP/wSp/M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=CuNVj5YL; arc=none smtp.client-ip=207.46.229.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="CuNVj5YL"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:MIME-Version:Content-Transfer-Encoding; bh=bJCm2
	Sf+Tv5QuT/oP1gUHO/u1/5zUlA3EubAjuJOkZU=; b=CuNVj5YL1hmlBzdtp2K2b
	jOp5kI1cSgTziLmn2VvTnQsAwGXfjrC3Km7cMBKj/OnJ9kUYNMTACVULjWv2eY8I
	LX82JoClyKgcc7NKNzCpe4gKDyw3prA7VdZR/yytGqwWZ9QKOcKGgOo2TB9lSV8v
	1Mk82STlz/5yOti6HlcI0w=
Received: from localhost.localdomain (unknown [101.5.13.242])
	by web5 (Coremail) with SMTP id zAQGZQA38L9nv0xqLHwFAw--.21191S2;
	Tue, 07 Jul 2026 16:57:11 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Alexander Frolkin <avf@eldamar.org.uk>
Cc: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	stable@vger.kernel.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>,
	Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>,
	Ke Xu <xuke@tsinghua.edu.cn>
Subject: [PATCH nf] ipvs: make destination flags atomic
Date: Tue,  7 Jul 2026 16:57:04 +0800
Message-ID: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:zAQGZQA38L9nv0xqLHwFAw--.21191S2
X-Coremail-Antispam: 1UD129KBjvAXoWftr17uFWDXrWrWr4fuFWfKrg_yoW8ZF4UGo
	W2q3ZIv3yrArWxt3y8tr4fuFWrWr42gF4xCFW7Xanxur9rt3WUX39rW3Waqa17JF1IqF13
	Z34xWwn8JFs5Kr1rn29KB7ZKAUJUUUU8529EdanIXcx71UUUUU7v73VFW2AGmfu7bjvjm3
	AaLaJ3UjIYCTnIWjp_UUUYQ7CY07I20VC2zVCF04k26cxKx2IYs7xG6rWj6s0DM28lY4IE
	w2IIxxk0rwA2F7IY1VAKz4vEj48ve4kI8wA2z4x0Y4vE2Ix0cI8IcVAFwI0_tr0E3s1l84
	ACjcxK6xIIjxv20xvEc7CjxVAFwI0_Gr1j6F4UJwA2z4x0Y4vEx4A2jsIE14v26rxl6s0D
	M28EF7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAac4AC62xK8xCEY4vEwIxC4wAS0I0E0x
	vYzxvE52x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VCjz48v1sIEY20_
	GrWkJr1UJwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IYc2Ij64vIr41lF7I21c0EjII2zV
	CS5cI20VAGYxC7M4IIrI8v6xkF7I0E8cxan2IY04v7MxkF7I0En4kS14v26r4a6rW5MxkI
	ecxEwVAFwVW8ZwCF04k20xvY0x0EwIxGrwCF04k20xvE74AGY7Cv6cx26r4rKr1UJr1l4I
	8I3I0E4IkC6x0Yz7v_Jr0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AK
	xVWUGVWUWwC2zVAF1VAY17CE14v26r4a6rW5MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcV
	AFwI0_Jr0_JF4lIxAIcVC0I7IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8I
	cIk0rVWUJVWUCwCI42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r
	4j6r4UJbIYCTnIWIevJa73UjIFyTuYvjfUoEfODUUUU
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAQUBAWpMKrKTLgACsF

is_unavailable() in the SH scheduler reads dest->flags from the packet
scheduling path while holding only the RCU read lock.  The same word is
updated by read-modify-write operations from connection accounting and
destination update paths, for example ip_vs_bind_dest(),
ip_vs_unbind_dest(), and __ip_vs_update_dest().

The RCU read lock only protects the destination lifetime; it does not
serialize accesses to dest->flags.  A racing plain load or RMW update can
therefore observe stale state or lose an AVAILABLE/OVERLOAD bit update,
which can make the scheduler choose an overloaded destination or report no
available destination even though one should be usable.

KCSAN reports the race with a standard IPVS configuration using the SH
scheduler and a destination with u_threshold set:

  BUG: KCSAN: data-race in __ip_vs_update_dest / ip_vs_sh_schedule
  write to ... of 4 bytes by task ipvs_cfg:
    __ip_vs_update_dest
    ip_vs_edit_dest
    do_ip_vs_set_ctl
    __x64_sys_setsockopt
  read to ... of 4 bytes by task ipvs_churn:
    ip_vs_sh_schedule
    ip_vs_schedule
    tcp_conn_schedule
    ip_vs_in_hook
    tcp_connect
    __x64_sys_connect
  value changed: 0x00000003 -> 0x00000001

Convert dest->flags to atomic_t and use atomic_read(), atomic_or(), and
atomic_and() for all destination flag tests and updates.  This preserves
the existing 32-bit field size while making the flag updates atomic RMW
operations and making readers use atomic accesses.  Valid minimum-sized
IPVS configuration and scheduling paths are unchanged; only the
synchronization of the destination status flags changes.

Fixes: eba3b5a78799d ("ipvs: SH fallback and L4 hashing")
Cc: stable@vger.kernel.org
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Assisted-by: Claude-Code:GLM-5.2
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 49297fec448a..bb969738ed73 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -972,7 +972,7 @@ struct ip_vs_dest {
 	u16			af;		/* address family */
 	__be16			port;		/* port number of the server */
 	union nf_inet_addr	addr;		/* IP address of the server */
-	volatile unsigned int	flags;		/* dest status flags */
+	atomic_t		flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
 	atomic_t		last_weight;	/* server latest weight */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index cb36641f8d1c..539f603f38b7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1055,7 +1055,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 
 	if (dest->u_threshold != 0 &&
 	    ip_vs_dest_totalconns(dest) >= dest->u_threshold)
-		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+		atomic_or(IP_VS_DEST_F_OVERLOAD, &dest->flags);
 }
 
 
@@ -1151,13 +1151,13 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 
 	if (dest->l_threshold != 0) {
 		if (ip_vs_dest_totalconns(dest) < dest->l_threshold)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+			atomic_and(~IP_VS_DEST_F_OVERLOAD, &dest->flags);
 	} else if (dest->u_threshold != 0) {
 		if (ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+			atomic_and(~IP_VS_DEST_F_OVERLOAD, &dest->flags);
 	} else {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
+			atomic_and(~IP_VS_DEST_F_OVERLOAD, &dest->flags);
 	}
 
 	ip_vs_dest_put(dest);
@@ -1188,7 +1188,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest)
 	 * Checking the dest server status.
 	 */
 	if ((dest == NULL) ||
-	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
+	    !(atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE) ||
 	    expire_quiescent_template(ipvs, dest) ||
 	    (cdest && (dest != cdest))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
@@ -1929,7 +1929,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 			cp = ip_vs_hn0_to_conn(hn);
 			resched_score++;
 			dest = cp->dest;
-			if (!dest || (dest->flags & IP_VS_DEST_F_AVAILABLE))
+			if (!dest || (atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE))
 				continue;
 
 			if (atomic_read(&cp->n_control))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d40b404c1bf6..ca778937facf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -302,7 +302,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 	struct ip_vs_dest *dest = cp->dest;
 	struct netns_ipvs *ipvs = cp->ipvs;
 
-	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (dest && (atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
 		struct ip_vs_service *svc;
 
@@ -338,7 +338,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 	struct ip_vs_dest *dest = cp->dest;
 	struct netns_ipvs *ipvs = cp->ipvs;
 
-	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (dest && (atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
 		struct ip_vs_service *svc;
 
@@ -2204,7 +2204,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	}
 
 	/* Check the server status */
-	if (cp && cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+	if (cp && cp->dest && !(atomic_read(&cp->dest->flags) & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 		if (sysctl_expire_nodest_conn(ipvs)) {
 			bool old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bcf40b8c41cf..685b2675b6e0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1368,10 +1368,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	}
 
 	/* set the dest status flags */
-	dest->flags |= IP_VS_DEST_F_AVAILABLE;
+	atomic_or(IP_VS_DEST_F_AVAILABLE, &dest->flags);
 
 	if (udest->u_threshold == 0 || udest->u_threshold > dest->u_threshold)
-		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+		atomic_and(~IP_VS_DEST_F_OVERLOAD, &dest->flags);
 	dest->u_threshold = udest->u_threshold;
 	dest->l_threshold = udest->l_threshold;
 
@@ -1613,7 +1613,7 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 				struct ip_vs_dest *dest,
 				int svcupd)
 {
-	dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
+	atomic_and(~IP_VS_DEST_F_AVAILABLE, &dest->flags);
 
 	spin_lock_bh(&dest->dst_lock);
 	__ip_vs_dst_cache_reset(dest);
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index e1f62f6b25e2..82492e824f02 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -201,7 +201,7 @@ static int ip_vs_dh_dest_changed(struct ip_vs_service *svc,
  */
 static inline int is_overloaded(struct ip_vs_dest *dest)
 {
-	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+	return atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD;
 }
 
 
@@ -219,10 +219,10 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	s = (struct ip_vs_dh_state *) svc->sched_data;
 	dest = ip_vs_dh_get(svc->af, s, &iph->daddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+	if (!dest
+	    || !(atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)
+	    || atomic_read(&dest->weight) <= 0
+	    || is_overloaded(dest)) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_fo.c b/net/netfilter/ipvs/ip_vs_fo.c
index d657b47c6511..5231e518c07c 100644
--- a/net/netfilter/ipvs/ip_vs_fo.c
+++ b/net/netfilter/ipvs/ip_vs_fo.c
@@ -29,7 +29,7 @@ ip_vs_fo_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 * Find virtual server with highest weight and send it traffic
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > hw) {
 			hweight = dest;
 			hw = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 15ccb2b2fa1f..d2eb5dda5b68 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -414,7 +414,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		if (atomic_read(&dest->weight) > 0) {
 			least = dest;
@@ -429,7 +429,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
@@ -502,7 +502,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		 */
 
 		dest = en->dest;
-		if ((dest->flags & IP_VS_DEST_F_AVAILABLE) &&
+		if ((atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE) &&
 		    atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
 			goto out;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c90ea897c3f7..48f02453a5be 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -166,11 +166,11 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry_rcu(e, &set->list, list) {
 		least = e->dest;
-		if (least->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&least->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-		if ((atomic_read(&least->weight) > 0)
-		    && (least->flags & IP_VS_DEST_F_AVAILABLE)) {
+		if ((atomic_read(&least->weight) > 0)
+		    && (atomic_read(&least->flags) & IP_VS_DEST_F_AVAILABLE)) {
 			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
@@ -181,13 +181,13 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
   nextstage:
 	list_for_each_entry_continue_rcu(e, &set->list, list) {
 		dest = e->dest;
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
 		if (((__s64)loh * atomic_read(&dest->weight) >
-		     (__s64)doh * atomic_read(&least->weight))
-		    && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+		     (__s64)doh * atomic_read(&least->weight))
+		    && (atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)) {
 			least = dest;
 			loh = doh;
 		}
@@ -577,7 +577,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
 		if (atomic_read(&dest->weight) > 0) {
@@ -593,7 +593,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 38cc38c5d8bb..6acb3c904af5 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -38,7 +38,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if ((atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 020863047562..c322ed1754b7 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -80,7 +80,7 @@ static inline void generate_hash_secret(hsiphash_key_t *hash1,
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD;
 }
 
 /* Returns hash value for IPVS MH entry */
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index ada158c610ce..ffa4bfeb21d9 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -72,7 +72,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD ||
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD ||
 		    !atomic_read(&dest->weight))
 			continue;
 
diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
index c5c67df80a0b..f7f17dddbb05 100644
--- a/net/netfilter/ipvs/ip_vs_ovf.c
+++ b/net/netfilter/ipvs/ip_vs_ovf.c
@@ -33,7 +33,7 @@ ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	*/
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		w = atomic_read(&dest->weight);
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if ((atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->activeconns) > w ||
 		    w == 0)
 			continue;
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 4125ee561cdc..98453d205d6f 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -66,7 +66,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) &&
 			    atomic_read(&dest->weight) > 0)
 				/* HIT */
 				goto out;
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 245a323c84cd..0249062d1360 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -75,7 +75,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_sed_dest_overhead(least);
@@ -90,7 +90,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index cd67066e3b26..343780b82c95 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -73,7 +73,7 @@ struct ip_vs_sh_state {
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD;
 }
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_twos.c b/net/netfilter/ipvs/ip_vs_twos.c
index dbb7f5fd4688..35fa4c6dc5cf 100644
--- a/net/netfilter/ipvs/ip_vs_twos.c
+++ b/net/netfilter/ipvs/ip_vs_twos.c
@@ -52,7 +52,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Generate a random weight between [0,sum of all weights) */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD)) {
+		if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)) {
 			weight = atomic_read(&dest->weight);
 			if (weight > 0) {
 				total_weight += weight;
@@ -75,7 +75,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Pick two weighted servers */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
 		weight = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 9da445ca09a1..c2d09ac96fe8 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -47,7 +47,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_dest_conn_overhead(least);
@@ -62,7 +62,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 2dcff1040da5..f21a75284971 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -176,7 +176,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!(atomic_read(&dest->flags) & IP_VS_DEST_F_OVERLOAD) &&
 			    atomic_read(&dest->weight) >= mark->cw)
 				goto found;
 			if (dest == stop)
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ce542ed4b013..37b9671e4960 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -351,7 +351,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			 * stored in dest_trash.
 			 */
 			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
-			    dest->flags & IP_VS_DEST_F_AVAILABLE)
+			    atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)
 				__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
 			else
 				noref = 0;
@@ -530,7 +530,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			 * stored in dest_trash.
 			 */
 			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
-			    dest->flags & IP_VS_DEST_F_AVAILABLE)
+			    atomic_read(&dest->flags) & IP_VS_DEST_F_AVAILABLE)
 				__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
 			else
 				noref = 0;

