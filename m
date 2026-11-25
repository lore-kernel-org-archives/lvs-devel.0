Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795633828;
	b=KovugPYLAwGeRJNEF3gNVA1I8NLhFxYFCsT3uW2uMIdcTFpkhRh/DvrgpyOm8M2ARaor
	 oi1hY+Wx4jb1i1lHRZ3w2daQlsu72Dm3ZECBQXDvZvpIpoA7YfCaZ/Qm3Z0zkncsXHGL6
	 teSlAqlHUvhbzyucsDKDd3qvzUmhBdVhnufqpdsRR2cTauEOCPL/IH+/O9U73e9a/teIv
	 egKuwbkMXcKQTwKNCaYeHPT9VzwlvWnlcKVDNr9X4KPKsJ0JwjMx29G41uNJweUtXGnFS
	 abK9Ruecdpj7uIYW6tP2Aye2AIkEE2D6rSW5sFznKKhnp173/uPTknYnaBV7/0fNa/g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795633828;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=jpKhVyqnxgdAt4gtB0kYhyxBPlB89OJQQHRpoISVsmQ=;
	b=Rt6ic23Xg8JMHCoAJvfww4o0OMe9MV0bCLL0t9Ly46sf4s0/piGbbWY+diTirEj5g+RN
	 8G+eXGMLFGTFKSYZ90i6C05YawdoMglrtaC0ECDgU6vKF35vhq9f1uW7hMv/I1gZ++G8j
	 EOK1awILYbDTS1T80yRYQxsXQHQ2w6VC0zxx8/HzWMY5ZOgB0+gkcsI5OUJSOwoEO7gDx
	 Bvq4j+nPDrQ+VzZE+nToQN1ITVBmr6yeCU8XvRUI8BQzzirzr1FgmN8Tid2uFx5g0bZoI
	 8Qp2ivGdmgE6B5YciwpMTg8p07aB3Kh6TutfMqs0qGqcQHXtKgdIF9SYYG1++eNMfUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=124mKR+t;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FB7F606A321;
	Wed, 25 Nov 2026 19:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9FB7F606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=124mKR+t
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5D76D21FD0;
	Wed, 25 Nov 2026 21:10:17 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=jpKhVyqn
	xgdAt4gtB0kYhyxBPlB89OJQQHRpoISVsmQ=; b=124mKR+tqmh6kCqk6IWxNnd9
	9tna0oFFiKA2SdgbGXsPvHEL0cneYiXAcU4q9xh8sLZH67TFigZyt8IaGTq0IZ8+
	u+C3hW1YyPoVUr1Fyx1aq9k7eE8ThZjSBwHWEALv6fVZmuqxHelTIS1X28vajWnz
	FFfAI9metLZ/aHnWo7fGmhlV6cjnEEwxRXU4sZRVYUzPmzO8/Qc/4lL/TqdfYHzX
	9CUe4cTWPfcb44CAZe5IhI/6dHLKVfFOBgnfpZSiIgsVPR0PmylRHUa8nEGGHdvp
	+oi7Liq3fpW4rq1hiIqttu0lxuoaRujsG7sYpqvqYzk7mIhtY2YKBobfCaW9c6sU
	sQvNl69AOotgd6RTfiYfKJW3QcUCvEJnU2I/dfVCuUPChEDfDNmUXmJO5IfbsYth
	pZLPRiKP3GcCo06gfounYPh0/FdgyOAM5qEaX3yoRRz8fwddYdmenQf0IJc0P7NW
	sS75XZoBRbezDS6KceGjk9jaVRdkYSgbmFNyTUAiCaiwNxFAhrvo1WBk+ceKBSjy
	ZOYRBHPodGNdo/OBZdiBjhUoEAz8BHZWsktgNZQm7zKlMTONfP0oGriBqPapZsQI
	0aIfrRz7BnepGXhixcW2MuxEfl3Usmtq0F3UNvFf/KDFYVYxUxz/GTVmjud97SMT
	fsKB9bwNMoc7eW4YRkA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 25 Nov 2026 21:10:17 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A25A160EB9;
	Wed, 25 Nov 2026 21:10:16 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6APJA8NV118146;
	Wed, 25 Nov 2026 21:10:08 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6APJA5JD118142;
	Wed, 25 Nov 2026 21:10:05 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>,
        Xing Feng <xingfeng@stu.xjtu.edu.cn>, Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: [PATCH nf v2] ipvs: fix connection reuse with the resizable hash tables
Date: Wed, 25 Nov 2026 21:09:40 +0200
Message-ID: <20261125190940.118112-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.1
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

Zhenrong (Daniel) Gu, Xing Feng and Peng Zhang report for
a problem with the reused connections while testing a passive
runtime checker for L4 load balancers.

When connection is reused, we create new connection and put it
first in the list. By this way all packets hit the new connection
leaving the reused one to expire. This order worked before the
the introduction of resizable connection hash table which
started to reverse the order of connections each time the
table is resized. If the table is resized while the reused
connection is still present, the next packets will not hit the
new connection.

To fix that we prefer not to rely on the order of connections,
now we will just mark the reused connection with a new flag
IP_VS_CONN_F_REUSED, so that it can be skipped when the list
is traversed on received packet. As the reused connection is
still hashed while waiting its timer to expire, it is visible
to the procedures that delete connections on memory pressure
or netns cleanup. Also, when the reused connections are now
marked, we can exclude them from the synchronization process.
Do this by checking for IP_VS_CONN_F_MASTER_NOSYNC for data
and controlling connections.

Reported-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
Closes: https://lore.kernel.org/all/avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local/
Reported-by: Xing Feng <xingfeng@stu.xjtu.edu.cn>
Reported-by: Peng Zhang <p-zhang@xjtu.edu.cn>
Link: https://sashiko.dev/#/patchset/20261124160226.103532-1-ja%40ssi.bg
Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
Tested-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v2:
 * Mark the connection as reused only when we create a replacement
   connection, not while dropping packets when old_ct is present
 * Check for IP_VS_CONN_F_MASTER_NOSYNC for the controlling connections

 Link to v1:
 https://lore.kernel.org/all/20261124160226.103532-1-ja@ssi.bg/

 include/net/ip_vs.h             |  1 +
 include/uapi/linux/ip_vs.h      |  7 +++++++
 net/netfilter/ipvs/ip_vs_conn.c | 15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 15 ++++-----------
 net/netfilter/ipvs/ip_vs_sync.c | 12 ++++++------
 5 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 6ee782f2362c..100638ee3780 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1717,6 +1717,7 @@ struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
+void ip_vs_conn_mark_reused(struct ip_vs_conn *cp);
 
 const char *ip_vs_state_name(const struct ip_vs_conn *cp);
 
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 2c37c6ac7525..b327e07e2c3f 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -112,6 +112,13 @@
 				IP_VS_CONN_F_NFCT | \
 				0)
 
+#define IP_VS_CONN_F_REUSED	(1 << 30)	/* replaced from new one */
+
+/* Connections with any of these flags are not synced */
+#define IP_VS_CONN_F_MASTER_NOSYNC	(IP_VS_CONN_F_ONE_PACKET | \
+					 IP_VS_CONN_F_REUSED | \
+					 0)
+
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_PENAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 98a3c9ec123f..f9f1665daa1f 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -405,6 +405,7 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 						     &cp->vaddr) &&
 				    (!p->cport ^
 				     (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
+				    !(cp->flags & IP_VS_CONN_F_REUSED) &&
 				    p->protocol == cp->protocol) {
 					if (__ip_vs_conn_get(cp)) {
 						/* HIT */
@@ -592,6 +593,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 				    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
 				    (!p->vport ^
 				     (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
+				    !(cp->flags & IP_VS_CONN_F_REUSED) &&
 				    p->protocol == cp->protocol) {
 					if (__ip_vs_conn_get(cp))
 						goto out;
@@ -1468,6 +1470,19 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 		mod_timer_pending(&cp->timer, jiffies);
 }
 
+/* Mark connection as reused:
+ * - it is still hashed
+ * - but it is not hit by packets
+ * - it is replaced by new connection with same addresses and ports
+ * - it is not synced anymore
+ */
+void ip_vs_conn_mark_reused(struct ip_vs_conn *cp)
+{
+	spin_lock_bh(&cp->lock);
+	cp->flags &= ~IP_VS_CONN_F_NFCT;
+	cp->flags |= IP_VS_CONN_F_REUSED;
+	spin_unlock_bh(&cp->lock);
+}
 
 /*
  *	Create a new connection entry and hash it into the conn_tab
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fe3ff0a10ddf..5354ecfe2607 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2215,11 +2215,8 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		}
 
 		if (resched) {
-			if (!old_ct) {
-				spin_lock_bh(&cp->lock);
-				cp->flags &= ~IP_VS_CONN_F_NFCT;
-				spin_unlock_bh(&cp->lock);
-			}
+			if (!old_ct)
+				ip_vs_conn_mark_reused(cp);
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
@@ -2235,12 +2232,8 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (sysctl_expire_nodest_conn(ipvs)) {
 			bool old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
 
-			if (!old_ct) {
-				spin_lock_bh(&cp->lock);
-				cp->flags &= ~IP_VS_CONN_F_NFCT;
-				spin_unlock_bh(&cp->lock);
-			}
-
+			if (!old_ct)
+				ip_vs_conn_mark_reused(cp);
 			ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
 			if (old_ct)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7e562e745ab5..08ac716aad29 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -551,8 +551,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	if (unlikely(cp->af != AF_INET))
 		return;
 	flags = READ_ONCE(cp->flags);
-	/* Do not sync ONE PACKET */
-	if (flags & IP_VS_CONN_F_ONE_PACKET)
+	if (flags & IP_VS_CONN_F_MASTER_NOSYNC)
 		return;
 
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
@@ -654,10 +653,10 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 		ip_vs_sync_conn_v0(ipvs, cp, pkts);
 		return;
 	}
-	/* Do not sync ONE PACKET */
-	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		goto control;
+
 sloop:
+	if (cp->flags & IP_VS_CONN_F_MASTER_NOSYNC)
+		goto control;
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
 		goto control;
 	flags = READ_ONCE(cp->flags);
@@ -895,6 +894,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		if (cp && ((cp->dport != dport) ||
 			   !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
 			if (!(flags & IP_VS_CONN_F_INACTIVE)) {
+				ip_vs_conn_mark_reused(cp);
 				ip_vs_conn_expire_now(cp);
 				__ip_vs_conn_put(cp);
 				cp = NULL;
@@ -1003,7 +1003,7 @@ static bool ip_vs_sync_validate_flags(u32 flags)
 		if (flags & IP_VS_CONN_F_TEMPLATE)
 			return false;
 	}
-	if (flags & IP_VS_CONN_F_ONE_PACKET)
+	if (flags & IP_VS_CONN_F_MASTER_NOSYNC)
 		return false;
 	return true;
 }

Prerequisite-Message-Id: <20261103165746.39516-1-axel.mierczuk@1password.com>
-- 
2.56.1


