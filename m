Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [52.237.72.81])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id B34C73E3167;
	Mon, 13 Jul 2026 09:49:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=52.237.72.81
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783936164; cv=none; b=oLHLpctHHCNyhIKeFw5dvUYQx350J19t4nSE89sevA8BC0Tay8eZdkNNtWzX2WETkwWK/GyEgLKJ8V2T6XOrXNOQsjZ/280zNY5AlGE4x4GMJjfMOByohqJBc1QeVLbdj+KPmwn95E+5rG+BUynExKERfdCppdMTn8SmOEJ4YEc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783936164; c=relaxed/simple;
	bh=dyofjdjySQUiBLq2MV6SAFacfOSDOw7gZ1Kn3cktthI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Oo9AzFR3zgtQMa5cwSK78T7BeIlpDxHYS3Q1/OmTF9iIlI56wuwxUE5IBJDH+LWlp6p83AVHNXiRMrzpwwZ+j7zp4cZ6odYS7V0bO98+nGQDK9GY9xDtTigm3y9j3uZDFP9So8FxGzgzUCUglsBs90ejk+cM4izShnodK4NZHSw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=OoB6Vw87; arc=none smtp.client-ip=52.237.72.81
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="OoB6Vw87"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:In-Reply-To:References:MIME-Version:
	Content-Transfer-Encoding; bh=ieNt4KYer9ZaDB5sbELoJIy8l78lrHNfSf
	D3geeGEHo=; b=OoB6Vw875sXgFo135FhYyTkzXpPs5vr+uayuSmkT21l9kiqsOG
	IXVgmDwuN/PsCFPo/kaH3JYc5Vw4e6zUQ+71+cwyociR2vgTFS2Wce9YW3aFZcwF
	CfOJnwgFSlskY4k0cRlYHQcacTeBFP1XBdie6Q2aCWkokYDdWWle2dRM4=
Received: from localhost.localdomain (unknown [121.229.84.192])
	by web5 (Coremail) with SMTP id zAQGZQCXT79htFRqkRUmAw--.5011S4;
	Mon, 13 Jul 2026 17:48:45 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>
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
Subject: [PATCH nf v3 2/2] ipvs: use bitops for destination overload state
Date: Mon, 13 Jul 2026 17:48:02 +0800
Message-ID: <edc095e05c89cc6481613126de5f2a91ed601fa9.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
In-Reply-To: <cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
References: <cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:zAQGZQCXT79htFRqkRUmAw--.5011S4
X-Coremail-Antispam: 1UD129KBjvAXoW3tF47JFWktr15tF1rJw1fWFg_yoW8Wry5Ko
	W3Z3ZxZw4rArW7tw4ktw43uF4rWr4Igr48CFW7XFsxur9rtr18X39rWa15tanrtFyIga13
	Z34xXwn8AFsY9r1rn29KB7ZKAUJUUUU8529EdanIXcx71UUUUU7v73VFW2AGmfu7bjvjm3
	AaLaJ3UjIYCTnIWjp_UUUYH7CY07I20VC2zVCF04k26cxKx2IYs7xG6rWj6s0DM28lY4IE
	w2IIxxk0rwA2F7IY1VAKz4vEj48ve4kI8wA2z4x0Y4vE2Ix0cI8IcVAFwI0_Ar0_tr1l84
	ACjcxK6xIIjxv20xvEc7CjxVAFwI0_Gr1j6F4UJwA2z4x0Y4vEx4A2jsIE14v26rxl6s0D
	M28EF7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAac4AC62xK8xCEY4vEwIxC4wAS0I0E0x
	vYzxvE52x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VCjz48v1sIEY20_
	GrWkJr1UJwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IYc2Ij64vIr41lF7I21c0EjII2zV
	CS5cI20VAGYxC7M4IIrI8v6xkF7I0E8cxan2IY04v7MxkF7I0En4kS14v26r4a6rW5MxkI
	ecxEwVAFwVW8uwCF04k20xvY0x0EwIxGrwCF04k20xvE74AGY7Cv6cx26r4rKr1UJr1l4I
	8I3I0E4IkC6x0Yz7v_Jr0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AK
	xVWUGVWUWwC2zVAF1VAY17CE14v26r4a6rW5MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcV
	AFwI0_Jr0_JF4lIxAIcVC0I7IYx2IY6xkF7I0E14v26F4j6r4UJwCI42IY6xAIw20EY4v2
	0xvaj40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxV
	W8JVW8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU1U73PUUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgMHAWpUphggYgAAsF

IPVS destination schedulers read the overload state from packet processing
paths, while connection accounting and destination updates can change it
concurrently. IP_VS_DEST_F_OVERLOAD currently shares dest->flags with
IP_VS_DEST_F_AVAILABLE, so plain read-modify-write operations on the two
independent states can race and lose either update.

KCSAN reports the race with the SH scheduler and an upper connection
threshold configured:

  BUG: KCSAN: data-race in __ip_vs_update_dest / ip_vs_sh_schedule

IP_VS_DEST_F_AVAILABLE is changed under service_mutex. Keep it in the
existing flags word, but move the overload state to a separate unsigned
long and access it with bitops. Use test_bit() in scheduler paths and
set_bit()/clear_bit() in ip_vs_dest_update_overload(). This serializes the
overload bit accesses and prevents updates to the available and overload
states from clobbering each other.

The destination flags are not exposed by the IPVS sockopt or netlink
interfaces, so move their definitions out of the UAPI header. Place the
new overload word next to weight, which keeps the existing flags,
conn_flags and weight offsets unchanged. On x86-64 this grows struct
ip_vs_dest from 472 to 480 bytes.

test_bit() does not add reader-side ordering. Schedulers can still observe
stale destination state, as they could before this change; this does not
provide a fresh cross-field snapshot.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Assisted-by: Claude-Code:GLM-5.2
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
 include/net/ip_vs.h              | 8 ++++++++
 include/uapi/linux/ip_vs.h       | 6 ------
 net/netfilter/ipvs/ip_vs_conn.c  | 7 ++++---
 net/netfilter/ipvs/ip_vs_dh.c    | 4 ++--
 net/netfilter/ipvs/ip_vs_fo.c    | 2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
 net/netfilter/ipvs/ip_vs_lc.c    | 2 +-
 net/netfilter/ipvs/ip_vs_mh.c    | 2 +-
 net/netfilter/ipvs/ip_vs_nq.c    | 2 +-
 net/netfilter/ipvs/ip_vs_ovf.c   | 2 +-
 net/netfilter/ipvs/ip_vs_rr.c    | 2 +-
 net/netfilter/ipvs/ip_vs_sed.c   | 4 ++--
 net/netfilter/ipvs/ip_vs_sh.c    | 2 +-
 net/netfilter/ipvs/ip_vs_twos.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_wlc.c   | 4 ++--
 net/netfilter/ipvs/ip_vs_wrr.c   | 2 +-
 17 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3fc864a320fb..5e8e55f82b04 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -36,6 +36,13 @@
 #define IP_VS_HDR_INVERSE	1
 #define IP_VS_HDR_ICMP		2
 
+/* Destination Server Flags */
+#define IP_VS_DEST_F_AVAILABLE	0x0001		/* server is available */
+
+enum {
+	IP_VS_DEST_FL_OVERLOAD,
+};
+
 /* conn_tab limits (as per Kconfig) */
 #define IP_VS_CONN_TAB_MIN_BITS	8
 #if BITS_PER_LONG > 32
@@ -976,6 +983,7 @@ struct ip_vs_dest {
 	volatile unsigned int	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
+	unsigned long		flags2;		/* dest status flags */
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
index fa3fbd597f3f..2591f4e143f8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1006,7 +1006,7 @@ __always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
 		goto unset;
 	conns = ip_vs_dest_totalconns(dest);
 	if (conns >= u) {
-		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+		set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
 		return;
 	}
 	/* Low threshold defaults to 75% of upper threshold */
@@ -1015,7 +1015,8 @@ __always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
 		return;
 
 unset:
-	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+	if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
+		clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
 }
 
 /*
@@ -1174,7 +1175,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		atomic_dec(&dest->persistconns);
 	}
 
-	if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+	if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 		ip_vs_dest_update_overload(dest);
 
 	ip_vs_dest_put(dest);
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index e1f62f6b25e2..364acb6342e2 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -196,12 +196,12 @@ static int ip_vs_dh_dest_changed(struct ip_vs_service *svc,
 
 
 /*
- *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
+ *      If the dest flags is set with IP_VS_DEST_FL_OVERLOAD,
  *      consider that the server is overloaded here.
  */
 static inline int is_overloaded(struct ip_vs_dest *dest)
 {
-	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+	return test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_fo.c b/net/netfilter/ipvs/ip_vs_fo.c
index d657b47c6511..a59af6c1189a 100644
--- a/net/netfilter/ipvs/ip_vs_fo.c
+++ b/net/netfilter/ipvs/ip_vs_fo.c
@@ -29,7 +29,7 @@ ip_vs_fo_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 * Find virtual server with highest weight and send it traffic
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) &&
 		    atomic_read(&dest->weight) > hw) {
 			hweight = dest;
 			hw = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 15ccb2b2fa1f..ee26be3eb860 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -414,7 +414,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 		if (atomic_read(&dest->weight) > 0) {
 			least = dest;
@@ -429,7 +429,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c90ea897c3f7..28858e44225a 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -166,7 +166,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry_rcu(e, &set->list, list) {
 		least = e->dest;
-		if (least->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &least->flags2))
 			continue;
 
 		if ((atomic_read(&least->weight) > 0)
@@ -181,7 +181,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
   nextstage:
 	list_for_each_entry_continue_rcu(e, &set->list, list) {
 		dest = e->dest;
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
@@ -577,7 +577,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 * new connection.
 	 */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 
 		if (atomic_read(&dest->weight) > 0) {
@@ -593,7 +593,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 38cc38c5d8bb..c4e4e91e3e6d 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -38,7 +38,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 020863047562..23ffc51ca088 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -80,7 +80,7 @@ static inline void generate_hash_secret(hsiphash_key_t *hash1,
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
 }
 
 /* Returns hash value for IPVS MH entry */
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index ada158c610ce..d6fbb9e50e4b 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -72,7 +72,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD ||
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) ||
 		    !atomic_read(&dest->weight))
 			continue;
 
diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
index c5c67df80a0b..104de8c24a4f 100644
--- a/net/netfilter/ipvs/ip_vs_ovf.c
+++ b/net/netfilter/ipvs/ip_vs_ovf.c
@@ -33,7 +33,7 @@ ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	*/
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		w = atomic_read(&dest->weight);
-		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) ||
 		    atomic_read(&dest->activeconns) > w ||
 		    w == 0)
 			continue;
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 4125ee561cdc..c38bee987d14 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -66,7 +66,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) &&
 			    atomic_read(&dest->weight) > 0)
 				/* HIT */
 				goto out;
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 245a323c84cd..0ce425f9748a 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -75,7 +75,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_sed_dest_overhead(least);
@@ -90,7 +90,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index cd67066e3b26..bbdb683b8e86 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -73,7 +73,7 @@ struct ip_vs_sh_state {
 static inline bool is_unavailable(struct ip_vs_dest *dest)
 {
 	return atomic_read(&dest->weight) <= 0 ||
-	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+	       test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);
 }
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_twos.c b/net/netfilter/ipvs/ip_vs_twos.c
index dbb7f5fd4688..ce5618f02e7d 100644
--- a/net/netfilter/ipvs/ip_vs_twos.c
+++ b/net/netfilter/ipvs/ip_vs_twos.c
@@ -52,7 +52,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Generate a random weight between [0,sum of all weights) */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD)) {
+		if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)) {
 			weight = atomic_read(&dest->weight);
 			if (weight > 0) {
 				total_weight += weight;
@@ -75,7 +75,7 @@ static struct ip_vs_dest *ip_vs_twos_schedule(struct ip_vs_service *svc,
 
 	/* Pick two weighted servers */
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 
 		weight = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 9da445ca09a1..62a4c8149192 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -47,7 +47,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
 
 	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+		if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
 			loh = ip_vs_dest_conn_overhead(least);
@@ -62,7 +62,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	 */
   nextstage:
 	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
 		if ((__s64)loh * atomic_read(&dest->weight) >
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 2dcff1040da5..b99cbc1d1302 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -176,7 +176,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		list_for_each_entry_continue_rcu(dest,
 						 &svc->destinations,
 						 n_list) {
-			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
+			if (!test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2) &&
 			    atomic_read(&dest->weight) >= mark->cw)
 				goto found;
 			if (dest == stop)
-- 
2.34.1

