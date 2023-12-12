Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Q0f1qWr/"
Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 18526DB
	for <lvs-devel@vger.kernel.org>; Tue, 12 Dec 2023 08:30:27 -0800 (PST)
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id AE3F81E098;
	Tue, 12 Dec 2023 18:30:25 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id 9093E1DE51;
	Tue, 12 Dec 2023 18:30:25 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 64D1A3C07D2;
	Tue, 12 Dec 2023 18:30:12 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1702398612; bh=KjEIq9gif1Gkj7PVtooN+W8tx5iL2XwqlO2KORUTVSc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Q0f1qWr/yZOzsKNvVBUFRAcwO5fSmkKR5GGUWaN5rdJU+req0xVzYJD4gfP2pKMvz
	 FO5j6EgeKDaWO0Qhbp1878x1Wg08h/+h//MmWihzBHk7cv4ZPnD3z9p+lGFY1AG11f
	 hEive0ZMKcYlr3j131i/YF3bkKODgZwrlCmmer5U=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 3BCGQUHb094066;
	Tue, 12 Dec 2023 18:26:30 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 3BCGQU83094065;
	Tue, 12 Dec 2023 18:26:30 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>,
        Jiri Wiesner <jwiesner@suse.de>
Subject: [PATCHv2 RFC net-next 05/14] ipvs: do not keep dest_dst after dest is removed
Date: Tue, 12 Dec 2023 18:24:35 +0200
Message-ID: <20231212162444.93801-6-ja@ssi.bg>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20231212162444.93801-1-ja@ssi.bg>
References: <20231212162444.93801-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Before now dest->dest_dst is not released when server is moved into
dest_trash list after removal. As result, we can keep dst/dev
references for long time without actively using them.

It is better to avoid walking the dest_trash list when
ip_vs_dst_event() receives dev events. So, make sure we do not
hold dev references in dest_trash list. As packets can be flying
while server is being removed, check the IP_VS_DEST_F_AVAILABLE
flag in slow path to ensure we do not save new dev references to
removed servers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c  | 20 +++++++----------
 net/netfilter/ipvs/ip_vs_xmit.c | 39 ++++++++++++++++++++++++---------
 2 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e325e5f9d37b..7a8c7ac94194 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -810,7 +810,6 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
 {
 	struct ip_vs_service *svc = rcu_dereference_protected(dest->svc, 1);
 
-	__ip_vs_dst_cache_reset(dest);
 	__ip_vs_svc_put(svc);
 	call_rcu(&dest->rcu_head, ip_vs_dest_rcu_free);
 }
@@ -1013,10 +1012,6 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 
 	dest->af = udest->af;
 
-	spin_lock_bh(&dest->dst_lock);
-	__ip_vs_dst_cache_reset(dest);
-	spin_unlock_bh(&dest->dst_lock);
-
 	if (add) {
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
@@ -1024,6 +1019,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		if (sched && sched->add_dest)
 			sched->add_dest(svc, dest);
 	} else {
+		spin_lock_bh(&dest->dst_lock);
+		__ip_vs_dst_cache_reset(dest);
+		spin_unlock_bh(&dest->dst_lock);
+
 		sched = rcu_dereference_protected(svc->scheduler, 1);
 		if (sched && sched->upd_dest)
 			sched->upd_dest(svc, dest);
@@ -1258,6 +1257,10 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 {
 	dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
 
+	spin_lock_bh(&dest->dst_lock);
+	__ip_vs_dst_cache_reset(dest);
+	spin_unlock_bh(&dest->dst_lock);
+
 	/*
 	 *  Remove it from the d-linked destination list.
 	 */
@@ -1747,13 +1750,6 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	}
 	rcu_read_unlock();
 
-	mutex_lock(&ipvs->service_mutex);
-	spin_lock_bh(&ipvs->dest_trash_lock);
-	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
-		ip_vs_forget_dev(dest, dev);
-	}
-	spin_unlock_bh(&ipvs->dest_trash_lock);
-	mutex_unlock(&ipvs->service_mutex);
 	return NOTIFY_DONE;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9193e109e6b3..d7499f1e3af2 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -317,9 +317,11 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
-		if (likely(dest_dst))
+		if (likely(dest_dst)) {
 			rt = (struct rtable *) dest_dst->dst_cache;
-		else {
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.ip;
+		} else {
 			dest_dst = ip_vs_dest_dst_alloc();
 			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
@@ -335,14 +337,24 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
-			__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+			/* It is forbidden to attach dest->dest_dst if
+			 * server is deleted. We can see the flag going down,
+			 * for very short period and it must be checked under
+			 * dst_lock.
+			 */
+			if (dest->flags & IP_VS_DEST_F_AVAILABLE)
+				__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+			else
+				noref = 0;
 			spin_unlock_bh(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
 				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  rcuref_read(&rt->dst.__rcuref));
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.ip;
+			if (!noref)
+				ip_vs_dest_dst_free(dest_dst);
 		}
-		if (ret_saddr)
-			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
 		__be32 saddr = htonl(INADDR_ANY);
 
@@ -480,9 +492,11 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
-		if (likely(dest_dst))
+		if (likely(dest_dst)) {
 			rt = (struct rt6_info *) dest_dst->dst_cache;
-		else {
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.in6;
+		} else {
 			u32 cookie;
 
 			dest_dst = ip_vs_dest_dst_alloc();
@@ -503,14 +517,19 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			}
 			rt = (struct rt6_info *) dst;
 			cookie = rt6_get_cookie(rt);
-			__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
+			if (dest->flags & IP_VS_DEST_F_AVAILABLE)
+				__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
+			else
+				noref = 0;
 			spin_unlock_bh(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
 				  &dest->addr.in6, &dest_dst->dst_saddr.in6,
 				  rcuref_read(&rt->dst.__rcuref));
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.in6;
+			if (!noref)
+				ip_vs_dest_dst_free(dest_dst);
 		}
-		if (ret_saddr)
-			*ret_saddr = dest_dst->dst_saddr.in6;
 	} else {
 		noref = 0;
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm,
-- 
2.43.0


