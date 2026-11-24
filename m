Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795536171;
	b=NS7mNn1v+dKqKdBaUrlGor+r8nte99uNGdUnF3w0iWshG4zFZ1vNFdpbOehyZAPM+CIa
	 QtTIEc/+///cCNYWIRvMnUPFVuQjURBjZQewUN8yWz13L9jBoy7SkcIH2kCsFjAvYJRcz
	 n7//40dmDo04XZ6kGeuwLaWciCuIy6ptRFfuH12itUhkg5VjVxp66hoRQ2Ye2rIgHDfeM
	 dcX16qpBGkrCYKXso/YB5WG6/NssYKk9NKVQxggU77Vg9mEcMXhNf2E/Gvl+p10OYIF4R
	 s6qzUAZM2phxM5DOwjDrMBSoNtQReAYSV8U/NxihaAY7jwbUMXWUDsT7U2cmpaqv9LA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795536171;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=M4w1nGhtEYxMWkgCexRxW36ga+RiGvSXtRJ5StovU1U=;
	b=K6d65OAUJ7ccDIvLRFk47zpiMEv19N2PJZz6Kj3j6WnU6Gxh2RIJpkJgqn31C4G5n+/H
	 IzT2LwB7RBu0F4bWJW2DXV37Sed2IUcYyWV3e2vShjypSeqW65lgBusGQnTj1lJv+VwS5
	 /wkqsfDf7TdK5uV87hA5tTutuhJp/9o5TNwCIJqlavCzWH89aFD4Wz+cyGGZZObOdtzUS
	 vbqfYBeC9xAzdy6ErXqQO2dpIVHiXPLJtEXaTpwP6F3Lqk3uhzvyJntRl961hOi6pzph0
	 oWIRb3HXKVtQJSUvyk27R7oiL6dfTUoA70pilPGB/wtfM/V2rYLpH6PFjTx5zxrUVXw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Z2YiBDIX;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DEB9606A31E;
	Tue, 24 Nov 2026 16:02:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2DEB9606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Z2YiBDIX
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C3CA421FD1;
	Tue, 24 Nov 2026 18:02:46 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=M4w1nGht
	EYxMWkgCexRxW36ga+RiGvSXtRJ5StovU1U=; b=Z2YiBDIX0w6DolsRr4Z7pPEN
	p4sE+ziPqW61Z+4W+VgUGMQLN+sgoZzCAgxQoA9gYXmqwqsvQlpOiVoKabcJwXQI
	cjSChv7r+Iw0nG5re/gVpKtAUfIzMVeFq4ZNU2UdKdRxWaSImJyc2/fSkQQBAcjq
	AOoevu/QA78PpmEjBB97/YtjWvNArmOl85cmdpFVAW+CSoIGHJdTc9/4OaPd/+RD
	Lh4kJVZuNFr+e/bPsF+MsuJ+G9WvtJtpWTX4UYUY98Q+ZFDKWckflkGGAtz71z4I
	TL/jN8ymW7k91cvHlXYSuXP+Ur/huiXObKoGushpflknC2LxRCk/TcDCmsIqS2eB
	7NPpIgklTYAgdJ6cdy6PgoAlOGmyzJHzj+uKPO2ozudhZkJHsyX/1EOO1wXkvoyK
	6ZbcVrFP5vKOWbIX/CUo+WsWCZsMXEWW9cU2rwRofFkGoHS2DZFbK9NqylffSEY/
	cp2oZBsZT3c/DR+aTgzlT2vT+SOnA8wrE0/wC5MPoi1SNSNbuSbrRfFUvSJXYEzw
	SybPn2TMZYg6GZ1MUiJXlvqYY9Q8nYWB1Q3LNDgbJ1KjpLzF9YsPzTlUIUOO+I3y
	qTXW94Fo7k/Q+TlunzVdXa2WIGiAtiVFPaph9agTi6G+kc4NtI1RGGyZD0Mh5oFr
	omjiOnKe0gqj3ntEG0w=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 24 Nov 2026 18:02:46 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5246162172;
	Tue, 24 Nov 2026 18:02:46 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AOG2i1o103565;
	Tue, 24 Nov 2026 18:02:44 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6AOG2f4a103560;
	Tue, 24 Nov 2026 18:02:41 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>,
        Xing Feng <xingfeng@stu.xjtu.edu.cn>, Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: [PATCH nf] ipvs: fix connection reuse with the resizable hash tables
Date: Tue, 24 Nov 2026 18:02:26 +0200
Message-ID: <20261124160226.103532-1-ja@ssi.bg>
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

Reported-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
Reported-by: Xing Feng <xingfeng@stu.xjtu.edu.cn>
Reported-by: Peng Zhang <p-zhang@xjtu.edu.cn>
Link: https://lore.kernel.org/all/avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local/
Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
Tested-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  1 +
 include/uapi/linux/ip_vs.h      |  7 +++++++
 net/netfilter/ipvs/ip_vs_conn.c | 16 ++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 13 ++-----------
 net/netfilter/ipvs/ip_vs_sync.c |  9 ++++-----
 5 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8dc80d5d42dc..1342c83af7f0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1714,6 +1714,7 @@ struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
+void ip_vs_conn_mark_reused(struct ip_vs_conn *cp, bool old_ct);
 
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
index 83d8a9153a34..667e6f38d381 100644
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
@@ -1468,6 +1470,20 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 		mod_timer_pending(&cp->timer, jiffies);
 }
 
+/* Mark connection as reused:
+ * - it is still hashed
+ * - but it is not hit by packets
+ * - it is replaced by new connection with same addresses and ports
+ * - it is not synced anymore
+ */
+void ip_vs_conn_mark_reused(struct ip_vs_conn *cp, bool old_ct)
+{
+	spin_lock_bh(&cp->lock);
+	if (!old_ct)
+		cp->flags &= ~IP_VS_CONN_F_NFCT;
+	cp->flags |= IP_VS_CONN_F_REUSED;
+	spin_unlock_bh(&cp->lock);
+}
 
 /*
  *	Create a new connection entry and hash it into the conn_tab
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f3eb72e95024..1d0e17565a99 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2209,11 +2209,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		}
 
 		if (resched) {
-			if (!old_ct) {
-				spin_lock_bh(&cp->lock);
-				cp->flags &= ~IP_VS_CONN_F_NFCT;
-				spin_unlock_bh(&cp->lock);
-			}
+			ip_vs_conn_mark_reused(cp, old_ct);
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
@@ -2229,12 +2225,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (sysctl_expire_nodest_conn(ipvs)) {
 			bool old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
 
-			if (!old_ct) {
-				spin_lock_bh(&cp->lock);
-				cp->flags &= ~IP_VS_CONN_F_NFCT;
-				spin_unlock_bh(&cp->lock);
-			}
-
+			ip_vs_conn_mark_reused(cp, old_ct);
 			ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
 			if (old_ct)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7e562e745ab5..f81f630591a9 100644
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
@@ -654,8 +653,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 		ip_vs_sync_conn_v0(ipvs, cp, pkts);
 		return;
 	}
-	/* Do not sync ONE PACKET */
-	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+	if (cp->flags & IP_VS_CONN_F_MASTER_NOSYNC)
 		goto control;
 sloop:
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
@@ -895,6 +893,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		if (cp && ((cp->dport != dport) ||
 			   !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
 			if (!(flags & IP_VS_CONN_F_INACTIVE)) {
+				ip_vs_conn_mark_reused(cp, false);
 				ip_vs_conn_expire_now(cp);
 				__ip_vs_conn_put(cp);
 				cp = NULL;
@@ -1003,7 +1002,7 @@ static bool ip_vs_sync_validate_flags(u32 flags)
 		if (flags & IP_VS_CONN_F_TEMPLATE)
 			return false;
 	}
-	if (flags & IP_VS_CONN_F_ONE_PACKET)
+	if (flags & IP_VS_CONN_F_MASTER_NOSYNC)
 		return false;
 	return true;
 }

Prerequisite-Message-Id: <20261103165746.39516-3-axel.mierczuk@1password.com>
-- 
2.56.1


