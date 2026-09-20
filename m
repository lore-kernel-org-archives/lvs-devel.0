Received: from mail-ua2-f43.google.com (mail-ua2-f43.google.com [74.125.226.235])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F2EA3D953D
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 05:47:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.226.235
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789883242; cv=none; b=SGxjAJXWF7ekjZjkwH5XPleHoXd6ZDFTRkqhQHMckKhr5Y5XfBs+8gkqxOMc4BmcL8XuhHj0xfvl0yUwU23gIrMBS6RMHxtZKUGB5yx1USq4k586Hp0Gadeo38sM9hXejj+R4c3SiADz6q6ji3cOfbz+QA5eEYl2qgd9n8U63PU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789883242; c=relaxed/simple;
	bh=XwLRDqoGDPXb6K5PWgL1M7DdV69+VMAJJyWkcb0+NUo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ApPJIjHYiFTiZEwUWWITKDOb7xAfxBH2odtEtQujxVvhiBnGYPem2t0k8qYka+cp7ENd4OtHfFRFjYYCjOh2rqxoWa5/5ftyeOSyq0F41XdONhaQBFExw4Bp4C5pZFCsO4yqfT1yyra0XOCT+RiV4oF6BeaOmj2lR0dyQn/H6E8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=O8amkPY2; arc=none smtp.client-ip=74.125.226.235
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O8amkPY2"
Received: by mail-ua2-f43.google.com with SMTP id a1e0cc1a2514c-97eaa1155b1so1031221241.3
        for <lvs-devel@vger.kernel.org>; Sat, 19 Sep 2026 22:47:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789883239; x=1790488039; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=83+plyF4HOp6Tc6yDaOIUjOh/yxbiFagCuYc/tYX0qs=;
        b=O8amkPY2Esj2W5BnE6vPGOjoGsQWoAqT5FK7u/mJvfO+xn7KdJfg7QTD14/1F/VxVZ
         5AhQVDPtOS6Z1DYVxgMEmfUtQ2T9A2zOgx6i/qq8Jpn7YTj+Wx0O+TSZI34yyKmO5eSq
         Ua8/4r7XVIrLOSIJDa3v/8loPoeQ2tUkwpvSZQHgn/k2ALLvBQT3SY48ioD5rx3yOqVx
         TvHIB2YLLuV8vPNFnb3F71jECq4R+n6ht2kyalDfHZwQZdWjrWKMCaa1PDjeXu6VbJob
         waVy0azEEBPHBwDbZi5oValmfbh6oFCS7FvqPOre0d8UvTcT9AHA3zvbDN2lhj2FdBcK
         LBKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789883239; x=1790488039;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=83+plyF4HOp6Tc6yDaOIUjOh/yxbiFagCuYc/tYX0qs=;
        b=zoayACHDHektG3MD8qniTgpNj1rp8wQXFNEcBSdzXa1rSh2fOczqtLiglMy2oL12xS
         pZo59t2mwPwlC8Ws2zcCm9NaVaV8OirLN06bIoNaNA4ku1kETfdppDH6veBM94zVJPlO
         9wpPvqWOC4ijAk9LPkQlHAYzXOA5bed0JDy56rm+wxpog2ZiGL1EfL69X3HOJgkmEfPC
         JI392dBpO1o4PITxAir0GozzeQgcWF7UZcbb8ILhF2tOmPWMShUEtiMIvFc1GyyfBiBo
         fhfN6bqaItJ4R2tMSueDiV60QUsVwRItWZZWyZgwBmk+dgoTv7aWgrW8r4X+6WFR6OeG
         kcmw==
X-Forwarded-Encrypted: i=1; AKwUvBwwQtF4Gx0QA5L1P3FidnnpBrgxS3IZMOp0SchlMH7t7h5vz2S8LBpG9RzKJgOJ2flXMRSBZvVR4pA=@vger.kernel.org
X-Gm-Message-State: AFuF++mAdKSVtwHRwtjp1CcGtMPR/bgG1UFgzHaxEiBSGmNM+mGUfo+K
	WINul+mfNTKP49Ih1hqztG0z0kjW/gwnwAPvDwrVeMA5C9Imz7M1Bc0l
X-Gm-Gg: AYBFou0l5ERp4NfCN+cnASWkndg99HqKpdQiQcn2mQCdKGs2yMNkNe+KTfg9saeXXX2
	zqDQATPpFTpB67B8/pjc//Y9qOOAZSertgIvRdiWvgjdrWVNSeJ/e3YTsN4flyMLN/p+rFFJN8e
	SIhIZzqPF2qXOaQdzXMxlzHmVF/H6yaO2QtPks0EmeWUxeWKP3eTIc7UBpImGHRD/+GoyRx2+91
	Qn1rZod/3boDaVOPWO6+XO9JtLLvWkJgmFh+Ar953imBQjxfxwHo/0/l/L6zNgQXg+HlUv4QdXA
	WfDze9fccDdki4zW0sRwGhz5bCw1L+3UgDgNb6c2aw6N7qCuWGUZIraKEd40IcJ/EdKA23UqsZH
	UgEER4AX+1UaqK/ObMcWekl3upDhi/KXd/6OaL8V5WnuSwkjHIjBEwlxWb4Ng3cOrKljuD40J4/
	CkPavAQ3ops9NTQcYpeA1h0lP9wi4hlciDo4qkffvsz895DlUiERBlCslF9pXPsUI=
X-Received: by 2002:a05:6102:e0e:b0:7a7:b6a:b022 with SMTP id ada2fe7eead31-7a70b6ab56dmr924527137.22.1789883239412;
        Sat, 19 Sep 2026 22:47:19 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-7a6aa41dac0sm4521732137.2.2026.09.19.22.47.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 19 Sep 2026 22:47:19 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 nf-next 1/3] ipvs: add flags for per-service secure TCP state table
Date: Sun, 20 Sep 2026 02:47:06 -0300
Message-ID: <20260920054708.988867-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260920054708.988867-1-adrianox@gmail.com>
References: <20260920054708.988867-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add IP_VS_SVC_F_SECURE_TCP to mark a virtual service for the
DoS-hardened TCP connection state table, and
IP_VS_CONN_F_SECURE_TCP to carry that capability on a connection
so the TCP state machine can select the hardened table for it.

The service flag is 0x0100: bits 0x0008/0x0010/0x0020 are the
scheduler bits, so leave 0x0040/0x0080 free for schedulers.

Set IP_VS_CONN_F_SECURE_TCP on every connection bound to a
destination whose service carries IP_VS_SVC_F_SECURE_TCP.

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
Changes in v2:
- Let IP_VS_SVC_F_SECURE_TCP be 0x0100, leaving 0x0040/0x0080 free for
  scheduler flags.
- Let IP_VS_CONN_F_SECURE_TCP be (1 << 17) and drop it from
  IP_VS_CONN_F_BACKUP_MASK.
- Set the flag in ip_vs_bind_dest() instead of at every ip_vs_conn_new()
  call site.

Changes in v3:
- Merge the uapi flag definition and the ip_vs_bind_dest() stamping into
  a single patch.

(no changes since v3)

 include/uapi/linux/ip_vs.h      | 2 ++
 net/netfilter/ipvs/ip_vs_conn.c | 4 ++++
 net/netfilter/ipvs/ip_vs_core.c | 3 +++
 3 files changed, 9 insertions(+)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 2c37c6ac7525..ade170109ff4 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -27,6 +27,7 @@
 
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
+#define IP_VS_SVC_F_SECURE_TCP	0x0100		/* use the hardened TCP table */
 
 /*
  *      IPVS sync daemon states
@@ -105,6 +106,7 @@
 
 /* Flags that are not sent to backup server start from bit 16 */
 #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
+#define IP_VS_CONN_F_SECURE_TCP	(1 << 17)	/* use the hardened TCP table */
 
 /* Connection flags from destination that can be changed by user space */
 #define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6fa3e1dc534c..0b465298b64b 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1090,6 +1090,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
 	unsigned int conn_flags;
 	__u32 flags;
+	struct ip_vs_service *svc;
 
 	/* if dest is NULL, then return directly */
 	if (!dest)
@@ -1102,6 +1103,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	if (cp->protocol != IPPROTO_UDP)
 		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
 	flags = cp->flags;
+	svc = rcu_dereference(dest->svc);
+	if (svc && (svc->flags & IP_VS_SVC_F_SECURE_TCP))
+		flags |= IP_VS_CONN_F_SECURE_TCP;
 	/* Bind with the destination and its corresponding transmitter */
 	if (flags & IP_VS_CONN_F_SYNC) {
 		/* Synced conns are hashed, so they can not get this flag */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ba0957798bad..aa8a3a964ffd 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -784,6 +784,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr = { .all = { 0, 0, 0, 0 } };
 
+		if (svc->flags & IP_VS_SVC_F_SECURE_TCP)
+			flags |= IP_VS_CONN_F_SECURE_TCP;
+
 		/* create a new connection entry */
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
-- 
2.51.0

