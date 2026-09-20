Received: from mail-pj2-f13.google.com (mail-pj2-f13.google.com [74.125.227.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB6B13EC838
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 09:31:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789896713; cv=none; b=L1k6jdTFqOQwNeQRbLrid9NU8xEDgUqoO4ZOK/pB6z8n/JZUwghVy6zn/ccU0RVUIN2/F+SIlkQEI3BEoxpMHv0JWwxevpA4Cj+lYbrQmBfuExgN7zzzhZsgXNUMx08pCP+8n/ftkOZHsXAF9WwoZ8aw+yzY39SMQplNCRWeqSM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789896713; c=relaxed/simple;
	bh=HHMylUUoV2ErCt+GQxiWiYuY3/hIn1WlIHK1Vv/s7aE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=j11EdpGZhepAP1jQf09jNOCCupa4NomatDCa/3KduRepWFbH9/HYWKZIf5K7xKfaM7rNpDR7PDxU3FM4Ux83zAr8csKMtffsngsEpulTW7xVKZo4UJoRXVDCHLbIrVYlXUHNPbenT0erZAhf78Vq/OvKCCAxdZbxQ8EXMjpbE5Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=iokKdjdC; arc=none smtp.client-ip=74.125.227.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="iokKdjdC"
Received: by mail-pj2-f13.google.com with SMTP id d9443c01a7336-2dd88a115ebso16935275ad.2
        for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 02:31:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789896703; x=1790501503; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6xnQtR49M9eGkH01aGrwefUnADH+0zwfkGfqg1+mMB8=;
        b=iokKdjdC0damnqdLIIDZov8xOw6uDdYi1cA8jVB8stIXO9MVGUIj2iOKAPr3GeSFUq
         nkRVPwJduqwGGekprLOexfQvmw99pr22GIxp7vmmioyKPkSZoB+sIPSbhDi0IQK8ZIP4
         20BNSiHy9CRE+0zrS/NinUPcenQDA0rRmEP+L3KJiJyY3wLg3BHpLjowdhCXBznBvvLQ
         T4PW6sXjLOOTeYCFbjDp930O+6ubrYH9sY/d+vCE7O6+IjaL4hQS0BqiLN+eehwoycEZ
         RN6nE53OE5C/y81STZdFJESnjOznqQbGp3LtwVyKkSWN5RFhYycPFr5VF7WuD3bAdTT6
         xp9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789896703; x=1790501503;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6xnQtR49M9eGkH01aGrwefUnADH+0zwfkGfqg1+mMB8=;
        b=HE4+ppQqkEIIKXIbbNeC4dZiIRHG9yVEB8a/uEtBBcWZZFJuJNPGdSS4f7hjW3I/ky
         JHxEuA27G+cmsRxtEKCIi/501WwSOqWolUQmVnTGPx7jsu/XuvoaLw8z2PJeWNidhpXL
         CQ3LMST1A3Rx3ek9MgB6mWZ0+c5kSoD14U5fNBYNk3g0aNrIO8hWb7cU9wt4X/OlC2NU
         LnHCg9kOwNML1Z9nPcL9NtZ2QB8CfczRGkmo8UMncUNB9ctn5LPfc2m9FTgz28DtS8lj
         k/uLLKT4l7ZGBq5evGoTZG6tGczkEJgRImGPJxLXsbQTExgy1tBtkTXCTj4HeVG7f1Xb
         UIXA==
X-Forwarded-Encrypted: i=1; AKwUvBw/sLEKAOOKAV8bkEnKKqCkdfSd04ZCDeAxT7wRigwlKT1HFSmv+VySueYmOSBSNHJHrnMaheNU0pE=@vger.kernel.org
X-Gm-Message-State: AFuF++kkOiNxw6iI9Cx2PAa+/Re8pOD4aVW+ne2JuE+fC2NGJa3TvmtQ
	6DOzandjTTQfQTUredduFVAtUewthTgY2QlXw0xdGzGqvC5J9xJzmMv8cbjyANWaaYlA
X-Gm-Gg: AYBFou2y/SRr9P3hWlOO/JUuqgNN5AHuNg0HmzMcbWl2YuR/BIKu1AH4/K97YI2Lntk
	NciYzeOO5NsJPCHI3UgYSvhYYogedXryBrECh0JIub8F5Dl+ANvTbpTHEo7RQIzH9j+CaNaDQrh
	YGoYA9NDZVSPKKai0/R+W7WBXDB7XKUBMKmrw8UqmWtg51ybBk1hMPJbP7cfZgoiCvIeXvTF1T6
	C14vHy1GLOIoUvb4OS9IWgzmFHeeOeFt1mMw3RBdITfrZ/IyKBaOSaNa6tSNGouxx4i2aPMSE42
	SpMCahMhFYu35dPYmWOxnUwHaFTAbgFgOOM2BBuP84/T+u6EIBlyA6OEMldDbeTkcN8sk08CrhF
	kHOUCUFrfeb+q6D1/piYoUZZHiorTWd28FhmpWQRFoIJ+pOjg4seV52TfmApKKe65taVb0Hdw7r
	EBr/s1jwmhsAYeTxu3yZ8qPlQ31UgYtXXPD+tWudH5UQtxl54B/Ke3EvSiA1KlDGZ/F5G7Uxgd8
	ZPrW/wwnUJsEFbuFnM/loIzaupTnrE=
X-Received: by 2002:a17:903:1446:b0:2da:eb8f:b4e4 with SMTP id d9443c01a7336-2ddb1add397mr121862955ad.7.1789896703153;
        Sun, 20 Sep 2026 02:31:43 -0700 (PDT)
Received: from b6ad5085b32f.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2ddc17e17e0sm18435235ad.70.2026.09.20.02.31.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 20 Sep 2026 02:31:41 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Zihan Xi <zihanx@nebusec.ai>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH nf v3 1/2] ipvs: avoid stack overflow from recursive connection expiration
Date: Sun, 20 Sep 2026 09:31:19 +0000
Message-ID: <650f5ad9c4eea0cf1d31b04b1d12d4a600e90337.1789877273.git.zihanx@nebusec.ai>
In-Reply-To: <cover.1789877273.git.zihanx@nebusec.ai>
References: <cover.1789877273.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a controlled IPVS connection expires, its controller may be expired
synchronously if it has no remaining controlled connections. A chain of
controlled connections can then recurse through ip_vs_conn_expire() and
exhaust the kernel stack during namespace cleanup.

Use an iterative cleanup path so the controller chain is expired with one
stack frame. Keep the reference obtained for the controller until its
expiration step, and drop it while checking the hash table. This prevents a
concurrent lookup from rearming the timer after the connection has lost its
last reference.

Distinguish a connection already unlinked by a concurrent timer callback and
avoid rearming its timer. Run the expiration path under RCU so a callback
cannot outlive an RCU-delayed connection free.

Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Assisted-by: LLM
Co-developed-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Zihan Xi <zihanx@nebusec.ai>
---
changes in v3:
  - Handle a concurrent timer callback while keeping controller cleanup
    iterative and synchronous.
  - Keep expiration under RCU and avoid rearming an already unlinked
    connection.
  - v2 Link:
    https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Replace recursive controller expiration with an iterative repeat path.
  - v1 Link:
    https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

 net/netfilter/ipvs/ip_vs_conn.c | 78 +++++++++++++++++++++++++--------
 1 file changed, 59 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6fa3e1dc534c..d111010469f8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -311,19 +311,30 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 }
 
 /* Try to unlink ip_vs_conn from conn_tab.
- * returns bool success.
+ * returns the unlink state.
  */
-static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
+enum ip_vs_conn_unlink_state {
+	IP_VS_CONN_UNLINK_BUSY,
+	IP_VS_CONN_UNLINKED,
+	IP_VS_CONN_UNLINK_GONE,
+};
+
+static inline enum ip_vs_conn_unlink_state
+ip_vs_conn_unlink(struct ip_vs_conn *cp, bool has_ref)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct hlist_bl_head *head, *head2;
 	u32 hash_key, hash_key2;
 	struct ip_vs_rht *t;
-	bool ret = false;
+	enum ip_vs_conn_unlink_state state;
 	bool use2;
 
-	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		return refcount_dec_if_one(&cp->refcnt);
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET) {
+		if (has_ref)
+			__ip_vs_conn_put(cp);
+		return refcount_dec_if_one(&cp->refcnt) ?
+			IP_VS_CONN_UNLINKED : IP_VS_CONN_UNLINK_BUSY;
+	}
 
 	rcu_read_lock();
 	local_bh_disable();
@@ -337,6 +348,9 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 		      false /* new_hash2 */, &head, &head2);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
+		if (has_ref)
+			__ip_vs_conn_put(cp);
+
 		/* Decrease refcnt and unlink conn only if we are last user */
 		if (use2 == ip_vs_conn_use_hash2(cp) &&
 		    refcount_dec_if_one(&cp->refcnt)) {
@@ -344,8 +358,14 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 			if (use2)
 				hlist_bl_del_rcu(&cp->hn1.node);
 			cp->flags &= ~IP_VS_CONN_F_HASHED;
-			ret = true;
+			state = IP_VS_CONN_UNLINKED;
+		} else {
+			state = IP_VS_CONN_UNLINK_BUSY;
 		}
+	} else {
+		if (has_ref)
+			__ip_vs_conn_put(cp);
+		state = IP_VS_CONN_UNLINK_GONE;
 	}
 
 	conn_tab_unlock(head, head2);
@@ -353,7 +373,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 	local_bh_enable();
 	rcu_read_unlock();
 
-	return ret;
+	return state;
 }
 
 
@@ -1331,24 +1351,29 @@ static void ip_vs_conn_del(struct ip_vs_conn *cp)
 }
 
 /* Try to delete connection while holding reference */
-static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
+static bool ip_vs_conn_del_put(struct ip_vs_conn *cp)
 {
 	if (timer_delete(&cp->timer)) {
 		/* Drop cp->control chain too */
 		if (cp->control)
 			cp->timeout = 0;
-		__ip_vs_conn_put(cp);
-		ip_vs_conn_expire(&cp->timer);
-	} else {
-		__ip_vs_conn_put(cp);
+		return true;
 	}
+
+	__ip_vs_conn_put(cp);
+	return false;
 }
 
 static void ip_vs_conn_expire(struct timer_list *t)
 {
 	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
 	struct netns_ipvs *ipvs = cp->ipvs;
+	enum ip_vs_conn_unlink_state unlink_state;
+	bool has_ref = false;
 
+	rcu_read_lock();
+
+repeat:
 	/*
 	 *	do I control anybody?
 	 */
@@ -1356,24 +1381,27 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		goto expire_later;
 
 	/* Unlink conn if not referenced anymore */
-	if (likely(ip_vs_conn_unlink(cp))) {
+	unlink_state = ip_vs_conn_unlink(cp, has_ref);
+	has_ref = false;
+	if (unlink_state == IP_VS_CONN_UNLINKED) {
 		struct ip_vs_conn *ct = cp->control;
+		bool next = false;
 
 		/* delete the timer if it is activated by other users */
 		timer_delete(&cp->timer);
 
 		/* does anybody control me? */
 		if (ct) {
-			bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
+			bool ct_ref = !cp->timeout && __ip_vs_conn_get(ct);
 
 			ip_vs_control_del(cp);
 			/* Drop CTL or non-assured TPL if not used anymore */
-			if (has_ref && !atomic_read(&ct->n_control) &&
+			if (ct_ref && !atomic_read(&ct->n_control) &&
 			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
 			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
 				IP_VS_DBG(4, "drop controlling connection\n");
-				ip_vs_conn_del_put(ct);
-			} else if (has_ref) {
+				next = ip_vs_conn_del_put(ct);
+			} else if (ct_ref) {
 				__ip_vs_conn_put(ct);
 			}
 		}
@@ -1402,21 +1430,33 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		else
 			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
 		atomic_dec(&ipvs->conn_count);
-		return;
+		if (next) {
+			cp = ct;
+			has_ref = true;
+			goto repeat;
+		}
+		goto out;
 	}
 
+	if (unlink_state == IP_VS_CONN_UNLINK_GONE)
+		goto out;
+
   expire_later:
 	IP_VS_DBG(7, "delayed: conn->refcnt=%d conn->n_control=%d\n",
 		  refcount_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
 
-	refcount_inc(&cp->refcnt);
+	if (!has_ref && !__ip_vs_conn_get(cp))
+		goto out;
 	cp->timeout = 60*HZ;
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
 
 	__ip_vs_conn_put_timer(cp);
+
+out:
+	rcu_read_unlock();
 }
 
 /* Modify timer, so that it expires as soon as possible.
-- 
2.43.0

