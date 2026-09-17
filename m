Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1125737C0E5;
	Thu, 17 Sep 2026 20:06:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789675610; cv=none; b=GWUnxqnX39TM3fE1r0RReFFT6KyBf8CE2iNJgn6+cNO8d9y+HYaMjqc3vibIWqmSVjpV355OAEPsw5FZp9f2paBpdsdvmwFVdddRUUlrJMhE1pyOig16uEk5sQ/p4oT76K21Ns0pLDOrl8vBMjqfBddZz1TFWR3XgYBUw0UKFWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789675610; c=relaxed/simple;
	bh=ZZQ/avcGSAm11gyhVAkGrrp/9Iv+ncyt2Zh1D9cMgPM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=tRaVIRPLEGSXGKC86/6+5xaRYlKoRl8bJIqsIxXcxVgz7Mf9k0pX9PQyHzSRRK0NmYC7umIDtgTVC0aOhtmtllGHH+BtZMVsCGVoBbfKq9YaIFJAvIJ3Jrup3VAijVIauDFtEIkkwzyr8bDtO9XZyGL+kMOKN3NOFm/FXlI+5kQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=0vEAye+p; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="0vEAye+p"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B695B22530;
	Thu, 17 Sep 2026 23:06:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=qcOazlMemARvwnoI7P2eb9P5WcQepLyqvvE2qLRuLgE=; b=0vEAye+pHG8K
	Tc5peVA+ez+e09/iKVSQ1HjU1X0/8a4FjYKqwHXlNgnCMTZD9uZjzAwDR2HwnwkP
	pexciXI/ltZ3jxES+a6gsgAUw+7ARGj9bDyviQLJoOJ/jgmgAjbgpNMnWUPQ1RYD
	Ggz2WPwGbNxSrsDpo+5fbJ3nCLJ68aNBu95HNp86dUua+3aHQci7JnWcmTzmGD8V
	aeRHcYk4b1PaPrGTwqpgOPlQ73b8QSPq66sr53raM3YJ9TcgxnQ7opQbXeRowsdT
	VYoP6BUsga7JdssZC/a85pcYdq2hKRnpdAJwmGniHjMNLfXQga7bKa2BbrpuCM5M
	17v8wmHtBChud5LeLsOt7TQTDUKKcbGMtCmO4XmACyqODuZaf8s4jR2GBDUui/c3
	1g9slzmhP4nGeQmBS28RKz7uro4N3dJD7myNjBo9QNwCuoQ7bdIliWRkqKPRylOf
	/oClzhfnsfdRW5F2aVel3gpMDw7ppOBoNYOf1InHfqdDjZwETy6+3WYqqzIVA4ef
	QUQwwHboqck4wDjJ7yBBXdJMa0NYCkID+VTJzVTyq//nEZq4pf1rjwKgDUIXV6KS
	vE4SEk72KxjKDv6NZH35Ex1UrqTwGJ9CKpqyqU0NU75F/Bf4zptrkbIu4NJefTIl
	ub/2XzFLQM2owYTnJZSjavwsbAJhI6A=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 17 Sep 2026 23:06:32 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 345E7603B1;
	Thu, 17 Sep 2026 23:06:34 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68HK6JPt087464;
	Thu, 17 Sep 2026 23:06:20 +0300
Date: Thu, 17 Sep 2026 23:06:19 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Jiayuan Chen <jiayuan.chen@linux.dev>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, darby.payne@gmail.com, vega@nebusec.ai,
        zzyy19904204639@163.com, Ren Wei <weir@nebusec.ai>
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
In-Reply-To: <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev>
Message-ID: <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg>
References: <cover.1789117690.git.zzyy19904204639@163.com> <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg> <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-792031271-1789675586=:71150"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-792031271-1789675586=:71150
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 17 Sep 2026, Jiayuan Chen wrote:

> 
> On 9/15/26 2:01 AM, Julian Anastasov wrote:
> >
> > 	I assume the problem is caused by the dest_trash.
> > It seems, we need a general solution to this problem.
> > One option is to penalize with synchronize_rcu() if we detect
> > dest that is reused too soon. But even that looks complex to
> > implement.
> 
> 
> I think we can use pair(get_state_synchronize_rcu, cond_synchronize_rcu)
> instead.
> For 'ipvsadm -C && ipvsadm -R', synchronize_rcu is only called once.
> 
> 
> From ccbb304ab17e00849ea0bf31582d384e6b2768ba Mon Sep 10 00:00:00 2001
> From: Jiayuan Chen <jiayuan.chen@linux.dev>
> Date: Thu, 10 Sep 2026 19:36:57 +0800
> Subject: [PATCH] ipvs: wait for readers before reusing dest from trash
> 
> __ip_vs_unlink_dest() and ip_vs_rs_unhash() remove the dest with
> list_del_rcu()/hlist_del_rcu(), so readers can still be on it. If
> ip_vs_add_dest() picks the same dest from trash right away,
> __ip_vs_update_dest() links it into another service and rs_table,
> and those readers follow the new next pointers into a different
> list.
> 
> A synchronize_rcu() on the delete side costs one grace period per
> dest, which makes 'ipvsadm -C' with many real servers very slow.
> Doing it on the reuse side has the same problem with 'ipvsadm -R'.
> So record a grace period cookie when the dest goes to trash and use
> cond_synchronize_rcu() on reuse. The first wait covers every dest
> trashed before it, so a full restore waits at most once.
> 
> Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
> ---
>  include/net/ip_vs.h            | 1 +
>  net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
>  2 files changed, 7 insertions(+)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 32fde731bceb..81b7600ac959 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1013,6 +1013,7 @@ struct ip_vs_dest {
> 
>      struct rcu_head        rcu_head;
>      struct list_head    t_list;        /* in dest_trash */
> +    unsigned long        rcu_state;    /* GP cookie when trashed */
>      unsigned int        in_rs_table:1;    /* we are in rs_table */
>  };
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 4c1c739446b7..99da7b74500f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1159,6 +1159,7 @@ static void ip_vs_trash_put_dest(struct netns_ipvs
> *ipvs,
>      /* dest lives in trash with reference */
>      list_add(&dest->t_list, &ipvs->dest_trash);
>      dest->idle_start = istart;
> +    dest->rcu_state = get_state_synchronize_rcu();
>      spin_unlock_bh(&ipvs->dest_trash_lock);
>  }
> 
> @@ -1566,6 +1567,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct
> ip_vs_dest_user_kern *udest)
>                    IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
>                    ntohs(dest->vport));
> 
> +        /* Readers may still follow n_list/d_list of the unlinked
> +         * dest, wait before linking it again.
> +         */
> +        cond_synchronize_rcu(dest->rcu_state);
> +
>          ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
>          /* On error put back dest into the trash */
>          if (ret < 0)
> --
> 2.43.0

	Very good solution, indeed. But it needed some tuning
and some other problems need to be solved:

- if dest is edited and the dest tunnel parameters changed
this leads to rehashing and a forced synchronize_rcu(). If
many dests are changed in this way - we got a coffee time...

- dest can be put back into dest_trash, so we do not need to
update the rcu_state for this case

- use single temp list dest_trash to speedup the deleting of
service (with many dests) and the service flush (many services with
many dests) by using single get_state_synchronize_rcu (which has
full memory barrier) and by splicing the temp list with all
deleted dests into the public dest_trash list by using single
spin lock (ip_vs_trash_put_dests call).

	This is only compile-tested and I hope it can survive
the flood tests that break the "two" scheduler lookups...

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e09b9598a476..2ed6fe86fa73 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1021,6 +1021,7 @@ struct ip_vs_dest {
 
 	struct rcu_head		rcu_head;
 	struct list_head	t_list;		/* in dest_trash */
+	unsigned long		rcu_state;	/* GP cookie when trashed */
 	unsigned int		in_rs_table:1;	/* we are in rs_table */
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5de69404a5e0..d29dde6a61fd 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -64,7 +64,8 @@ int ip_vs_get_debug_level(void)
 
 
 /*  Protos */
-static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup);
+static void __ip_vs_del_service(struct ip_vs_service *svc,
+				struct list_head *dest_trash, bool cleanup);
 
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -883,7 +884,8 @@ static inline unsigned int ip_vs_rs_hashkey(int af,
 }
 
 /* Hash ip_vs_dest in rs_table by <proto,addr,port>. */
-static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
+static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
+			  bool need_gp)
 {
 	unsigned int hash;
 	__be16 port;
@@ -918,6 +920,9 @@ static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 	 */
 	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, port);
 
+	/* Need RCU grace period when rehashing */
+	if (need_gp)
+		synchronize_rcu();
 	hlist_add_head_rcu(&dest->d_list, &ipvs->rs_table[hash]);
 	dest->in_rs_table = 1;
 }
@@ -1144,24 +1149,59 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 	return dest;
 }
 
-/* Put destination in trash */
-static void ip_vs_trash_put_dest(struct netns_ipvs *ipvs,
+/* Add destination in temp list for trash */
+static void ip_vs_trash_add_dest(struct netns_ipvs *ipvs,
 				 struct ip_vs_dest *dest, unsigned long istart,
-				 bool cleanup)
+				 struct list_head *dest_trash)
 {
-	spin_lock_bh(&ipvs->dest_trash_lock);
 	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
 		      refcount_read(&dest->refcnt));
+	/* dest lives in trash with reference */
+	list_add(&dest->t_list, dest_trash);
+	dest->idle_start = istart;
+}
+
+/* Put destinations in trash */
+static void ip_vs_trash_put_dests(struct netns_ipvs *ipvs,
+				  struct list_head *dest_trash, bool cleanup)
+{
+	spin_lock_bh(&ipvs->dest_trash_lock);
 	if (list_empty(&ipvs->dest_trash) && !cleanup)
 		mod_timer(&ipvs->dest_trash_timer,
 			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
-	/* dest lives in trash with reference */
-	list_add(&dest->t_list, &ipvs->dest_trash);
-	dest->idle_start = istart;
+	list_splice(dest_trash, &ipvs->dest_trash);
 	spin_unlock_bh(&ipvs->dest_trash_lock);
 }
 
+/* Put destination back in trash */
+static void ip_vs_trash_put_back(struct netns_ipvs *ipvs,
+				 struct ip_vs_dest *dest)
+{
+	LIST_HEAD(dest_trash);
+
+	list_add(&dest->t_list, &dest_trash);
+	ip_vs_trash_add_dest(ipvs, dest, dest->idle_start, &dest_trash);
+	ip_vs_trash_put_dests(ipvs, &dest_trash, false);
+}
+
+/* Put destinations in trash and save the RCU state */
+static void ip_vs_trash_save_dests(struct netns_ipvs *ipvs,
+				   struct list_head *dest_trash, bool cleanup)
+{
+	struct ip_vs_dest *dest;
+	unsigned long rcu_state;
+
+	if (!list_empty(dest_trash)) {
+		/* Remember when dests were removed and added to dest_trash */
+		rcu_state = get_state_synchronize_rcu();
+		list_for_each_entry(dest, dest_trash, t_list) {
+			dest->rcu_state = rcu_state;
+		}
+		ip_vs_trash_put_dests(ipvs, dest_trash, cleanup);
+	}
+}
+
 static void ip_vs_dest_rcu_free(struct rcu_head *head)
 {
 	struct ip_vs_dest *dest;
@@ -1348,6 +1388,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct netns_ipvs *ipvs = svc->ipvs;
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
+	bool need_gp = false;
 	int conn_flags;
 
 	/* We cannot modify an address and change the address family */
@@ -1369,8 +1410,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	if ((udest->conn_flags & IP_VS_CONN_F_FWD_MASK) !=
 	    IP_VS_DFWD_METHOD(dest) ||
 	    udest->tun_type != dest->tun_type ||
-	    udest->tun_port != dest->tun_port)
+	    udest->tun_port != dest->tun_port) {
+		need_gp = dest->in_rs_table;
 		ip_vs_rs_unhash(dest);
+	}
 
 	/* set the tunnel info */
 	dest->tun_type = udest->tun_type;
@@ -1387,7 +1430,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	}
 	atomic_set(&dest->conn_flags, conn_flags);
 	/* Put the real service in rs_table if not present. */
-	ip_vs_rs_hash(ipvs, dest);
+	ip_vs_rs_hash(ipvs, dest, need_gp);
 
 	/* bind the service */
 	old_svc = rcu_dereference_protected(dest->svc, 1);
@@ -1566,11 +1609,16 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
 		/* On error put back dest into the trash */
-		if (ret < 0)
-			ip_vs_trash_put_dest(svc->ipvs, dest, dest->idle_start,
-					     false);
-		else
+		if (ret < 0) {
+			ip_vs_trash_put_back(svc->ipvs, dest);
+		} else {
+			/* Readers may still follow n_list/d_list of the
+			 * unlinked dest, wait before linking it again.
+			 */
+			cond_synchronize_rcu(dest->rcu_state);
+
 			__ip_vs_update_dest(svc, dest, udest, 1);
+		}
 	} else {
 		/*
 		 * Allocate and initialize the dest structure
@@ -1634,7 +1682,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
  *	Delete a destination (must be already unlinked from the service)
  */
 static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
-			     bool cleanup)
+			     struct list_head *dest_trash, bool cleanup)
 {
 	ip_vs_stop_estimator(ipvs, &dest->stats);
 
@@ -1643,7 +1691,7 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	 */
 	ip_vs_rs_unhash(dest);
 
-	ip_vs_trash_put_dest(ipvs, dest, 0, cleanup);
+	ip_vs_trash_add_dest(ipvs, dest, 0, dest_trash);
 
 	/* Queue up delayed work to expire all no destination connections.
 	 * No-op when CONFIG_SYSCTL is disabled.
@@ -1693,6 +1741,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	__be16 dport = udest->port;
+	LIST_HEAD(dest_trash);
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
@@ -1712,8 +1761,9 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(svc->ipvs, dest, false);
+	__ip_vs_del_dest(svc->ipvs, dest, &dest_trash, false);
 
+	ip_vs_trash_save_dests(svc->ipvs, &dest_trash, false);
 	return 0;
 }
 
@@ -2057,7 +2107,8 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
  *	- The service must be unlinked, unlocked and not referenced!
  *	- We are called under _bh lock
  */
-static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
+static void __ip_vs_del_service(struct ip_vs_service *svc,
+				struct list_head *dest_trash, bool cleanup)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
@@ -2091,7 +2142,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(svc->ipvs, dest, cleanup);
+		__ip_vs_del_dest(svc->ipvs, dest, dest_trash, cleanup);
 	}
 
 	/*
@@ -2114,7 +2165,8 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 /*
  * Unlink a service from list and try to delete it if its refcnt reached 0
  */
-static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
+static void ip_vs_unlink_service(struct ip_vs_service *svc,
+				 struct list_head *dest_trash, bool cleanup)
 {
 	ip_vs_unregister_conntrack(svc);
 	/* Hold svc to avoid double release from dest_trash */
@@ -2124,7 +2176,7 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	ip_vs_svc_unhash(svc);
 
-	__ip_vs_del_service(svc, cleanup);
+	__ip_vs_del_service(svc, dest_trash, cleanup);
 }
 
 /*
@@ -2134,12 +2186,14 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 {
 	struct netns_ipvs *ipvs;
 	struct ip_vs_rht *t, *p;
+	LIST_HEAD(dest_trash);
 	int ns;
 
 	if (svc == NULL)
 		return -EEXIST;
 	ipvs = svc->ipvs;
-	ip_vs_unlink_service(svc, false);
+	ip_vs_unlink_service(svc, &dest_trash, false);
+	ip_vs_trash_save_dests(ipvs, &dest_trash, false);
 
 	/* Drop the table if no more services */
 	ns = ip_vs_get_num_services(ipvs);
@@ -2190,6 +2244,7 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	struct hlist_bl_node *ne;
 	struct hlist_bl_node *e;
 	struct ip_vs_rht *t, *p;
+	LIST_HEAD(dest_trash);
 
 	/* Stop the resizer and drop the tables */
 	if (!test_and_set_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
@@ -2199,8 +2254,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	if (ip_vs_get_num_services(ipvs)) {
 		ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
 			hlist_bl_for_each_entry_safe(svc, e, ne, head, s_list)
-				ip_vs_unlink_service(svc, cleanup);
+				ip_vs_unlink_service(svc, &dest_trash, cleanup);
 		}
+		ip_vs_trash_save_dests(ipvs, &dest_trash, cleanup);
 	}
 
 	/* Unregister the hash table and release it after RCU grace period */

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-792031271-1789675586=:71150--

