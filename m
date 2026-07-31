Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.76.78.106])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A0328429CFA;
	Fri, 31 Jul 2026 14:28:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.76.78.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785508126; cv=none; b=TW1maHV6ViJdCBSdSmjZny/ZcRc2U/qSGX/6kwk3TreLMuy3AzIT+IwP+PO6N4HSsIO1U+ME4Q8w3ugGqdvyvsAsyQu7ommh9xheN+U3pznDZUCtuxbdkPmvhNQzXHrorg4VW79LQk7MpugfenqdZuP0wfwv6vc7xhEy3W3yuig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785508126; c=relaxed/simple;
	bh=a8T1tz6oqIoJV49P5wMByN+R0SUEd93d7bvdQSXFGcA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CPo84ZGGYx4giQnABWj2qdutt+qnQAb0Ec0LDrIsiNbjWvRfr2HGapZIYZHoUGvEbEe3zuUvMD6EYg1gU2+aX3dS3XAeG0Fnf+CudP6nQlW1nl+4lp+mQH/uBisM1YI5+fgR9fLJ2f+dW7tIsPYecP+Bi+2cx8iCau+qcAFc4+Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=c4winM0R; arc=none smtp.client-ip=13.76.78.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="c4winM0R"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:In-Reply-To:References:MIME-Version:
	Content-Transfer-Encoding; bh=zz9/LRUu/hZaHg34Gms7ZVYpk+ULypF6JZ
	5wv4vWnBM=; b=c4winM0RyWKtyvoYxz+a6j/KNd+swSVKSdYxvzD1ILUZtYc5Fj
	VWzwrpikDMNH8zfMlbr5C0Iyt52GIyjT48C+vbrPtPdEgaHS5ImiD0H/IAAl7pKA
	vaqp8Z24JneJM2ofZ9PYzdbmRMva5tzuPY3Hl40Z6ZHKJEBSGo3nb24MU=
Received: from localhost.localdomain (unknown [106.111.19.240])
	by web1 (Coremail) with SMTP id yAQGZQAXuMfosGxqWfTeAA--.54054S3;
	Fri, 31 Jul 2026 22:28:01 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>,
	Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>,
	Ke Xu <xuke@tsinghua.edu.cn>,
	stable@vger.kernel.org,
	Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Subject: [PATCH nf v4 1/3] ipvs: add totalconns for dest
Date: Fri, 31 Jul 2026 22:27:41 +0800
Message-ID: <20260731142748.56545-2-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
In-Reply-To: <20260731142748.56545-1-zhaoyz24@mails.tsinghua.edu.cn>
References: <20260731142748.56545-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:yAQGZQAXuMfosGxqWfTeAA--.54054S3
X-Coremail-Antispam: 1UD129KBjvJXoWfGF4rAw17GFykXF47Xw17trb_yoWDCr1rpF
	s5CF9IgrWUGF45GF4DtF4kZryrG3WkArW7Wry5C3WfX3ZrArs0qanYkFyUAFW7ArsYkFyx
	WFW3t34DCayDJFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9v1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW8JVW5JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2
	z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1lnxkEFVAIw20F6cxK64vIFxWle2I262IYc4
	CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E74AGY7Cv6cx26r4r
	Kr1UJr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc
	8vx2IErcIFxwACI402YVCY1x02628vn2kIc2xKxwCY1x0262kKe7AKxVW8ZVWrXwCY02Av
	z4vE14v_Xryl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Ww4UJr1UMxC20s
	026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_
	JrI_JrWlx4CE17CEb7AF67AKxVW8ZVWrXwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14
	v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xva
	j40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVW8JV
	W8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU1m9aPUUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgIFAWprz6HfEAAAsk

From: Julian Anastasov <ja@ssi.bg>

Replace the inactconns dest counter with totalconns, now
inactconns can be obtained from totalconns - activeconns.
This reduces the atomic inc/dec ops for TCP/SCTP from
6 to 4 if the connection is established and then closed.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
 include/net/ip_vs.h                   | 17 ++++++++++++-----
 net/netfilter/ipvs/ip_vs_conn.c       | 24 +++++++-----------------
 net/netfilter/ipvs/ip_vs_ctl.c        | 10 +++++-----
 net/netfilter/ipvs/ip_vs_lc.c         |  4 ++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 --
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  2 --
 net/netfilter/ipvs/ip_vs_sync.c       |  7 ++-----
 7 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e6ca930a3507..eb796e04eed6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -989,7 +989,7 @@ struct ip_vs_dest {
 
 	/* connection counters and thresholds */
 	atomic_t		activeconns;	/* active connections */
-	atomic_t		inactconns;	/* inactive connections */
+	atomic_t		totalconns;	/* total connections */
 	atomic_t		persistconns;	/* persistent connections */
 	__u32			u_threshold;	/* upper threshold */
 	__u32			l_threshold;	/* lower threshold */
@@ -2229,14 +2229,21 @@ void ip_vs_unregister_hooks(struct netns_ipvs *ipvs, unsigned int af);
 static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
-	/* We think the overhead of processing active connections is 256
+	/* We think the overhead of processing active connections is 257
 	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
+	 * 257 times might not be accurate, we will change it later) We
 	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
+	 *		  dest->activeconns*256 + dest->totalconns
 	 */
 	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
+		atomic_read(&dest->totalconns);
+}
+
+static inline int
+ip_vs_dest_inactconns(const struct ip_vs_dest *dest)
+{
+	return max(atomic_read(&dest->totalconns) -
+		   atomic_read(&dest->activeconns), 0);
 }
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 36c5cba03f5b..4d0a6f718ced 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1081,12 +1081,6 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
 #endif
 
 
-static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
-{
-	return atomic_read(&dest->activeconns)
-		+ atomic_read(&dest->inactconns);
-}
-
 /*
  *	Bind a connection entry with a virtual service destination
  *	Called just after a new connection entry is created.
@@ -1153,8 +1147,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		 */
 		if (!(flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
-		else
-			atomic_inc(&dest->inactconns);
+		atomic_inc(&dest->totalconns);
 	} else {
 		/* It is a persistent connection/template, so increase
 		   the persistent connection counter */
@@ -1162,7 +1155,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	}
 
 	if (dest->u_threshold != 0 &&
-	    ip_vs_dest_totalconns(dest) >= dest->u_threshold)
+	    atomic_read(&dest->totalconns) >= dest->u_threshold)
 		dest->flags |= IP_VS_DEST_F_OVERLOAD;
 }
 
@@ -1244,13 +1237,10 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
-		/* It is a normal connection, so decrease the inactconns
-		   or activeconns counter */
-		if (cp->flags & IP_VS_CONN_F_INACTIVE) {
-			atomic_dec(&dest->inactconns);
-		} else {
+		/* It is a normal connection, so decrease the counters */
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
 			atomic_dec(&dest->activeconns);
-		}
+		atomic_dec(&dest->totalconns);
 	} else {
 		/* It is a persistent connection/template, so decrease
 		   the persistent connection counter */
@@ -1258,10 +1248,10 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	}
 
 	if (dest->l_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) < dest->l_threshold)
+		if (atomic_read(&dest->totalconns) < dest->l_threshold)
 			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
 	} else if (dest->u_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3)
+		if (atomic_read(&dest->totalconns) * 4 < dest->u_threshold * 3)
 			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
 	} else {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bcf40b8c41cf..45f534427d23 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1445,7 +1445,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest->port = udest->port;
 
 	atomic_set(&dest->activeconns, 0);
-	atomic_set(&dest->inactconns, 0);
+	atomic_set(&dest->totalconns, 0);
 	atomic_set(&dest->persistconns, 0);
 	refcount_set(&dest->refcnt, 1);
 
@@ -3031,7 +3031,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
 					   atomic_read(&dest->weight),
 					   atomic_read(&dest->activeconns),
-					   atomic_read(&dest->inactconns));
+					   ip_vs_dest_inactconns(dest));
 			else
 #endif
 				seq_printf(seq,
@@ -3042,7 +3042,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
 					   atomic_read(&dest->weight),
 					   atomic_read(&dest->activeconns),
-					   atomic_read(&dest->inactconns));
+					   ip_vs_dest_inactconns(dest));
 
 		}
 	}
@@ -3670,7 +3670,7 @@ __ip_vs_get_dest_entries(struct netns_ipvs *ipvs, const struct ip_vs_get_dests *
 			entry.u_threshold = dest->u_threshold;
 			entry.l_threshold = dest->l_threshold;
 			entry.activeconns = atomic_read(&dest->activeconns);
-			entry.inactconns = atomic_read(&dest->inactconns);
+			entry.inactconns = ip_vs_dest_inactconns(dest);
 			entry.persistconns = atomic_read(&dest->persistconns);
 			ip_vs_copy_stats(&kstats, &dest->stats);
 			ip_vs_export_stats_user(&entry.stats, &kstats);
@@ -4282,7 +4282,7 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
 			atomic_read(&dest->activeconns)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,
-			atomic_read(&dest->inactconns)) ||
+			ip_vs_dest_inactconns(dest)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
 			atomic_read(&dest->persistconns)) ||
 	    nla_put_u16(skb, IPVS_DEST_ATTR_ADDR_FAMILY, dest->af))
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 38cc38c5d8bb..18b976a7c4d2 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -30,7 +30,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	/*
 	 * Simply select the server with the least number of
-	 *        (activeconns<<5) + inactconns
+	 *        (activeconns*256) + totalconns
 	 * Except whose weight is equal to zero.
 	 * If the weight is equal to zero, it means that the server is
 	 * quiesced, the existing connections to the server still get
@@ -56,7 +56,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 			      IP_VS_DBG_ADDR(least->af, &least->addr),
 			      ntohs(least->port),
 			      atomic_read(&least->activeconns),
-			      atomic_read(&least->inactconns));
+			      ip_vs_dest_inactconns(least));
 
 	return least;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3dbd3096e163..9db1273e5ba4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -446,12 +446,10 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
 				(next_state != IP_VS_SCTP_S_ESTABLISHED)) {
 				atomic_dec(&dest->activeconns);
-				atomic_inc(&dest->inactconns);
 				cp->flags |= IP_VS_CONN_F_INACTIVE;
 			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
 				   (next_state == IP_VS_SCTP_S_ESTABLISHED)) {
 				atomic_inc(&dest->activeconns);
-				atomic_dec(&dest->inactconns);
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
 		}
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 99a286fdc90c..fec0e8b47b71 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -526,12 +526,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
 			    !tcp_state_active(new_state)) {
 				atomic_dec(&dest->activeconns);
-				atomic_inc(&dest->inactconns);
 				cp->flags |= IP_VS_CONN_F_INACTIVE;
 			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
 				   tcp_state_active(new_state)) {
 				atomic_inc(&dest->activeconns);
-				atomic_dec(&dest->inactconns);
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
 		}
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 93038abbf5e0..ea5fdd4f4ce7 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -878,13 +878,10 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		spin_lock_bh(&cp->lock);
 		if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
 		    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
-			if (flags & IP_VS_CONN_F_INACTIVE) {
+			if (flags & IP_VS_CONN_F_INACTIVE)
 				atomic_dec(&dest->activeconns);
-				atomic_inc(&dest->inactconns);
-			} else {
+			else
 				atomic_inc(&dest->activeconns);
-				atomic_dec(&dest->inactconns);
-			}
 		}
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
-- 
2.34.1

