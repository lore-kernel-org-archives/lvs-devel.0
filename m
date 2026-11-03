Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.175
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793725154;
	b=Hlvh/LUJh0PCPm4lNJ1yuEK9Kz1cQesJ6mlzrGh1ODWc/fQFSKwsVccFKQK2Ovq4vxVU
	 yRng5os45NiuG23jD2dzOHKv3EO7dgBzMXxumRm0NRXhRK54PkTGwfK+vZQLiL9D+0u0Z
	 Y9fnHKFopqkIpLO3+V1RU7apbeoGuVhSTyIFTq8aJs5Htz1LfC+EdGWaYvv2z/QNHKU+F
	 WQoroZwUUw+dtnAWj8xej414C042RC3LapWiVZOpWgDxqEAd2eZH6C+kPnkpvbc/FO2lU
	 +o1b/QiXIp2hgX0+G07fyxKMVBIODX2VhSx0jbmgzT1N0m2y6lPiUJqqlirLFITtOsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793725154;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=N2nmgAkk9tKVW9ZZZ6y0Nm3a3F6PCdPuD8mrqugKq5U=;
	b=lHI42QKm0Phc6gu48GELad+0qZ4n7aoUrU9IQeLpid9VKEO1Cq6HZX/zGFVeT5iOa4q2
	 1bpiUDJ2dq0dVhxv/Gy7rNilSmK19Wgs20lUtqbfP2eTXrTgxdrprfhPwpVZ3CWazlk5+
	 /uegU43ytjbnwdqg6eE3KSynnOXmzRkQntGVlQnzWHhJ0ccNA4C7N184fd2jyNm7KXU7t
	 Z8fWM156iQhhqdCwf+a5mXRD9pW8Er0J9wkwT0a9RVz1JpdcghOWvq0entti0y1YB5LuL
	 ubJrbRxTwmttmPvMD6vTn2g8k3ToSDsAakr9HUZzhyzHfm3qbleROVMvTseB6rujWAg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=1password.com;
	spf=pass smtp.mailfrom=agilebits.com;
	dkim=pass header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=Z2SC43w2;
	arc=none smtp.remote-ip=209.85.160.175
Received: from mail-qt1-f175.google.com (mail-qt1-f175.google.com [209.85.160.175])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FA80606A329
	for <lvs-devel@vger.kernel.org>; Tue,  3 Nov 2026 16:59:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1FA80606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=Z2SC43w2
Received: by mail-qt1-f175.google.com with SMTP id d75a77b69052e-53634b8328eso39406921cf.0
        for <lvs-devel@vger.kernel.org>; Tue, 03 Nov 2026 08:59:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1793725152; x=1794329952; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=N2nmgAkk9tKVW9ZZZ6y0Nm3a3F6PCdPuD8mrqugKq5U=;
        b=Z2SC43w2Jegfalwfgu+2q/1oAUA+RXjVC6sKz/YdcFg4UC2x+XgGUs+2ttfIx/923/
         TdyxACU2F8UKQcE2sl3mLgvVVw/hKOoEYrDeQPuRcLkBkRsFm3B2i/KtCPrBTIQNu3tH
         T540yzoo+oQoP7XQHaclkUpQQ1a5vIlF4Pc28=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793725152; x=1794329952;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=N2nmgAkk9tKVW9ZZZ6y0Nm3a3F6PCdPuD8mrqugKq5U=;
        b=e8gKarrR8bEzyxBG4Lj/hKM1k65RaMkKZ3nDnCOpYsfiNvXNq6a6kfY3bZh1fztNg+
         JTRARZMVM1MyO2LVHDyyP7AUHEFp8F3kfSXbV2UNRb07OwH2oKpge4HYS1mVKrpEC/eR
         M7VXCalKqFd3ZvpVzdLZFQ3bdgkPNqQOPQizPUNxWDgEmr3feDc+pTn5wdDC+8KlKIlt
         5ku0MN+2VTfu4WJv4pGMYN++9MqI9Oe5QJ37mtzHM+EEZHB/sYyKZ7ReBQufI2QV291O
         OUlrm59fQ6/XyH3D8V3gccBe/vNLGLRaMlqexou/zJAS0qbKLmjWrb2fsqrJQJZMOuDf
         Uz0Q==
X-Forwarded-Encrypted: i=1; AKwUvBxRytWArtA4ceNfcKbei6ViNeujD+oXkUxYKPNdE3Zohuihj7L3Ay5H/wCY5RUI0ygcdXdz7Lpbqok=@vger.kernel.org
X-Gm-Message-State: APuU4Z/q1DhY7jVvaGCGhGHBvx5mfPJjFT7Mz+L8aFTMsKStifI5cRLS
	jTJBTDj6hv5g5QddtJRTQ8wST5OAsqKdsfcN4eYHcQ/FjGQ8pB1Cb2TT1pN3x4qWB4c=
X-Gm-Gg: AYBFou2RZyiL4pSghvNYBNtvrm0N91zesio89kCfJ09pEbxWhPliBXJQGHMUl4ykr2s
	5VpXnFY6ewxUmk/xrkID703mlKmSQ8ltkQA9ijGngABkyCJTqGH/2jRperPEdIQOKoFXg+VBZeS
	zRftckKrvqscws/KnSHBq455S4Z3pXPL58zslVi+T5tGD5O+XMlBeSci8sczD3Urr3G3XrEsdlA
	C/T54i5GEvXG64XeSXfbUERgMkVldDRIFIiyzA20Hm1bAbg8l7XRdw1VALJkzBEYqok3FLqIX9o
	ghStjIa2ij9z9RykIhPyICfeMo/6NSNE03ESXXdd06EWqi2lJMmmshVcWtK18G/DAgIE/rw3w08
	Rta4pMZTCQoRyuk+Dc/JgijGSHbQUTbJ7nAhDUdz8PrPP/fyRsUSsHItTVxOlVOT7rgeI9manNt
	5+pIq5HFLRnYzSeDf1jOZdqWZY0i6hZ0yPM+aNZaYJQdvuWCfcZZPSCjPkkaUdLSMG1FLJVdv9F
	yd7nEzynLkts12YTz1qobUOw9tl+/dH+EuG8JDNd6NhB42R9r81fXRzjy5qzPTduYe1Snq29i2y
	mY2oQUqUKL3VR+Gt6lNVgZr6aFQXKKM7xk02bwUBmT6Ec7nx8N9+4sO8jd7hlgkk5pGYbuTM1hA
	7M+Ymrw==
X-Received: by 2002:a05:622a:a584:b0:536:6ae9:f581 with SMTP id d75a77b69052e-542b8ad94a8mr237532011cf.67.1793725151850;
        Tue, 03 Nov 2026 08:59:11 -0800 (PST)
Received: from localhost ([2600:4041:59c3:300:a850:2af1:eb93:4121])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ca95caf90sm118485686d6.30.2026.11.03.08.59.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 08:59:10 -0800 (PST)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: ja@ssi.bg,
	horms@verge.net.au,
	pablo@netfilter.org
Cc: fw@strlen.de,
	phil@nwl.cc,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	w@1wt.eu,
	Axel Mierczuk <axel.mierczuk@1password.com>
Subject: [PATCH nf v2 0/2] ipvs: keep templates and cport 0 conns away from packet lookups
Date: Tue,  3 Nov 2026 11:57:44 -0500
Message-ID: <20261103165746.39516-1-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A template received over the unauthenticated sync protocol with a
nonzero cport is matched by data packets in ip_vs_conn_in_get() and
the protocol state machine runs on it. Patch 1 rejects sync records
with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
the backup.

Patch 2 applies the cport rule of __ip_vs_conn_in_get() to
ip_vs_conn_out_get(): a lookup for client port 0 matches only
connections flagged IP_VS_CONN_F_NO_CPORT, so templates and cport 0
connections cannot be matched through the out hook, while the
"update or create" lookup in ip_vs_ftp_out() keeps working.

The companion patch "ipvs: filter some flags received in the backup
server" is already applied and rejects template records carrying
IP_VS_CONN_F_NO_CPORT.

Packets with port 0 are handled separately by Julian's patch "ipvs: do
not create conns from packets with port 0".

Changes since v1:
- Patch 1: unchanged, added Acked-by from Julian.
- Patch 2: test p->vport against IP_VS_CONN_F_NO_CPORT instead of
  requiring a nonzero cp->cport. The v1 check made the
  ip_vs_conn_out_get() lookup in ip_vs_ftp_out() always miss, so a
  duplicate data connection was created for every PASV/EPSV reply,
  and it read cp->cport twice. Reported by the Sashiko review and
  Julian. Commit message rewritten.

v1: https://lore.kernel.org/netfilter-devel/20260925141115.16126-1-axel.mierczuk@1password.com/

Axel Mierczuk (2):
  ipvs: validate cport in received sync records
  ipvs: skip cport 0 connections in ip_vs_conn_out_get()

 net/netfilter/ipvs/ip_vs_conn.c |  2 ++
 net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
 2 files changed, 21 insertions(+)


base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
-- 
2.50.1 (Apple Git-155)

