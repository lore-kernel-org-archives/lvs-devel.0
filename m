Received: from mail-vs2-f41.google.com (mail-vs2-f41.google.com [74.125.227.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABB063BCD25
	for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 20:50:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789591835; cv=none; b=TR9TKIYxnIMQN/uCSe4jBc3FaE4qGBRPZMoJkMBfLjqd4Nv/d3hbC5RLj+uCc1SMmXYf0eqrqOoAa1P/LpNp+sjmYvlLLwpCbUDXHMftRVK4wXqT5R2CfyrmUteDQ+z5A3D/DNnMlSoMhHPnXkxFHcD7l9re/z8vYKDeXITrLdA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789591835; c=relaxed/simple;
	bh=r4G5Ta8DgCpNKxXd+Tmp2CKseIRyFZZjfIzJ3sbKUC4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=K4zOWVxYuN0bTbMpAluVm8u5aBiwUzp0j8uqVXvJwOB1JZE7fgTuiOq6gnv+Xp/lnAtYJmnQzpaE0COa1YjMuruZ660Shl1oBx6dZfVIgBfl20OvqKKuWgOlpbbnoiIXIDuuNAv4Lcyjva6IvvORtXRVsmc6paLoh85wwy9vz/c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AcCB7A90; arc=none smtp.client-ip=74.125.227.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AcCB7A90"
Received: by mail-vs2-f41.google.com with SMTP id ada2fe7eead31-785686d2764so40056137.2
        for <lvs-devel@vger.kernel.org>; Wed, 16 Sep 2026 13:50:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789591828; x=1790196628; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HSr0kw5vQg14RdBAH3z3ZmTLwP6SZgfcuyqihKeKt2U=;
        b=AcCB7A90RXmTOiPQFMW3SPPCkzaWVe4pHvC0LQq1VQOXzdJVz7ziHkjWmnToVUSERZ
         mXkq/7xTHDQN7VjYmHwHaKgLH23IAalRbJWXCmX5jyt1Y6H27KoMA0ZajKbsXf2pn1Oy
         91GqAEMvkIBzFJ5Yh01JddAjIstioH6YcYKDY2duina3s5TMxzN6ovc4y4O2ak8BUUg5
         JU1ssB3HwBFX8jb85MkO1pCa62zp9nbTg+VjllAKotDfV1safHXglObHxjWf2HXdKGce
         4kfd7urAOoLAe8oXk4yjG98gCxe6MbrtUIVV60z5icDUyBILoB/kAQ4+DWZKskQ5W+ox
         Y5bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789591828; x=1790196628;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HSr0kw5vQg14RdBAH3z3ZmTLwP6SZgfcuyqihKeKt2U=;
        b=dPiFCEJKxishZtyLZjMz5pVFXg4V74Bwc0IDlEaISLx/5N1tJet8gLh5b3YLWb2YPB
         jzlfDqlFUWQe/v4nhR7FmvyXCfZgIeS9PC89WNfFRBa6S53D/HG1e27wZpxEl4z5ub+9
         a4zp2aGMcsXTkuZurIZH2ac0Ckd1xwsCi3Mij+7uCkt0BXuLspVLUcEiKLuZ8YsoOk/M
         2vtyKeEDFRyOESlbcL2oIGtUZSN/JFdekW87rEQswsX4QZvnybDHw6gY83ACnU1PGTZQ
         3a/1TvZWKzA7JFytuwKrQvHpiULNEJLTQsHOKYVddBpmz+c9CNMrhNA9EKcpfCWbrprE
         bY8Q==
X-Forwarded-Encrypted: i=1; AKwUvBxS1WHSC8B3Rd0uaB/hsrqo6ko5wiwBApb3Jx3Ra4zSok4IRoUzjNQJ7uA5qRRa+2v7HIqVKdpXt60=@vger.kernel.org
X-Gm-Message-State: AFuF++k4Ige9vx6c2sCitKBlti+C/+wXDLHfVVc+ZsrakiTykFqDe0/X
	SkJ2dG7oJ0SRLthEbx+0Qq57K7zefSvT3wdhntFO1D1bNeIqKuEsy3M6
X-Gm-Gg: AYBFou2oYXnPXFHysNtNWDEX46IZGLvz+71obQWV7MK/gvzX7D0Sq1qplkas/XaYawg
	THmujEJr1CbjTEAAslbe3FLvhUByCHlQ3hNIch1vz+G73gehNYTAGgCs0oomZRW1eDboH3J3sb9
	7pI0J7T+6r+MhDLPwuTLkyUMW+iQcp5v0sA8JsvoTiJVXfI2BSfsZfc9CZU34Xptxi/A1iThwUU
	Dw+YbkDuz18zH59/yQvfSxfatAk/WdbthjHoKGXfU9golhqlqfOHuHZwG6JdEew9XodYCKmwA+W
	Hzm5KlHWk2s+cNbgSXtlvj3JFCxoBmiw5Q98+R3f6tHHRWmMZ2vKL+uaJdibdIZaITXeUX62GN0
	eB8AEYnoeYfesI5AWKG1y6P4lrT7OD+3fRZiykpdIQ/Xw1Dkf0gfWCKwvdLT+g99AVADPsZSPDa
	i2pMs9uvKU33YkWINeYr8r0n5wijbj2N8Ruk28DbNRQprvimsak8yZckobES4XduUE
X-Received: by 2002:a05:6102:f9c:b0:7a1:f7d2:e80d with SMTP id ada2fe7eead31-7a1f7e27e6bmr657555137.21.1789591828210;
        Wed, 16 Sep 2026 13:50:28 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id a1e0cc1a2514c-9832354a8aasm947799241.10.2026.09.16.13.50.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 13:50:27 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Shuah Khan <shuah@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Adriano Cordova <adrianox@gmail.com>
Subject: [PATCH v3 nf-next 1/3] ipvs: add flags for per-service secure TCP state table
Date: Wed, 16 Sep 2026 17:50:02 -0300
Message-ID: <20260916205004.647194-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260916205004.647194-1-adrianox@gmail.com>
References: <20260916205004.647194-1-adrianox@gmail.com>
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

(no changes since v2)

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

