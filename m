Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795150520;
	b=vj9BJXptF1ZcZJUzjfUkOJDlDSmcwvU+pfCuPLDN/N1ZSD3YwAxb9XhtUaOnEpdLBZB4
	 LxpILyNhPlCgKzCk42gzI5HCDtEGfTWt6JWuppjXNitjKlIR1WxDfd7Ccky+Ls/QYXO69
	 EYA2oth0jJzq/izmIiKY1ShMpzXwvfpexf1M4rpf72jVjWH/ftauJ9jLEoUlmd5O02j75
	 QQ/5q/IRNfAES4rewtubekc1GrWrtM0F5wCnUy7ueVxy8GrCvgBFnrKz5wDBlEF2ioWME
	 FG/W9iz+eBdQljfvBqS5FJEg4d0IGvxIRpxuz/9GIGg8ctSEh7aotMc+YCYAREbaEkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795150520;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=i4SnMK+pfFxzNIcNnfyzMcnXZmIRWceJf6OnbQhpSf0=;
	b=A6ZDoKcifWLJFi23Bn9A2fnfcNRrt8VqZ4lo9RcteXUykG1p5bWgSK+HglwIQCXAaEpz
	 hpDMv6PCMbwX94a8Ovh5djvESloTJWyRsCX8BdeSPtOR9Gi1iLIz8y7u5S0iNLgWYBBRy
	 V1ljCaonnbaYhgtc3BTCrtHExN5bmHd/pRFR1KrlN3IA04Uic0RFWHJLVrn5kJQIdIulv
	 E3qW3AJqnLIPC71VDZji5ohcXuInthxSsmpY3hWgX107arDQGq7cgVqKh7BoDMUW8XSyy
	 L8LzdewWKZuuOST4kGym7yQ8Xc7tp58c/urGf5W4aVhHodBKx0av+oY5A1n5cHfA4Bg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b="eEUTZtt/";
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ACD0606A335;
	Fri, 20 Nov 2026 04:55:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9ACD0606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=eEUTZtt/
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5C10921FD8;
	Fri, 20 Nov 2026 06:55:16 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=i4SnMK+pfFxzNIcNnfyzMcnXZmIRWceJf6OnbQhpSf0=; b=eEUTZtt/xZE9
	Nozlj36LgcOwy7IDSFeXq/1rYM5Blm+2Rp6i1wSpKSPqiKK7egcH/mnqOU2Xvuic
	NHZpmwAYFTwoP5P1cMgzLh+L6M6Tuzr+B9QZLNqQQ3ZlWrZHBrDTIBF7Doc+kpJL
	cKZV1bKxKqhvKOT7RmctPiuPH5Wznkpff/CwL5Sk3LXXP/1jf2ae9Z241bKZco6b
	gi9IwCyNqtyFCra6Wv24k+MJCTO00lDe/u1CAoM4nIs8WT7PwFOsdBm3BGhBQDKo
	3ydZWCQteeiWmEno0FqQladb0Z6FpTJIPWQkw6kWhpB+pO6t76wRKYVDMNayGoPf
	57zlvlR8zpucanuFW1fAm1DPikT5n2iki2NdheSiR/H/n8FizyuivVuXLyBkqCDw
	rERKUVWQssg/qeH0MKBLgug3FRnVXri+6Teuvx4Ccv6U2um+ptCwrLwOxdm0ACK4
	RN2lHIy204XIK7MoKFS8W8vnbQiKUpJTQMfzbVvSU+XM6vzbnmtbaHW138bMiSqZ
	LiA7ry/6nk3Vl7pO/K10UrEF5/a5uq0ETBxxTWPLY9c2VXYpmnQWrRu13M1rR5TB
	kc52Gx0wSUVFEj6VOPwTdklGDHgcv3rhYUPftFyPk6nl+14zvevjAGqm7u+J61zg
	ASVtOTvXd739STjeR77gp441eJtkDdk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 20 Nov 2026 06:55:16 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C085A60790;
	Fri, 20 Nov 2026 06:55:15 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AK4t7ZM006170;
	Fri, 20 Nov 2026 06:55:10 +0200
Date: Fri, 20 Nov 2026 06:55:07 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        Xing Feng <xingfeng@stu.xjtu.edu.cn>, Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
In-Reply-To: <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local>
Message-ID: <a5aa2a54-d8ea-bbe1-3a72-d672d6fd92c4@ssi.bg>
References: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local> <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg> <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 19 Nov 2026, Zhenrong (Daniel) Gu wrote:

> On Wed, Nov 18, 2026 at 05:26:40PM +0200, Julian Anastasov wrote:
> > 
> > 	We prefer not to unhash such connections because they will
> > go out of our control, eg. we may want to delete them immediately
> > on netns cleanup. May be we should add some check to make them
> > invisible to packets, such as adding new bit in the cp->flags,
> > not depending on the cp->timeout being 0 or not. I can prepare
> > some patch to fix this problem.
> 
> Thanks, a flag that hides the entry from packet lookups makes sense
> to us, and it also keeps ip_vs_conn_put() from re-arming the old
> entry's timer. We would be glad to test the patch: we can run the
> reproducer (force, grow and noresize modes) on 7.3.3 and report back.

	Appending a RFC version for testing. It is for the net
tree because it contains all recent fixes for IPVS.

[PATCH RFC net] ipvs: fix connection reuse with the resizable hash tables

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
-- 
2.56.1


Regards

--
Julian Anastasov <ja@ssi.bg>

