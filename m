Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795583107;
	b=T1Y0YSF+CcouEdQP2aNSTiJxLzt3Cqs5Pb/BG7TLToz86B/mtw8nuPIPGKhtCscBpiZ6
	 5gQlEoa4jVJrKSlABGk3LRt5OEJT12XyN0uytawC4ZH3i5uUm8/w8vge+LIoVhswWaIsX
	 XNUG2bTfWfmlpN4ksu7ji9Sh7V20eZoV6DGOn5XYhDeR0SweehBP3LRid8+OMOnyhMynJ
	 xHJFQ0bUbFqYxr//HfPw00N9G8KdTtXo450PeE6r3ts8RA7O8dVCCcbgXHURUog7hpzQG
	 wemWGfimSBeyvPjFk3DqUUgifZa+Jgg6ffbKt+LAxMdO9/NSkMzeWqZtnZ9yY5ZikKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795583107;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=nHf+uAV5AF2pizhCOYyzn1HDmepelEyIFEUn+tPSLbw=;
	b=OI3vr6EMoNfAbJ34eAg5IoWIi0OVhNEbasJLBGbhMuGTQYT/RXWVm7krED8lfl3ge3JW
	 xDst2ZWOflQYPwDC8vMY4fuCo+5jKmNCN8saUSPXdvEHF4/f8cyQG6lj7Ta1Um5tcaGus
	 n5m/PH4yvpEANl31cWWdOjaJg6cngj7vlJXoYFMmrWEKty6vJst4JhwKaxsoe9mcYarz9
	 iptifopFTfiWkbYrKlX8nNGfmCrj7PWh/24GgSWPcxhyvJBsifH3niCOsFcNZIJWYZ1Os
	 vmd+HyJGz7awGKWwR93yabHKwG1ID5mQeg93t8NP5a0J+/n3BJhj39GpEZNMbN1zrjA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=LdLookln;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E819F606A321;
	Wed, 25 Nov 2026 05:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E819F606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=LdLookln
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 391BA21FD3;
	Wed, 25 Nov 2026 07:05:03 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=nHf+uAV5AF2pizhCOYyzn1HDmepelEyIFEUn+tPSLbw=; b=LdLooklnqWej
	EYgkxPaTxUgdmjCNEzC2ybO7UWx/ySxaolgglX4wwqd5ixGY/fgtWOdW2ZGAtZyM
	pyPLsKWFhqMo2+QBOBn01ZB8MzSGF8WIg6IHbpyuWwFxhlB60nZ3FdIXZLsPN3G2
	RS+qPgsLUHY1boMHPYc4ruHLlIroXBEoSIDCKQ8OL2RHnxbpmb74DgS2nD6b3aIf
	C0Nbspun1Uen9yOkdZFw8ybdS1QupvaDYWUOy+3Lx9ezYti56xU2cYS2qQOrEMT/
	M6N+Z5ecOXpj43arAdrxnXYyq9+pMjqjsEZ5hjOUnvOYmsCDE/8oQOGPjOVFsVp/
	4OUd6D+aT9wvWtOUfz73Mhn+L+uoPuKyVOWZ7qisphPCJCCS42Y5gOTDLnUnN2fo
	ihOpUIWIWRZihF5/l8Vv0dndCjvcli4UKWIZ5pSLs//O5iadtdXnY1CvbCoLt2jj
	LWtzGqZXQDu5EK9Qx8xpE4khM07eAYQj1lDINe2tEaYgz3fI6/7Oe4pxIuUhh/Ag
	P+y2o9bHmAg4dKza0VmR5Y98hiKUnoO9w7kwCIqb90ujCmvNM5bcrFVpPQA9ONIA
	Wirq0W3nUNOrWMnBdn53SyxhosRvur8XrZxQXt1YFrfrmRUhYqhClz1NMTNINYH3
	JS56SdmSFwoYyDsGk970IUc+mqSnYRU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 25 Nov 2026 07:05:03 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A70B960049;
	Wed, 25 Nov 2026 07:05:02 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AP54vg8007743;
	Wed, 25 Nov 2026 07:04:59 +0200
Date: Wed, 25 Nov 2026 07:04:57 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        Xing Feng <xingfeng@stu.xjtu.edu.cn>, Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [BUG] ipvs: new connection on a reused port goes to the previous
 real server during conn_tab resize
In-Reply-To: <awWHfO0EgdLoOxLi@fxxowodeMacBook-Pro.local>
Message-ID: <4da25158-cbab-1186-b948-e17b13262bc3@ssi.bg>
References: <avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local> <d876f5ef-982a-0ddb-5e75-3434453c2ccf@ssi.bg> <av7f6F123V2WDd_u@fxxowodeMacBook-Pro.local> <a5aa2a54-d8ea-bbe1-3a72-d672d6fd92c4@ssi.bg> <awWHfO0EgdLoOxLi@fxxowodeMacBook-Pro.local>
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

On Tue, 24 Nov 2026, Zhenrong (Daniel) Gu wrote:

> Hello Julian,
> 
> On Fri, Nov 20, 2026 at 06:55:07AM +0200, Julian Anastasov wrote:
> > 	Appending a RFC version for testing. It is for the net
> > tree because it contains all recent fixes for IPVS.
> > 
> > [PATCH RFC net] ipvs: fix connection reuse with the resizable hash tables
> 
> 
> Thanks for the patch. We tested it on the net tree (af6737b90,
> 7.4.0-rc3) in a KVM guest with 8 vCPUs, using the reproducer from the
> report:
> 
>   mode      kernel    reused-port   misrouted     answered     failed
>                       connections   connections   > 100 ms
>   force     net         13289          413          333        35 reset
>   force     net+RFC     15634            0            0             0
>   grow      net         15584            7            5         1 reset
>   grow      net+RFC     15678            0            0             0
>   noresize  net          7841            0            0             0
>   noresize  net+RFC      7834            0            0             0
> 
> (force: 60 s, conn_lfactor written every 100 ms; grow: 60 s, all
> defaults; noresize: 30 s, conn_lfactor=8.)
> 
> With the patch no packet of a reused-port connection went to another
> real server than its SYN, and the client saw no delayed or failed
> exchanges.
> 
> To check for regressions we also ran, on both kernels:
> 
> - tools/testing/selftests/net/netfilter/ipvs.sh: PASS on both.
> - Rolling updates with drained and deleted real servers, and reused
>   ports with conn_reuse_mode=0, in a NAT setup with kube-proxy's
>   sysctls: same results on both kernels.
> - Master/backup sync with reused-port traffic and forced resizes: the
>   backup's entries for the reused ports matched the master's on 20 of
>   20 ports with the patch, 22 of 30 without.
> - Persistent service (-p 60) with reused ports and forced resizes:
>   every connection reached the same real server, on both kernels.
> 
> We did not construct the case of a late packet from the old real
> server (e.g. a retransmitted FIN) after its connection was marked
> reused.
> 
> Tested-by: Zhenrong (Daniel) Gu <zrgu@stu.xjtu.edu.cn>

	Thank you for the testing! Due to the Sashiko concerns [1]
I'll post new version later today:

[1]
https://sashiko.dev/#/patchset/20261124160226.103532-1-ja%40ssi.bg

	Here is the v2 that I'll post, in case you want to do
the main test again. The difference is that we do not mark
the connection as reused early because a retransmitted SYN
should hit the old connection while it is using confirmed
conntrack and is not expired yet (2nd SYN comes before the
expiration):

[PATCH RFC nf v2] ipvs: fix connection reuse with the resizable hash tables

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
Link: https://sashiko.dev/#/patchset/20261124160226.103532-1-ja%40ssi.bg
Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
Tested-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v2:
 * Mark the connection as reused only when we create a replacement
   connection, not while dropping packets when old_ct is present.
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

Regards

--
Julian Anastasov <ja@ssi.bg>

