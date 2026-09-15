Received: from mail-vs2-f32.google.com (mail-vs2-f32.google.com [74.125.227.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 621C5418346
	for <lvs-devel@vger.kernel.org>; Tue, 15 Sep 2026 22:41:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.32
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789512094; cv=none; b=EADI5dS9Bmm+0Q271/DndGNMKnkit7mQuUYdmyJmXHP+5KkZoS1AZgM+IxyN5tgdDG8eaDBmHNic9CruY9d1OG0zcGrlYyoKRS+ko1Rl5AbPO09ObiL7oN3Ni5CjYfjIGAtcF1lkuBaJAmRSs85NfFeQKNKan4XQcCLQb9ZDHu8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789512094; c=relaxed/simple;
	bh=Kyh4J3uXxKY1C5bNjX3MqrZtSsK7sPC1wg2NbNBCIwQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hlhJxwoCV41wscmlyl45uw/pHf3NvSU+wTIPVCu1zxPD6Nv6cJJ24fPfsMmEDtUNEymf0ns4BasNCimKp4Adss1/+z9GVKsAV+w0OH4Nozpjqx9KM2uClWPWtNGkk6abO3D1wIHjkdH0PTbqYnXOegYYlxlbw5O4tCSZPVKJh3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NdSdKhdS; arc=none smtp.client-ip=74.125.227.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NdSdKhdS"
Received: by mail-vs2-f32.google.com with SMTP id 71dfb90a1353d-5c67e4d8d8aso182731e0c.1
        for <lvs-devel@vger.kernel.org>; Tue, 15 Sep 2026 15:41:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789512092; x=1790116892; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=StfeLdJl3NyRKAxmr0Q5/80WQQS9SqqL1W9LYvixQ08=;
        b=NdSdKhdScUzYzMswHvXVNikOpAnUaU7uhcaPZrFQjTnmgD6yb6CurcXqH8r3xJdS2D
         e1JRz2FMqQpbKVk6ushXLvSWMjhW4ir1N1R4j/YqnxoC+lW1Ts/CC79dUD75ObZOezBw
         UXQtXtBOOz54fEYuOVaqaIhHMQcerH3Og3uDeVdgzm+0hXbLH40lyapDKBUPaEQgyIlE
         SMHJzNsDVBhgkYTkbg7znDMEqYx+R/p8RW1S00ABUJ6KAWDeOGSzUM8UwFys919GNC4Z
         iN58Fn45wOapDfRETWbabiAaTXH/xiNkcMx64h8WQR+wklgunAJVQvJHCE9/xDvCVN9n
         hqfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789512092; x=1790116892;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=StfeLdJl3NyRKAxmr0Q5/80WQQS9SqqL1W9LYvixQ08=;
        b=ISR8mmlr4NBeguhIY1ZS8uwsaQIt1Ig0Ig9dZBUz1ZUouv7e0J4p3ocXRcz5hFknre
         f7+fvIGjqdvhNhszL4qqwaAWcplvPKkZ0qoIx13E/ke2ucEIibM50Gw4M7pMVvMlAX1K
         GANHdP6GXPBgjQRXgjDB+qXjwPLk8S04TrVNlHtEsUlBTcAVNBHdXQJEl0GNJzTEmDUY
         qrkRxdOMZRAIcq+cBn5FaVYuDGvCOXuhyiyBaPn3q/IW0wzyfWTcTtFivKSbfx3ObfdZ
         4jCrjXLrguNl64QjfcFSeau03ev1UvNf5dOq96QFaU6FI+NV7Sa0FAbnJVtOGodqQn5s
         8+Yg==
X-Forwarded-Encrypted: i=1; AKwUvBwSmwS2ZthOmH2AGN41uKjb3C8x67fegfgn4OTkOaUgrPQVmuCzPlEKHD30FoDkjBhOoInNz52Jxuc=@vger.kernel.org
X-Gm-Message-State: AFuF++m2/+jVDn2jD3n3oCxD79yWvE5zI3R8VWcyEv0zLwa6/7gSDWcK
	RF0QOS8V78lZuNmQ7ooTMaDr2x+ob8DaW8+/W5YbKKYbITA2nReDB3dW
X-Gm-Gg: AYBFou0RnmZJhg3RKbBcyG0zAmyR+3NqycSW3Ff5xNfQn/CEyi407OVkoaSAgsp0D6f
	fNXuTh69B+g1Pu8p993G/p9L91QsEJd1iIFhl9UZzL1ZR7yEbrTf4xFtmdjAwsYaRNCLn2YZ2zn
	TdyEOtpoGhMCTEWTWU7WwYS22RH/Q0Xt9OBS2X1WPT7GaKyOnkdNRAilr7Scp7lkzkBxUq/NVB8
	1aIbglihw89ayvQ0zwN+0N/r1P2gbHiJZnpuwrF9kohd6Ftor07lpcbwEdwVwk36pBF376xsgeC
	gQ8Yg6gGB4Qk64Mn5SDqaGZUpUEN2UXzuMGfvVtSa3SMLG42HiWtlIkmO8K15UnHahRZSQeYlsG
	mRsCTBDTAnnt1uCimyTRUj2IZNPudjiwvRT9rLW2wyofYNMnticT5drViMgF8qHMpKBB3UQTBYw
	Yy5ay3oyaBFuO8uIhDpPtHp2P/Camf0Lu7QAnUcCFofYx+0XBQU9ybOLgteMrf4Ck=
X-Received: by 2002:a05:6122:288f:b0:5c6:6189:c756 with SMTP id 71dfb90a1353d-5c99ab6f120mr226744e0c.2.1789512092282;
        Tue, 15 Sep 2026 15:41:32 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c9988e5f27sm974975e0c.1.2026.09.15.15.41.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 15:41:32 -0700 (PDT)
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
Subject: [PATCH v2 1/4] ipvs: add flags for per-service secure TCP state table
Date: Tue, 15 Sep 2026 19:41:01 -0300
Message-ID: <20260915224104.639985-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260915224104.639985-1-adrianox@gmail.com>
References: <20260915224104.639985-1-adrianox@gmail.com>
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

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
Changes in v2:
- Let IP_VS_SVC_F_SECURE_TCP be 0x0100, leaving 0x0040/0x0080 free for
  scheduler flags.
- Let IP_VS_CONN_F_SECURE_TCP be (1 << 17) and drop it from
  IP_VS_CONN_F_BACKUP_MASK.

 include/uapi/linux/ip_vs.h | 2 ++
 1 file changed, 2 insertions(+)

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
-- 
2.51.0

