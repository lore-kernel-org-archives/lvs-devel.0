Received: from smtp-relay-internal-0.canonical.com (smtp-relay-internal-0.canonical.com [185.125.188.122])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70EBD16C6AF
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 14:57:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.122
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713452278; cv=none; b=M+BgG4rO1YRHozHSag9PA0UZ8J+yan0pe6loTbSvCv9c6gOY5NCZ4bxPFurdZbXsLcx7nDIwhAleQ8J9NJEgwCZHoByuSQJL9cIx7BMvVgORkUQelam6L3mNS5yMnvRvPaJUmaSzlLrmRAmVba863QmUf00+Egxa8esu8W6sv3E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713452278; c=relaxed/simple;
	bh=XnWJOnILBcBRDeU1BqBLAtGDVWZ7R54SvcYt0DpJjys=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=miiZxO3ckWZ29+afU2rj31gZypHnjp9FuuwFfaHDLOMETJZvV2wDwcLGBtordtveqd7yiOLIZey+zFkFor2/DgPDAFYlIJKR4pHp3ML6f4yemScNOVKeZ9zr+rni/L0dHmd5SP5O1mDgZ1MBZPYFzYInAoOU3PyM0gcDNfJwPCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=BAT8MIoK; arc=none smtp.client-ip=185.125.188.122
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="BAT8MIoK"
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-0.canonical.com (Postfix) with ESMTPS id 76CEE3F68F
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 14:57:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1713452272;
	bh=TPzhJ3AAYaNuKmuKpflVm92Wqe6tHXbtl8g4S4zlOco=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version;
	b=BAT8MIoKlopi90CacwOQVPh0v/pBJBYgIWvrP5qRLoZbLA2NqWDQHgyvXwiI8UEMW
	 boJDhO6wVH6BH7mzp8Ow73Im10o8w+rMrgerZmcKTcYFIJDBknvCST6yCW3mHRykZM
	 0BizvkRbPrM9H3XgXAf0ilFPS46mONPfyCS+QVy70t7LQzYpqFhwkCIYqwPoj9oT3h
	 1YhQ0DXnF0rC3nmN1v3u5PyDfTA4r0v2m9wb/Quo2487xqk3uaBRR+SbHUfqAesfn7
	 CEK/p7Db17pH0wwod0eVQHbuvDuv06EdP+R+fBKJnM1d40nWBWmqwQz27d6lQBW7L1
	 9SCG5jpPRdd2w==
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-a5569434b26so58442966b.0
        for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 07:57:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713452271; x=1714057071;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=TPzhJ3AAYaNuKmuKpflVm92Wqe6tHXbtl8g4S4zlOco=;
        b=dN7l5cqU84aQQNGwOB7wC6lrMVe5TEH2ysKUHwxiEE0MoxrckrPNSJlx7iYnKz1lRS
         I2NqWkv0VDW7C8irxgoLad75IydNv4uM9Nv1VNHY41nkyPE6qCjOqoTjp7ziV+igiaBw
         UFFVgKuUeqLYGSMnnhOAEz1IWndbqLwromcMrhuzkji9hMW2cHPfoElgvNdSUGUYlqRC
         CoLuowkzPaN83rMwndndu85k4T5pVEV6/WMTQMtshqBhKG8Fi5Bkv29k2AQswYG6TLIZ
         nZmb+XovEGCCWsQfaixKyDRz+azSp5OAL3R+wRCnmaf96+EFn7FhzihodtYcR1tBKL4y
         AerQ==
X-Forwarded-Encrypted: i=1; AJvYcCWJSzYNXYlA6a4ICGmyefJw1gWxFFmvbJGoXH4EOCzBVuoZ1HNRdyyOmt12E05oM3+d63cSUWbbo+XzlZNk+iI+37pBh86R5xLv
X-Gm-Message-State: AOJu0YzdXqX/lNBeSVxRYC1rIoFsXmC2fZFCY1IG4BLlK8lxvzIUOdhf
	Zg960UIpRPuI+41BXXbhDzZIIB3okxIjFUTpXpbKaXHCjSr4t+oI/kTYQYafEzUSFppKaA1hbwP
	hXdAqSVnD+tV/8Cz65SSXy3LuJftNZJUAcHu4gYQnmzNXryiBGhDUTl6AKZ7LBP7crk3/7AUqW1
	uPs95epQ==
X-Received: by 2002:a17:906:1182:b0:a52:58a7:11d1 with SMTP id n2-20020a170906118200b00a5258a711d1mr1836767eja.38.1713452271343;
        Thu, 18 Apr 2024 07:57:51 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFhzDZOsSyjW2YgiF+3b9SbPzp6uVKID7mT1Wura27dE1HKH8MQkcJys3WmmEXVTnVSN92wWQ==
X-Received: by 2002:a17:906:1182:b0:a52:58a7:11d1 with SMTP id n2-20020a170906118200b00a5258a711d1mr1836755eja.38.1713452271043;
        Thu, 18 Apr 2024 07:57:51 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:320c:9c91:fb97:fbfc])
        by smtp.gmail.com with ESMTPSA id jj17-20020a170907985100b00a522a073a64sm993665ejc.187.2024.04.18.07.57.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 18 Apr 2024 07:57:50 -0700 (PDT)
From: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
To: horms@verge.net.au
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 1/2] ipvs: add READ_ONCE barrier for ipvs->sysctl_amemthresh
Date: Thu, 18 Apr 2024 16:57:42 +0200
Message-Id: <20240418145743.248109-1-aleksandr.mikhalitsyn@canonical.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 143a341bbc0a..32be24f0d4e4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -94,6 +94,7 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 {
 	struct sysinfo i;
 	int availmem;
+	int amemthresh;
 	int nomem;
 	int to_change = -1;
 
@@ -105,7 +106,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 	/* si_swapinfo(&i); */
 	/* availmem = availmem - (i.totalswap - i.freeswap); */
 
-	nomem = (availmem < ipvs->sysctl_amemthresh);
+	amemthresh = max(READ_ONCE(ipvs->sysctl_amemthresh), 0);
+	nomem = (availmem < amemthresh);
 
 	local_bh_disable();
 
@@ -145,9 +147,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 		break;
 	case 1:
 		if (nomem) {
-			ipvs->drop_rate = ipvs->drop_counter
-				= ipvs->sysctl_amemthresh /
-				(ipvs->sysctl_amemthresh-availmem);
+			ipvs->drop_counter = amemthresh / (amemthresh - availmem);
+			ipvs->drop_rate = ipvs->drop_counter;
 			ipvs->sysctl_drop_packet = 2;
 		} else {
 			ipvs->drop_rate = 0;
@@ -155,9 +156,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 		break;
 	case 2:
 		if (nomem) {
-			ipvs->drop_rate = ipvs->drop_counter
-				= ipvs->sysctl_amemthresh /
-				(ipvs->sysctl_amemthresh-availmem);
+			ipvs->drop_counter = amemthresh / (amemthresh - availmem);
+			ipvs->drop_rate = ipvs->drop_counter;
 		} else {
 			ipvs->drop_rate = 0;
 			ipvs->sysctl_drop_packet = 1;
-- 
2.34.1

