Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.172
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794190017;
	b=IoDXVtGo4jg92m6yG7hzc4BLU0WbqKLlkb6t3YNbf2YMscgIYjOuWj0d9QkfsEjz24a2
	 SNaaeIti+wnKNeAFKEvDp46P5PIdzMfH4x0cilDvHK04bn+Jt/4+RgISPUFbF5sEupHSj
	 yG1tT0x14yb27oJ6lrVQg1RtGo7srH206Tm5uHoVfYr4O3rO/8oTZUo3ur+9YO/92HUC7
	 MD9t90tSoLQN+WTpR36id1owAWqvIJBif7ZO4s5CGoPRyD2GlL5Gkfv2Z8eXKNLE4NA2w
	 FKj1lc3lqI6U+1Hf4k1qUzd3dbhxkF4DytoaroGUOn1NaySaH/jKxAd1/bYHmSO7W/g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794190017;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=mJXHwV9S+YJJdv8FCMhmcbrWQshrRjANPkjQmNxFO2s=;
	b=3eZC1LQWm2WqJy3+bxwyOI/2q9mal2EiWj+7UHYEb+AGzaHitJ6geY5lT8UUZ8Rh4pkj
	 B4pa6g1S0i43DMODHJFdLG5WgrOgYh/qV4N0xsF9SxKhkq3A3C+SVoX/FAP5HLbgN2Z+3
	 b5bDjbIjQ9OYb6/NYJ1NCbqa7Om9N1h35wflw2VLG+pIGH1rtm9ilxEFsX6D7TOTW0Yi3
	 wRoAKzwEcVr3uI5LRUaA4Y5J0VdE745CVaRaazfQPjzvBz3qabPiPSprlDrExDjSyjfM5
	 LCI4/NmFXq1Fcz1cPPJAu5ADf7v/ZQ0zDZ1gS3lRI3Sa0RYAwDAxF7/gCKmNxbqBaug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nebusec.ai;
	spf=pass smtp.mailfrom=nebusec.ai;
	dkim=pass header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=syP29jTn;
	arc=none smtp.remote-ip=209.85.214.172
Received: from mail-pl1-f172.google.com (mail-pl1-f172.google.com [209.85.214.172])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A1C6606A31C
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:06:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A1C6606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.a=rsa-sha256 header.s=google header.b=syP29jTn
Received: by mail-pl1-f172.google.com with SMTP id d9443c01a7336-2ed1414df17so1166355ad.2
        for <lvs-devel@vger.kernel.org>; Sun, 08 Nov 2026 18:06:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1794190016; x=1794794816; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=mJXHwV9S+YJJdv8FCMhmcbrWQshrRjANPkjQmNxFO2s=;
        b=syP29jTnwHq+uFxOzKOBgmrs4vd8O8Qx1j6xw56dHz7XDMZprBmsKqXbW1NcHotazD
         gCv75BWJBzdyGUJ84HZmzOsGyrUk2JOUS3Sah9H3VhZm+DB66uK6ev+ajj6DEys6lQIa
         biDtaKc6Glwh1XcgzztE6WIr/BZe4CyIsitbXurUYwpCJNkiM/RRq0r3EhscwMf+X8Mu
         5R04R6XIdNzU8YGevKW3AEpJVLRfNJuCZANT/kvoUSFxys/s1sFWZGdG+jHIJMRfllDf
         Od3DLGZQU9meOoijrB7upWhgDWq74klk8azjxTZV4Ar8neSrPauuJwrWc6nxfEXRJ/vk
         xmOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794190016; x=1794794816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mJXHwV9S+YJJdv8FCMhmcbrWQshrRjANPkjQmNxFO2s=;
        b=JNdVH0XlHVcdoYgfkRrA1cXvLJgDsg4r4vYIhm9pLyKZj0g7F+jAH9l+PvyEI8giTQ
         PsJg11KBjpjgaINrUnRFHJyAqp1559WwtfSxMdV+oVT8iqiAeNbCFSFUufjYp2dkSnLn
         lbFU53goJig+3zjUWwSFz9ofzA3j7J+As5LU9C3a6RfgEz7ZSymfln7YyqjhT+bo6hQ3
         D4mrZ65vQlNIDI8zGSma8Pwoxr8MThU+ironj2FfcVXK7QV3PG7p+51E9rLf2XiDrE00
         QWjX2zRtlGdWfbuHksKjVhK6dnmMDPwdVM66Ktp3nhtpJG08i2d+/Qx0mC1L+LYYTjDw
         QRjg==
X-Gm-Message-State: APuU4Z/TI6EfcGJQBvLjcBM6B8EsgfEgJwF+7Awp+plgh/mAxypFzuUP
	T/N5ansB8bwfFBdpLyz4SNT86UqS7KqW3OqkVO61fEaJd2R8sVfN0iCMDV4zF7Knv2o2h0vpzT+
	2yLAptw==
X-Gm-Gg: AYBFou0ckjjEUnJ6GZz/Df/ufro+D8HvVIxvTXNTQJPseLqmbFShCc5XI7Wrt9cQWEm
	sXPA1JdVScOCzcZsK7VyxjK2sQiQhTFeByNWSDjTTL9OHZ5vgJm1DP0RYQdSZuqyZn/Uy6I6htT
	25IA8SWVLqIQlO6zY8FupBsxetIsLO2xw35pRE6I3tFJ9xBbfalhDeoDWZpYXIwMPbgvT+pfHkX
	X8s6mambrB7w+F1QC/gK2OGrXtqL0o/uM9sACN+dUCGxcXBGKaPjX5HWftUtM1RSZka1d+BjgEh
	nLle9e8gwkWDDZ5zwDih8eIJtjIoyklSpS6VNp01f+ksoBUdsOsZxAaTmaU14FbJ6Yq0lS1RGU0
	4rCRq3SxmuZ5HYjFvE760nKcmVU4MgHBBi0mH5p6PZ5A0bbeOBuLP7ePkNd9lgtvCX58ecCTY8V
	0b1QucTewLg49Vq58TG/Xz13I1NZE34HJPTNnlNP91YItDCbK1Q775YPfhCtqJ4Mh+F7aMtIwoM
	m7/GH9K2S/qRQwGuiNJwsXBetoPR1l5sZIma1Paest9V/6lLOh38tRzksQiyCoJxsZA0DdpLwjs
	pCHVW9hTEgnXpJh/6HLeGg8WNkPn5bfSKc3i
X-Received: by 2002:a17:902:e54b:b0:2e8:295c:f03d with SMTP id d9443c01a7336-2ed8379d69amr30642025ad.58.1794190015454;
        Sun, 08 Nov 2026 18:06:55 -0800 (PST)
Received: from enjou-Legion-Y7000P-2019 ([74.52.12.168])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2ed815e73f3sm6757285ad.22.2026.11.08.18.06.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Nov 2026 18:06:54 -0800 (PST)
From: Ren Wei <weir@nebusec.ai>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au,
	dsahern@kernel.org,
	idosch@nvidia.com,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	vega@nebusec.ai,
	zzyy19904204639@163.com,
	jiayuan.chen@linux.dev,
	weir@nebusec.ai
Subject: [PATCH net v3 1/1] ipvs: wait grace period before reusing destinations
Date: Mon,  9 Nov 2026 10:06:47 +0800
Message-ID: <f552f176c8387c819e748c93c0fb99de70e4406d.git.zzyy19904204639@163.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Darong Lu <zzyy19904204639@163.com>

An IPVS destination can be removed from a service and immediately reused
from dest_trash before an RCU grace period has elapsed. Reusing its n_list
or d_list can make existing readers follow links into another service or
real-server hash chain.

The grace-period cookie is also saved when a live destination is unhashed
for an edit and consumed when it is rehashed. Describe rcu_state as the
cookie for an unlink, covering both trash and rehash cases.

When a destination is retrieved from dest_trash, ip_vs_add_dest() currently
restarts its estimator before waiting for the grace period.
If the estimator was on a tick chain, ip_vs_stop_estimator() removed
est->list with hlist_del_rcu(), so an estimator kthread can still be
traversing that node.
ip_vs_start_estimator() rewrites the node on its temporary list on success,
or initializes it on failure, before the current wait. A reader can then
follow the changed link or stop traversing the chain early.

Wait immediately after retrieving the destination, before starting its
estimator. The conditional grace-period wait then covers the destination
list, real-server hash and estimator list on both estimator success and
failure paths.

Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Reported-by: Darong Lu <zzyy19904204639@163.com>
Co-developed-by: Jiayuan Chen <jiayuan.chen@linux.dev>
Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Darong Lu <zzyy19904204639@163.com>
Signed-off-by: Ren Wei <weir@nebusec.ai>

---
Changes since v2:

  - Wait immediately after retrieving a destination from trash, before
    starting its estimator. This protects the estimator list on both
    success and failure paths.
  - Clarify that rcu_state stores the cookie for trash and rehash unlinks.

v2 Link: https://lore.kernel.org/all/cover.1789473164.git.zzyy19904204639@163.com/
---
 include/net/ip_vs.h            |   4 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 110 ++++++++++++++++++++++++++-------
 2 files changed, 91 insertions(+), 23 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 32fde731bceb..fdffc8f927f3 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1013,7 +1013,9 @@ struct ip_vs_dest {
 
 	struct rcu_head		rcu_head;
 	struct list_head	t_list;		/* in dest_trash */
-	unsigned int		in_rs_table:1;	/* we are in rs_table */
+	unsigned long		rcu_state;	/* GP cookie on unlink (trash or rehash) */
+	unsigned int		in_rs_table:1,	/* we are in rs_table */
+				need_gp:1;	/* Need GP on rehash */
 };
 
 /* The scheduler object */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4c1c739446b7..ad59b97079ff 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -64,7 +64,8 @@ int ip_vs_get_debug_level(void)
 
 
 /*  Protos */
-static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup);
+static void __ip_vs_del_service(struct ip_vs_service *svc,
+				struct list_head *dest_trash, bool cleanup);
 
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -918,6 +919,11 @@ static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 	 */
 	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, port);
 
+	/* Need RCU grace period when rehashing */
+	if (dest->need_gp) {
+		cond_synchronize_rcu(dest->rcu_state);
+		dest->need_gp = 0;
+	}
 	hlist_add_head_rcu(&dest->d_list, &ipvs->rs_table[hash]);
 	dest->in_rs_table = 1;
 }
@@ -1111,6 +1117,8 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 	struct ip_vs_dest *dest;
 	struct netns_ipvs *ipvs = svc->ipvs;
 
+	lockdep_assert_held(&ipvs->service_mutex);
+
 	/*
 	 * Find the destination in trash
 	 */
@@ -1144,24 +1152,57 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
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
+		list_for_each_entry(dest, dest_trash, t_list)
+			dest->rcu_state = rcu_state;
+		ip_vs_trash_put_dests(ipvs, dest_trash, cleanup);
+	}
+}
+
 static void ip_vs_dest_rcu_free(struct rcu_head *head)
 {
 	struct ip_vs_dest *dest;
@@ -1369,8 +1410,16 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	if ((udest->conn_flags & IP_VS_CONN_F_FWD_MASK) !=
 	    IP_VS_DFWD_METHOD(dest) ||
 	    udest->tun_type != dest->tun_type ||
-	    udest->tun_port != dest->tun_port)
+	    udest->tun_port != dest->tun_port) {
+		bool unlinked = dest->in_rs_table;
+
 		ip_vs_rs_unhash(dest);
+		if (unlinked) {
+			dest->rcu_state = get_state_synchronize_rcu();
+			/* Need grace period in this or next dest update */
+			dest->need_gp = 1;
+		}
+	}
 
 	/* set the tunnel info */
 	dest->tun_type = udest->tun_type;
@@ -1558,6 +1607,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest = ip_vs_trash_get_dest(svc, udest->af, &daddr, dport);
 
 	if (dest != NULL) {
+		/* Readers may still follow the n_list, d_list or estimator list
+		 * links. Wait before reusing any of them.
+		 */
+		cond_synchronize_rcu(dest->rcu_state);
+
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
 			      "dest->refcnt=%d, service %u/%s:%u\n",
 			      IP_VS_DBG_ADDR(udest->af, &daddr), ntohs(dport),
@@ -1568,11 +1622,14 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
 		/* On error put back dest into the trash */
-		if (ret < 0)
-			ip_vs_trash_put_dest(svc->ipvs, dest, dest->idle_start,
-					     false);
-		else
+		if (ret < 0) {
+			ip_vs_trash_put_back(svc->ipvs, dest);
+		} else {
+			/* need_gp matters only on dest edit, reinit it */
+			dest->need_gp = 0;
+
 			__ip_vs_update_dest(svc, dest, udest, 1);
+		}
 	} else {
 		/*
 		 * Allocate and initialize the dest structure
@@ -1636,7 +1693,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
  *	Delete a destination (must be already unlinked from the service)
  */
 static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
-			     bool cleanup)
+			     struct list_head *dest_trash, bool cleanup)
 {
 	ip_vs_stop_estimator(ipvs, &dest->stats);
 
@@ -1645,7 +1702,7 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	 */
 	ip_vs_rs_unhash(dest);
 
-	ip_vs_trash_put_dest(ipvs, dest, 0, cleanup);
+	ip_vs_trash_add_dest(ipvs, dest, 0, dest_trash);
 
 	/* Queue up delayed work to expire all no destination connections.
 	 * No-op when CONFIG_SYSCTL is disabled.
@@ -1695,6 +1752,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	__be16 dport = udest->port;
+	LIST_HEAD(dest_trash);
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
@@ -1714,7 +1772,9 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(svc->ipvs, dest, false);
+	__ip_vs_del_dest(svc->ipvs, dest, &dest_trash, false);
+
+	ip_vs_trash_save_dests(svc->ipvs, &dest_trash, false);
 
 	return 0;
 }
@@ -2059,7 +2119,8 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
  *	- The service must be unlinked, unlocked and not referenced!
  *	- We are called under _bh lock
  */
-static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
+static void __ip_vs_del_service(struct ip_vs_service *svc,
+				struct list_head *dest_trash, bool cleanup)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
@@ -2093,7 +2154,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(svc->ipvs, dest, cleanup);
+		__ip_vs_del_dest(svc->ipvs, dest, dest_trash, cleanup);
 	}
 
 	/*
@@ -2116,7 +2177,8 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 /*
  * Unlink a service from list and try to delete it if its refcnt reached 0
  */
-static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
+static void ip_vs_unlink_service(struct ip_vs_service *svc,
+				 struct list_head *dest_trash, bool cleanup)
 {
 	ip_vs_unregister_conntrack(svc);
 	/* Hold svc to avoid double release from dest_trash */
@@ -2126,7 +2188,7 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	ip_vs_svc_unhash(svc);
 
-	__ip_vs_del_service(svc, cleanup);
+	__ip_vs_del_service(svc, dest_trash, cleanup);
 }
 
 /*
@@ -2136,12 +2198,14 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
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
@@ -2192,6 +2256,7 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	struct hlist_bl_node *ne;
 	struct hlist_bl_node *e;
 	struct ip_vs_rht *t, *p;
+	LIST_HEAD(dest_trash);
 
 	/* Stop the resizer and drop the tables */
 	if (!test_and_set_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
@@ -2201,8 +2266,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	if (ip_vs_get_num_services(ipvs)) {
 		ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
 			hlist_bl_for_each_entry_safe(svc, e, ne, head, s_list)
-				ip_vs_unlink_service(svc, cleanup);
+				ip_vs_unlink_service(svc, &dest_trash, cleanup);
 		}
+		ip_vs_trash_save_dests(ipvs, &dest_trash, cleanup);
 	}
 
 	/* Unregister the hash table and release it after RCU grace period */
-- 
2.53.0

