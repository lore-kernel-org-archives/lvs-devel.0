Received: from zg8tmja5ljk3lje4mi4ymjia.icoremail.net (zg8tmja5ljk3lje4mi4ymjia.icoremail.net [209.97.182.222])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 553A03E44E4;
	Mon, 13 Jul 2026 09:49:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.97.182.222
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783936151; cv=none; b=r6CR+8NK2yIO94BInmHPVBSPwjCpS/OFzTRE05ZOVEdQB3/fxhNkI6UIfwQPtcMs4KbaVgxTZZZHTezZuewdM6A9qVJN6JHMSgf0Q8l+cnH97a3m6+WazggBEuxXjr/vOrpiA7tRQ4GEI0xtsQ3z07neUiHHmtUYOM7TCE6+7UA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783936151; c=relaxed/simple;
	bh=3/BP5uD5nRa0nxQHzhS+ZEMFFDOehR5f0M7Qj3EYLUw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=vCjPoYkUywh4Juul5+AsDmxohb8tsaKo+djT1Hv3iZljKfErgoFexgjW+k8j144YQ2g6QAx19VFc8vIDXdYlOUwLgdBBqUaD9d9OcsHYaKS/5wT1d8ja9kZLNhQGMw9FsrCYtOiH0BwHgbkFBwmdSjjSxxU8MeX0xPuKMeq1avE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=MsrA1vj7; arc=none smtp.client-ip=209.97.182.222
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="MsrA1vj7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:In-Reply-To:References:MIME-Version:
	Content-Transfer-Encoding; bh=F+rleY0S+475U+nqz/aNKWhnUEDWwsADbM
	8b2BXmTuU=; b=MsrA1vj7QwlbC1vjeGPAfUOoI8k4LQ3eNxATyW0vfJOK5C3lal
	lx6dgUu1b4bi8Uxx0oShuiSL2JahoF7arAaB4eq6hcQlVqwvTzGZWZmJhGYbr+QJ
	n8OsVzeTNw9h4KDW9krUZ6c1NKYQ97s9+3UG4z/67ahvdJAPvS+1aImy4=
Received: from localhost.localdomain (unknown [121.229.84.192])
	by web5 (Coremail) with SMTP id zAQGZQCXT79htFRqkRUmAw--.5011S3;
	Mon, 13 Jul 2026 17:48:30 +0800 (CST)
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
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>,
	Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>,
	Ke Xu <xuke@tsinghua.edu.cn>
Subject: [PATCH nf v3 1/2] ipvs: properly update the overload flag on dest edit
Date: Mon, 13 Jul 2026 17:48:01 +0800
Message-ID: <82748f09f01858b0d9910f372ed67e9ab539fe35.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
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
X-CM-TRANSID:zAQGZQCXT79htFRqkRUmAw--.5011S3
X-Coremail-Antispam: 1UD129KBjvJXoWxKFyxZrykZr4xCFWrWFyrXrb_yoWxXrykpr
	WxJasF9r4UWr4DWFs8tFnxZrZ5GF18JFW7WF98KasxJ3ZrArn0qFnakFWDGFsrAFs7AFyf
	GFW5t34Yka4DJFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9m1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW7JVWDJwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8Jr0_Cr1UM28EF7xvwVC2z280aVAFwI0_GcCE3s1l
	84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2vYz4IE04k24VAvwVAKI4IrM2AIxVAIcx
	kEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8
	Ww4UJr1UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwACjI8F5VA0II8E6I
	AqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAaw2AFwI0_GFv_Wrylc2xS
	Y4AK67AK6r4fMxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_GrWkJr1UJwCFx2
	IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v2
	6r106r1rMI8E67AF67kF1VAFwI0_GFv_WrylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67
	AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IY
	s7xG6r1j6r1xMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr
	0_Gr1UYxBIdaVFxhVjvjDU0xZFpf9x0JUJ8nOUUUUU=
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAQIHAWpUpbIhPQAAsw

From: Julian Anastasov <ja@ssi.bg>

The upper/lower connection thresholds for dest can be changed,
so use ip_vs_dest_update_overload() to properly update the
dest overload flag.

The thresholds were not limited, fit them in the 0 .. INT_MAX
range as already done in ipvsadm.

As the thresholds are also read when connections are created
and expired, use WRITE_ONCE/READ_ONCE to access them.

As the lower threshold is optional, use (u - (u >> 2)) to
calculate the 75% default value based on the upper threshold
by preserving the integer rounding, as suggested by Yizhou Zhao.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  2 ++
 net/netfilter/ipvs/ip_vs_conn.c | 43 +++++++++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_ctl.c  | 26 ++++++++++++++------
 3 files changed, 50 insertions(+), 21 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 417ff51f62fc..3fc864a320fb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1907,6 +1907,8 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 		kfree(dest);
 }
 
+void ip_vs_dest_update_overload(struct ip_vs_dest *dest);
+
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
  */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6ed2622363f0..fa3fbd597f3f 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -991,6 +991,33 @@ static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
 		+ atomic_read(&dest->inactconns);
 }
 
+/* Update overload flag based on number of dest conns and lower/upper
+ * connection thresholds:
+ * - conns reach u_threshold and exceed it: set the flag
+ * - conns go below l_threshold (or 75% of u_threshold): clear the flag
+ */
+__always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
+{
+	int conns;
+	u32 l, u;
+
+	u = READ_ONCE(dest->u_threshold);
+	if (!u)
+		goto unset;
+	conns = ip_vs_dest_totalconns(dest);
+	if (conns >= u) {
+		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+		return;
+	}
+	/* Low threshold defaults to 75% of upper threshold */
+	l = READ_ONCE(dest->l_threshold) ? : (u - (u >> 2));
+	if (conns >= l)
+		return;
+
+unset:
+	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
+}
+
 /*
  *	Bind a connection entry with a virtual service destination
  *	Called just after a new connection entry is created.
@@ -1053,9 +1080,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		atomic_inc(&dest->persistconns);
 	}
 
-	if (dest->u_threshold != 0 &&
-	    ip_vs_dest_totalconns(dest) >= dest->u_threshold)
-		dest->flags |= IP_VS_DEST_F_OVERLOAD;
+	ip_vs_dest_update_overload(dest);
 }
 
 
@@ -1149,16 +1174,8 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		atomic_dec(&dest->persistconns);
 	}
 
-	if (dest->l_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) < dest->l_threshold)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	} else if (dest->u_threshold != 0) {
-		if (ip_vs_dest_totalconns(dest) * 4 < dest->u_threshold * 3)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	} else {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
-			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	}
+	if (dest->flags & IP_VS_DEST_F_OVERLOAD)
+		ip_vs_dest_update_overload(dest);
 
 	ip_vs_dest_put(dest);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bcf40b8c41cf..62f73d892f97 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1370,10 +1370,12 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	/* set the dest status flags */
 	dest->flags |= IP_VS_DEST_F_AVAILABLE;
 
-	if (udest->u_threshold == 0 || udest->u_threshold > dest->u_threshold)
-		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
-	dest->u_threshold = udest->u_threshold;
-	dest->l_threshold = udest->l_threshold;
+	if (READ_ONCE(dest->u_threshold) != udest->u_threshold ||
+	    READ_ONCE(dest->l_threshold) != udest->l_threshold) {
+		WRITE_ONCE(dest->u_threshold, udest->u_threshold);
+		WRITE_ONCE(dest->l_threshold, udest->l_threshold);
+		ip_vs_dest_update_overload(dest);
+	}
 
 	dest->af = udest->af;
 
@@ -1486,6 +1488,9 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ERANGE;
 	}
 
+	if (udest->u_threshold > INT_MAX)
+		return -EINVAL;
+
 	if (udest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
 		if (udest->tun_port == 0) {
 			pr_err("%s(): tunnel port is zero\n", __func__);
@@ -1559,6 +1564,9 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ERANGE;
 	}
 
+	if (udest->u_threshold > INT_MAX)
+		return -EINVAL;
+
 	if (udest->tun_type == IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
 		if (udest->tun_port == 0) {
 			pr_err("%s(): tunnel port is zero\n", __func__);
@@ -3667,8 +3675,8 @@ __ip_vs_get_dest_entries(struct netns_ipvs *ipvs, const struct ip_vs_get_dests *
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
 			entry.weight = atomic_read(&dest->weight);
-			entry.u_threshold = dest->u_threshold;
-			entry.l_threshold = dest->l_threshold;
+			entry.u_threshold = READ_ONCE(dest->u_threshold);
+			entry.l_threshold = READ_ONCE(dest->l_threshold);
 			entry.activeconns = atomic_read(&dest->activeconns);
 			entry.inactconns = atomic_read(&dest->inactconns);
 			entry.persistconns = atomic_read(&dest->persistconns);
@@ -4277,8 +4285,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 			 dest->tun_port) ||
 	    nla_put_u16(skb, IPVS_DEST_ATTR_TUN_FLAGS,
 			dest->tun_flags) ||
-	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
-	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH,
+			READ_ONCE(dest->u_threshold)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH,
+			READ_ONCE(dest->l_threshold)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
 			atomic_read(&dest->activeconns)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,
-- 
2.34.1

