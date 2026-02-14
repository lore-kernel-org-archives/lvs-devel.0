Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF8731DA62E;
	Sat, 14 Feb 2026 15:02:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771081374; cv=none; b=B/xZ3x7MGIGU/p357eIFhiXA/Yyv8R9emGLg6pYISstx/8DdeZqjlrYSbd3jNplTtM+SeqYsI9z3BUgwaM0N5kyhfqouooYfJ///gn0z1kiAQijxOjMUyowzOZJ+QFPP8xf2n524HYV16HmyTm/X+zdq+hZHrNbDsi9zF2aoTyI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771081374; c=relaxed/simple;
	bh=bUJ2/NUoi4gA+6dl0HVCjfpN5T6IjvL4MwfSVRanpwY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=p5MbSJnebMajY4m2XzrMrv1sWSFreSz9xOdo0BlJyc2OlrmLobwwfamvn8/G+zwKAMVmMxpPM1L/9R39naTx3NOTT8PWnu8fVGgcn+pXIDunYROFmUwe96mQRGcKmubV11kgQKSCJIGpElAijHTx/SlSfAO0P9OkE+rQ3LdjHOk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bminM2jV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bminM2jV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E20DC21D6A;
	Sat, 14 Feb 2026 17:02:46 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=m28j557dyzS+Eb3mAHQeLNi4x1G/+PYAORs4hd4EMPo=; b=bminM2jVyS3t
	ovnJDBGI7+Uy9lnXrUqrI0KpRi4GvQ4BPnTZm0I2WoaaWe3K9sV14XJLycIzV3hF
	zVb0IQbOZ5Dfce9NvtL27Au9WQiw4+4GocWCOmHQoCzYdMg5exdQtnXbv5xQsqpH
	LTya6cZT8KtE+SEYKvvdazL/cTzIloQG5mUwMzM0DUNaaJy6Va9F6GyMcIhKzzUj
	1qdsP3cZn+uchGJXW/tZ27c0ajyvkm379rwpthW+LzD0ymPbyBMkNRlkl0U8wVaT
	mIdwmNju9RksxV+1hM3GXYsMAmzLxsHWZRmt6vGj4vMxhNdVDv8kaxUhcnZhfXcR
	7Lt777pqhj0d0gDKA2e58xb26f1rrhUapblDsSalO7SluX2ivFEZZWkx3EZ8/Yy0
	K527yZgPxXqQBLt3APn8TMMhTULyyT+idLmwaeeH+dEUy33kX7qq8AeSUxQCJpI1
	0RzRxAP+aMbgwQpxNbfXvV2XmDLM8IP20ZCkndmctD5PMfkNWigxRZk7dLuk+bo/
	ElPULgDHSmlc32E1laqjDZMjisTQE9nQWZ9n5xWoTaAHyio4WWnqy1rzmxmngJli
	QR4pv2d1/oj70u9BgKMCQBh2VLyu/Fz/w1Llb0ArE2UFQll+0CeUXEJaANkcgJLY
	WVpknRfFKfqfLzqfMsnJ0wE36E/KJM8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 17:02:45 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6255C609BE;
	Sat, 14 Feb 2026 17:02:45 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EExQeU018159;
	Sat, 14 Feb 2026 16:59:26 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EExQ8Q018158;
	Sat, 14 Feb 2026 16:59:26 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf 2/2] ipvs: do not keep dest_dst if dev is going down
Date: Sat, 14 Feb 2026 16:58:50 +0200
Message-ID: <20260214145850.18130-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260214145850.18130-1-ja@ssi.bg>
References: <20260214145850.18130-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

There is race between the netdev notifier ip_vs_dst_event()
and the code that caches dst with dev that is going down.
As the FIB can be notified for the closed device after our
handler finishes, it is possible valid route to be returned
and cached resuling in a leaked dev reference until the dest
is not removed.

To prevent new dest_dst to be attached to dest just after the
handler dropped the old one, add a netif_running() check
to make sure the notifier handler is not currently running
for device that is closing.

Fixes: 7a4f0761fce3 ("IPVS: init and cleanup restructuring")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 46 ++++++++++++++++++++++++++-------
 1 file changed, 36 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 64c697212578..124f779424b0 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -294,6 +294,12 @@ static inline bool decrement_ttl(struct netns_ipvs *ipvs,
 	return true;
 }
 
+/* rt has device that is down */
+static bool rt_dev_is_down(const struct net_device *dev)
+{
+	return dev && !netif_running(dev);
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
@@ -309,9 +315,11 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
-		if (likely(dest_dst))
+		if (likely(dest_dst)) {
 			rt = dst_rtable(dest_dst->dst_cache);
-		else {
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.ip;
+		} else {
 			dest_dst = ip_vs_dest_dst_alloc();
 			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
@@ -327,14 +335,22 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
-			__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+			/* It is forbidden to attach dest->dest_dst if
+			 * device is going down.
+			 */
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)))
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
 		noref = 0;
 
@@ -471,9 +487,11 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
-		if (likely(dest_dst))
+		if (likely(dest_dst)) {
 			rt = dst_rt6_info(dest_dst->dst_cache);
-		else {
+			if (ret_saddr)
+				*ret_saddr = dest_dst->dst_saddr.in6;
+		} else {
 			u32 cookie;
 
 			dest_dst = ip_vs_dest_dst_alloc();
@@ -494,14 +512,22 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			}
 			rt = dst_rt6_info(dst);
 			cookie = rt6_get_cookie(rt);
-			__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
+			/* It is forbidden to attach dest->dest_dst if
+			 * device is going down.
+			 */
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)))
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
2.53.0


