Received: from mail-qk2-f41.google.com (mail-qk2-f41.google.com [74.125.230.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F367423EBA
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 14:11:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.233
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345493; cv=none; b=hL+MMbvzamBUs81IG9BlagdTdPBDqCJpiDvrbTyhBR52yvaY8edj4anHrdaB4vKv6QxV0srM1TfBkEn1F/MUF0AuyUkGTa7Uj0S9jERD6P5yQ0OigQpqs2wI1vqjoCAzTpUmpvuNCVuPzOanIqNMtK8WM7reqiUsxikukdPzZjw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345493; c=relaxed/simple;
	bh=dndpdC1BFf2YzxpLiKezMO4GTZISkuWDrKJcbkUpd/o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=es8ArCPCXa0qV7x0AHs08LMVn1fKl3fcVOgGxm1TUzQZKwNWHRpqRVJKM/MII79l2454XNIbLuE1DBzj3nXHWxG1q5n6R/iVfOYfiexImjxKZRcu9dDi9qzIJ8fNx2K62BM1RwA5UBQMd8I7li9zzwCOK0hE9kiwWCuVFWbfsy8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com; spf=pass smtp.mailfrom=agilebits.com; dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b=uE2R0+c1; arc=none smtp.client-ip=74.125.230.233
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b="uE2R0+c1"
Received: by mail-qk2-f41.google.com with SMTP id af79cd13be357-93910ad2273so119348985a.0
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 07:11:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1790345491; x=1790950291; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=J3Lllhowz5xAm041vYg/0uhyYfJTfX7BTIf91ZP5MNU=;
        b=uE2R0+c1d0HLIki2Xoh4xJsjMAYRdFM9de9SkPZDS/HH10hgHz17ckVXxqPEsT7WpO
         TJENKPEVEBcJAilbP47sjLvNkL5TPZtyiKE+gjJF1hyE37bsx6EgFj80yGt0TifVUUmA
         pfPD4PXZ0F8a/NfcNoGjpY75+Yj7O/B62Us1M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790345491; x=1790950291;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=J3Lllhowz5xAm041vYg/0uhyYfJTfX7BTIf91ZP5MNU=;
        b=B1VnZDEYALYazyuB4lc+46H/Omu1KWutj2tgoEZ6r2oUFeFdQmGGx5qvoj37JGyFac
         s0ad2E3biA1PRve9Oef3HZ688lc/KDmijySoL7Fnt/PXjfQhoTTX/wKWryoBB5eY+Ejb
         CFXcZvHIEJxcpfDHhHnPtfacRUwqTazdBzdSIs97YHNDqCCuXUBZl+C2/6cm7FquEdUX
         TsBZPokuvshnJ8oKkj0XnkkWpA8x4lZqbEcqGpcGrojGvxldizlBA87kUjr/LzmiH2Ke
         74a9K0VA/ON8IbKigQfFT56AkZ1kYrePD+62VQB5XTm4kqxTyQLMR+0w2ltjmfjEjpLv
         qXfw==
X-Forwarded-Encrypted: i=1; AKwUvBxqkQDSVOhthskrsiC5wkW3mJOtTPKGnm25+eT982FwuXvG+FUiy+iOIIee2VRutCL2BTgli87txps=@vger.kernel.org
X-Gm-Message-State: AFuF++nqkOF5DKAf4J8UVheEBGUBFzn2juHfZ3MNmVqqFJNaealNs+i+
	L1f50NoQikNO/ryGrXhPv+JQAs9R/kq5zSPE6feF4Vioirbbd3xyn15xgUigPrDEIKM=
X-Gm-Gg: AYBFou3SbPu5lGenti+Jlcj71Y7TS429LdrJwA0a7jRhdAO5GmXu6+tkyu5rVF9auWT
	yj3yypCJUSNqkCOztvHI7niQ6iLGjOnyncIw2VHA1QIsKeM3XfpiPbXebaBwp3zqsemqGpvjced
	ZkWaZU/TLj99l2IKQwGR9HklsOzsKappOoWuImul/k6f5vkD0e/GO6iMRuGs5cHT9zLxAcMQCR0
	ULxXYL7Z+NGpyPrblUu5v/SGp0rtNVLTDfIZfsmqBwVxAe4J3LWtGhs4pjkrqn94db+s2vWWeU6
	GKZuejBD9rcRJcGw0eIHIOgHq+5NMjY9KpB0iwQV6wT4ArEVqb7JUMeaX1cKg4hS8Wazw3p4U9o
	p83D6ZCjEgrwNowOFdRG+5oKe1Csk0KzxgVn7q418yPuuOLXMJg9TTsE8XcKed33/RvmAT1Ki1a
	K6ksUzdzPYfdiAg94ntkCaiTBLAXzQr9lHG7fa6YXwMe1Ycl4LRgWzeK0drDsWgesnCRsovciRw
	VWTlkL8Hpvw8P+t+Mtw+TwnuIkZSTwZTs5fUFc+
X-Received: by 2002:a05:620a:3706:b0:939:6de8:43de with SMTP id af79cd13be357-93c475124cbmr376847185a.50.1790345490729;
        Fri, 25 Sep 2026 07:11:30 -0700 (PDT)
Received: from localhost ([2600:4041:59c3:300:7917:c7f6:28c6:182b])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c4493ec1csm187075685a.30.2026.09.25.07.11.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 07:11:30 -0700 (PDT)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>,
	Keith Hoodlet <keith.hoodlet@1password.com>,
	Axel Mierczuk <axel.mierczuk@1password.com>
Subject: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from packet lookups
Date: Fri, 25 Sep 2026 10:11:13 -0400
Message-ID: <20260925141115.16126-1-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A template received over the unauthenticated sync protocol with a
nonzero cport is matched by data packets in ip_vs_conn_in_get() and
the protocol state machine runs on it. Patch 1 rejects sync records
with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
the backup.

Patch 2 requires a nonzero cp->cport in ip_vs_conn_out_get() so that
templates and connections still waiting for their cport cannot be
matched through the out hook.

The companion patch "ipvs: filter some flags received in the backup
server" rejects template records carrying IP_VS_CONN_F_NO_CPORT.

Axel Mierczuk (2):
  ipvs: validate cport in received sync records
  ipvs: skip cport 0 connections in ip_vs_conn_out_get()

 net/netfilter/ipvs/ip_vs_conn.c |  3 ++-
 net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

-- 
2.43.0

