Received: from mail-dy2-f41.google.com (mail-dy2-f41.google.com [74.125.229.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29E9744AB8E
	for <lvs-devel@vger.kernel.org>; Mon,  5 Oct 2026 23:08:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791241703; cv=none; b=bwqVB0pW9BBVT9O+GcVgCoOIJ8jTei6mVeXcaNrIJHoWX3+agRySSRyzfUaVU73HELJa/Qi4uWKe2ptkWrRluu3lq9VXDGUKEFxjczgGwvmyo744H4M0EG1q8NUYqHaDyswiJjx1aRl3TqF1cKu4PUpPp9LBb6CSERarGgBjzNY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791241703; c=relaxed/simple;
	bh=RuOlmH+gE+PsU2c4ImXZATz12XxcNJl97Anm6ea/uvI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kFS/F0tJ/Q3pxONI/LTY/QKd9jId+BuroGCrk6iMFA9qwudVAkM84jsDarXYfW0OVy+qEoTgxFYqZFLYxoDpNq43NTadzuQJMSkpR6DbNQ4HflM3IKu3D9LqvJxa05yjkn0c70zmUFkvmJ/8Zq4esm0em+Fqltx6H/nH6frI0O8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Jlcbi+yz; arc=none smtp.client-ip=74.125.229.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jlcbi+yz"
Received: by mail-dy2-f41.google.com with SMTP id 5a478bee46e88-34c0b552ccfso1875884eec.3
        for <lvs-devel@vger.kernel.org>; Mon, 05 Oct 2026 16:08:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791241697; x=1791846497; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iwVdub7SvE0q9v6YhfCPFziiywDnhl87IC9aEio8GCg=;
        b=Jlcbi+yzhfTypLY+gEBRimQMnUWF2joCZk73MzjoDGyISvuk5Brs8vK1CY6EZLgd0Z
         q+UHqqfgSC82n5fjwD5BCsyvNfLvWnY0MmBXST6fvqA2fjdGcaki2aLs4sr68EiH9+zq
         CBkoapP/MqKQ50XQAhoWV89zQUHGi3R3s7YxAYg0PvBGO5iZ7u3rVuPbjRHkIr7eQPeh
         1tdl9VurOgSsqAI9xrvJtlDgEPG6JQT6mXk7Rnvn4Iab+PD/afWH+5ZNcu1Zq5Eca0WQ
         5UXShL6t0/JoGoxpjXBQz8MPtov5UuE17r0PqIGBz3JHkt+XpVDwz5QN92WlTKxk4KEF
         t5hg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791241697; x=1791846497;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=iwVdub7SvE0q9v6YhfCPFziiywDnhl87IC9aEio8GCg=;
        b=j9sYAAlqTEGR6kgJi6rZ0Y+pnDWsStgznzMmLgPefVLRmEz48igSOPbQGHJao8uU48
         RpYTZrIRwTvq1xtCO8C3IIUyvl7hGvHt6eh24aZEeiG7tSnAzWGn18Ah1Ygotox+j0y2
         +uVZ71/Md44FZX7irfPwHZ2OrIpC8vRLqbZyROCtVRcE1lp1nnW+U+lC2dTALqPc5oCr
         QLLAfsQTyJajUkY9Zp7eLGBGA9o25/DxY9O1t/r75CTxq5N0ppe8dualhxc9es0i6Y4Z
         nKkhrPK+IIaaDHR1sX0lLWVx8RN+LvG4SUh/xSbp/uRAsI1WJxbz4OYCrgEvsK+9EbwI
         Kj2A==
X-Forwarded-Encrypted: i=1; AKwUvByvu1LhbF/4Y8CveUvvgsf6jrF8bCS949SxF2H9sFE/UyYZmONd7i41enMdVfAO+R5HIDNgkOJgglU=@vger.kernel.org
X-Gm-Message-State: AFq9FYKepgctqhUgg026bxxvIRsHntMVXPrnBZWbIgm1xzXv96vC4/9Q
	kY22KBinHVQ2+/tIWFWtKRGVbLm6OTxmXyAtR4B4M71oKGpG8bx/I6kZ
X-Gm-Gg: AYBFou1N+TLwebVkcOOqceIHau7RXyc5NHXB26N7fK0HhbTADBgS8EmLbT57F2YIWWD
	IfusoPJtoZ3PWQVh5UYDGw5Pbnm7xx6nWZ3VSqjQqV+vbb9MettgTLkj+1tZrYdfZIcg6meIIBB
	67500w36FbmCeUkH6CSsNTGBrCFluCdVVVX8Y/2evh/VB+2oAUc2NCJ5YnTiDrbB16DiEKxKLdY
	y60CqBR4go1Ae9n6OmcY+Ow8XEO3jRzd5R79IDy8HEFiRfVxN6uXD5nYOPxzIAplRqajjvhtdqt
	tBgKYRztd2fejkJZz19I4EG07FnI9gcVy0ozWEsbhUOeGLLCeAuszv8OhJbFKDXFbTqvjVRo04d
	r7qdplM7B+5DNXbMZaETyLjJF17tg6K6ftXpC//iHpaXIU+4ohX4Wprhw5WJSMSoFDBAOJkPv9t
	BznjF0FVXgxGKzvXQYNSXJjsEgPF/abpXlINACoWpXA+TVofGjO2scIANQ97bjgic=
X-Received: by 2002:a05:693c:41d4:20b0:341:c6ca:1df3 with SMTP id 5a478bee46e88-34f150bd707mr14582248eec.14.1791241697110;
        Mon, 05 Oct 2026 16:08:17 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-35146a5b004sm1859493eec.18.2026.10.05.16.08.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 16:08:16 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 nf-next 1/3] ipvs: add flags for per-service secure TCP state table
Date: Mon,  5 Oct 2026 20:08:06 -0300
Message-ID: <20261005230808.148478-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20261005230808.148478-1-adrianox@gmail.com>
References: <20261005230808.148478-1-adrianox@gmail.com>
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

Changes in v6:
- Rebase onto nf-next.

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
index cb009208826f..78be0a4983dc 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1090,6 +1090,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
 	unsigned int conn_flags;
 	__u32 flags;
+	struct ip_vs_service *svc;
 
 	/* if dest is NULL, then return directly */
 	if (!dest)
@@ -1105,6 +1106,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	/* Only visible templates can control multiple connections */
 	if (flags & IP_VS_CONN_F_TEMPLATE)
 		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
+	svc = rcu_dereference(dest->svc);
+	if (svc && (svc->flags & IP_VS_SVC_F_SECURE_TCP))
+		flags |= IP_VS_CONN_F_SECURE_TCP;
 	/* Bind with the destination and its corresponding transmitter */
 	if (flags & IP_VS_CONN_F_SYNC) {
 		/* Synced conns are hashed, so they can not get this flag */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd503f0efb57..0c5935a2f58a 100644
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

