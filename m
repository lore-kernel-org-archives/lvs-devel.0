Received: from smtp-relay-internal-0.canonical.com (smtp-relay-internal-0.canonical.com [185.125.188.122])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98F7C7FBD0
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:15:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.122
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715004905; cv=none; b=hiWZUXPiavucGVfhUlGxXykTiGMmZNVWJCVN31B7dI9bxeszL2ZoFiEAY/KDx2lPhvrdk+We+rXqmsMNCzcTswOH5VFAWAqPeGXyqpurY/pKnArqewFg/7xIz/iJ1q1QOiP7H/j++kR+B77oYaA32igIQTc3VE2gazzFDrqqAQE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715004905; c=relaxed/simple;
	bh=wcidanXZQTb3aE8biUO7m9uGWdjY9fC00+u5PTnfNfg=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=Ti+YSYYEqkWWtLYbVWfJKPl+tLEZHCebfl3Q2KWAN6nyjXZWYDS/dot8FKtdTe133vXA8iojRacPHEDEwPTuiENrpBkLn3OZdBqtFc/RBqzJExqUuSBO4yhptx4vS+U+32fu1PkRzq0jt7PaBtCibRu4xHHK5hvBLmnDCuGWSGk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=phcptJ2Q; arc=none smtp.client-ip=185.125.188.122
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="phcptJ2Q"
Received: from mail-ej1-f69.google.com (mail-ej1-f69.google.com [209.85.218.69])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-0.canonical.com (Postfix) with ESMTPS id 9D4B13FA51
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:14:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1715004894;
	bh=ZyaYKGnkDPnTk6rgEgUZ2eoc97Zq0+zWClbbP5jrG5Y=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version;
	b=phcptJ2QVN0G8jM8cNMMBXZ5gNfWBLDEoemhGjO0tdU90Nb3ykM8qrXT3sAjsxcpr
	 KREGP2NgUd6/12S7lw8jJCPz2dG2vx6r5sJdR4sr5UzGCFp7HCyzSNiPcSuWowiNiP
	 NkAXKTkYpHInv2dEAo1VPpGQYblhUWHpQIs/SoU3gSebJOSBbigY0CPFItPAPdE/R4
	 eFtGOVo4zZYzW4u7xhq/hAba2J2TS3M3aBGduEP9kw4VZ94PnHbwPnt4L1AFo7BcOx
	 RkIJ06U88vNhmFzum63uBDrQQrvJ6vlr9OuEoVsrqZqZdV0Q/FBULMxdJDiWtRqAfc
	 0DljOOaRMjI/A==
Received: by mail-ej1-f69.google.com with SMTP id a640c23a62f3a-a59c7586f7cso70219966b.3
        for <lvs-devel@vger.kernel.org>; Mon, 06 May 2024 07:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715004894; x=1715609694;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=ZyaYKGnkDPnTk6rgEgUZ2eoc97Zq0+zWClbbP5jrG5Y=;
        b=mfQIA2vbpPZiXMoBZtLbAP0Pmu8Tf18XLBG42FgHvhaZXn9Ce/r2ykNDMcwqSItYt0
         PYMerVPgnIsXEHgLz8xHwiuxryfktlRi7mtuHJyyaalGtHHTMikZzhQ857A/pC9HOnSZ
         0B8YkCpJ3puHCEBD2QeuuRMLp/dQpqsoIJ7nI6cMBu/yiJ4vjmLHN/MLEIoxBRYk511W
         bEVM9DV1hELGb8sxDK2R51/RkXdxox+B0//cgwPq40Z6qIelBbLmjBA8fCyvfnSfrbUh
         3n/uWN2ownUAtyZLdKiV+P4rKiKEnAP96hFN/9mqUbmsDlRliUGzGvwtZxZPBj09TTxj
         +zhA==
X-Forwarded-Encrypted: i=1; AJvYcCUj2TcvFvkC5aVi9obRPAkxcu6/Wd4t68tLQEmFkYDJzcufdjijNhM18PPDPgoGyutO8xvfJAMJerQcSapwpJGzf9bA2L2Lk9fo
X-Gm-Message-State: AOJu0YxSxfihqDYJBg97DghZNZOze8qg8U9oiA42k467T9fUbo50oYWc
	0RktBo+cSNTvHT+He8q2qTcfpGDjHjsiNHX3WsOl+Aa0wb7rW9nvPbFHvV17/G7na5hRJ2qsl8G
	ZWqYPOZTx4d1mHJV81ZH6oenf57tEwzX4M3Qkmaay4Hij/qHvOwR9NdK9kQXZthNrHEzd+3fzYQ
	==
X-Received: by 2002:a17:906:4899:b0:a59:bfd3:2b27 with SMTP id v25-20020a170906489900b00a59bfd32b27mr2701619ejq.70.1715004894083;
        Mon, 06 May 2024 07:14:54 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEk/9m6RYfEf0M6hlNPk6/CFatHUn4Rb6d03W4Hp+pLLGOwdF9b9V1H4mNBZdkFpbMX/boBAw==
X-Received: by 2002:a17:906:4899:b0:a59:bfd3:2b27 with SMTP id v25-20020a170906489900b00a59bfd32b27mr2701599ejq.70.1715004893754;
        Mon, 06 May 2024 07:14:53 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:4703:a034:4f89:f1de])
        by smtp.gmail.com with ESMTPSA id xh9-20020a170906da8900b00a597ff2fc0dsm4663754ejb.69.2024.05.06.07.14.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 May 2024 07:14:53 -0700 (PDT)
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
Subject: [PATCH v4 1/2] ipvs: add READ_ONCE barrier for ipvs->sysctl_amemthresh
Date: Mon,  6 May 2024 16:14:43 +0200
Message-Id: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
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
index 50b5dbe40eb8..e122fa367b81 100644
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

