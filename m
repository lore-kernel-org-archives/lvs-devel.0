Received: from mail-ua1-f42.google.com (mail-ua1-f42.google.com [209.85.222.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A9174E1414
	for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 20:57:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790024238; cv=none; b=FQGaktb/4ZpsdmqsJEuf9cG7TVpVUgCjBke2hP5dunTVohellolUXInt2CDSbFr6GM7HUdMBndEY5BMXFNMXAG+Q46JoeEzLWTMNKj0yfZrnfw9xONWC4JnDZQyHvJNLiJcPWFr8wLetuXHjJY6WQ8ynXJ5RysuVwpIouTOpPWE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790024238; c=relaxed/simple;
	bh=XwLRDqoGDPXb6K5PWgL1M7DdV69+VMAJJyWkcb0+NUo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U8qkMMw7rubpIDPzaT8fhrtnEe51wZFoiSyGsec8Xkcp1DBYkabPPORWLQKGZk26Dj/8OwtdiI2oVcNfrPfmZR/za3COqSfdlZMditkSg1jiDzjh4hpMZCw2DTauxNeEb4BafNKpD3R+td7UsUyBgTZl7FM+1EYHrptb4SDaO4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=gctrSTTw; arc=none smtp.client-ip=209.85.222.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gctrSTTw"
Received: by mail-ua1-f42.google.com with SMTP id a1e0cc1a2514c-9830aa5523bso216034241.1
        for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 13:57:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790024235; x=1790629035; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=83+plyF4HOp6Tc6yDaOIUjOh/yxbiFagCuYc/tYX0qs=;
        b=gctrSTTwh4KNldwSOKV4v9wn6xM3km2liI0bThL0e3MKs+L5sSxsYX6hiLihvTnXdC
         ku2HRaTnNhLChkKO6nZ19EJmAGOhmZVG7nv3aGERcadabr5OjfowsbVJJL2ZNL+IQdTA
         TZ4g4idRdhnJiCM6g3p0R/4z2WiO5RB8d+yp/M35TR7CcNQryP7AGd3W90riorE4KrtR
         YAUbyttQIbVzMSOSl6njNhujmrbYel19QJCVRf/n63I/vUlsrn5zrwB3LHnWF4d0ivff
         ldUJ8MFJd+qZmlerCs+7CyhKP9GCwN915N0WtyHfZQ1Yb03r02cY0BQs9S+JPSBWSrlW
         Xilw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790024235; x=1790629035;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=83+plyF4HOp6Tc6yDaOIUjOh/yxbiFagCuYc/tYX0qs=;
        b=ZY7DslTkRo4IS9PEFyiHpG7a2F0VPATsXmzk40lIT0DUMtCgkvmKiMI1aY6I1AZUVu
         dlMs6ekyVRqnxtDjxd149QMKN+EeQ9HCDlRyHwUSIe75XmII11M+tEHG2NSVrGTkFXOl
         PhhLZefhD7b+L26KuoNfpviPDoJi9nfN1Nm9UyfQoR82HP8yVnR0Q3om0/6GBdQZCZY/
         yTJeRGCF/JPgrpl5Wyh6/QsxeN/4oOkkLU9d8K7zkw8XDxWhsAY96nygH/sZ2Q56eiUz
         juNSMAghkYpxp0Fn8EPvdCRduqYPRjwkJAsNbNrKsI/2Irk+H7xqh69AC7irhuJM2LzS
         XdRg==
X-Forwarded-Encrypted: i=1; AKwUvBy1F9BqcROmC9WbjWRU0rE/lu01kmzKJ51AsFu7Nr1EN/EbMHSfQnibvQ3d3Mq73rKteiFATWy1bDk=@vger.kernel.org
X-Gm-Message-State: AFuF++kcBh7G+nNP46uleNwa1Vjrb+Jo5mi2ekgCEJsJ//XWmrWTS+GK
	UUPcHGAJIIicTMcC5DI9h0jPf+ZVdqD9wxOXV691BiMlJ/qHKDUY9T6f
X-Gm-Gg: AYBFou1wqqe1m820KHX9uhEC6d24w1x3cF/uUmH2yVscFNTT3rz0Wi9Q2RhCyd+5QOC
	633+g7d1Vr1IMqGwu1D2w18TYunbvbPRr7hjFjYANdauCTSVfSt6mFpXxlWFRRym+vHo0u8QjSp
	QPyUVR+5JlzM9ZfVrtT+a1kfwG0LzlfKUSEIxuV3Iup4YMJPacYxTUzL3RDfraBCJl3PKMSNtIu
	yJCxhPHEZVYdtk1VTUmlEvfTwJRniaYLRai9/+DTUediq/lFtACJ9f+eY+RCa7BY4qhPY/FWKnq
	bxVRj8zEyiq7fNcNwUusupkRnmmBgiMTcQ1wD3qymyswNEK7UoJFvRw4OSSian1b9jNTX/9Fkej
	p0dQmskT6p6vXD8vk0MIzhvnjYRquFOIbfOCh+LzOyRsUea0rb3X7VPYvT5cSZlgK7/3aG2lMqz
	HnJQST+t23VsTcc6quXrb1E6V0TYlmdraRsdplZCXCDLwU2pHg10g0Cg9o/5aq1XU=
X-Received: by 2002:a67:ef8e:0:b0:7aa:d0a9:c5aa with SMTP id ada2fe7eead31-7aad0a9c60dmr280100137.18.1790024234730;
        Mon, 21 Sep 2026 13:57:14 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c9e591d496sm286884e0c.2.2026.09.21.13.57.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 21 Sep 2026 13:57:14 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 nf-next 1/3] ipvs: add flags for per-service secure TCP state table
Date: Mon, 21 Sep 2026 17:57:04 -0300
Message-ID: <20260921205706.1055288-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260921205706.1055288-1-adrianox@gmail.com>
References: <20260921205706.1055288-1-adrianox@gmail.com>
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

