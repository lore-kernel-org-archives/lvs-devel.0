Received: from mail-pg1-f175.google.com (mail-pg1-f175.google.com [209.85.215.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6106345CC0
	for <lvs-devel@vger.kernel.org>; Wed,  1 Apr 2026 08:00:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775030448; cv=none; b=foF36X6wzBpBc9Jz21vgJOEmDuBJ0acpdHKnhE657GtZxDDo7RtH26eY31Qp/3DwplWrcZDlFn5930aMT5ldX05Vj5F9f4WKenL9RjLsiRrvJEtKiUsV2sTQqMcBJuTFOUUh/YX7GRqdqHBHS1yZFwbepQXPBwX5ZtB+s6lyohg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775030448; c=relaxed/simple;
	bh=IPr2oYPn/26eQSmWxcSleR1D2ek6vWmOS678MnORj2o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GgUx+m8ghMctwF716N0aUdju0lQSwvZ7y0teMS0/31rhzt4winIMBud9ispcHMbgXyGUd45tSVVXlGbxCuHCkTIbyMZSjQH8mngjM1XM62aIiSGvC0+ub417m8oW2hc5FVHfJZ49fYa3xp7B2coWPYIhxlHAgod261Yz1g/mJuo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HnlDtbNi; arc=none smtp.client-ip=209.85.215.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HnlDtbNi"
Received: by mail-pg1-f175.google.com with SMTP id 41be03b00d2f7-c7358a7a8d1so4395353a12.3
        for <lvs-devel@vger.kernel.org>; Wed, 01 Apr 2026 01:00:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775030446; x=1775635246; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=2y8dUPGFi+UBO55SBUip5Hfz6jHTFtt4ylYjmLjQEmw=;
        b=HnlDtbNiLMneGLpWqFnifSQaPv14PcjRdIP6OuLaTJvhit+92zAPvm5zwqbtO26tub
         zMEWYmhjaJX0lxSMph241x1sJVwJTNgpKrhlwbs4w4kD0J1+JggpTaknNKWswBOpyuoE
         58Q4acqJXuJaio+Q4xObL2vVC7zzD8d55YsOLGA5+HtnKPdbJevveFsKWtqjgLvzN8ZK
         7Dn8wtHseyeJymCBbbMvAADrvGifMvI8Vj/1wsiR1CA1p3YPr/ZkihAefaD7g3LnjExa
         KwcuJGZQY/Bl4EXCrAzdg4oNaWbhjx1ruCJ/wEsoEyLhbIkKgkGFf/LVEAsUlWizCkhe
         ZBWQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775030446; x=1775635246;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=2y8dUPGFi+UBO55SBUip5Hfz6jHTFtt4ylYjmLjQEmw=;
        b=D7gr2TO5acScWyZWQJ6qw2vqXWK0Oa5gZDhpvvD5x8E5nQPVp2zy7ce/oein/iB5kX
         h34UWmIRkNCb/1g4tc15r8F5qhS3AcPx1SFqaYCiCytbgo9bxd+Ch1M86WI+XpRWgiSe
         ZxqlbXWS6Li3RERbGSa4BeyVrfICrcEnwXOBr578ul9PgtxpxlNDFBUrLxuYjBNu21Ra
         vrX18HSggLS0VNTh+JT9erimHyQdrCD/MnD3W7gi8LYAP/RQHa98A99Ncuw6XVLFjgTm
         rU8AXunGVjrYYGVkaRSy9MkI/uLt6WxDZVj3e22apGbJYx/8LrpL9OazIT4gypFgpuvc
         t7GA==
X-Forwarded-Encrypted: i=1; AJvYcCURF1U/CIxcDqxIRrtJHRaweFVkjxGGc8F3xsNU9fTE8QBHWMeXupeXnL6Yllzkw/PY0zmjylWMMqs=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz2VJuC3x2703KX/gbyvUrgcqX3YD/7FevEaJhoTuu5qTAZvgco
	7gMzR0Ydwl8atk8r/KT0+z/V7smUQbm/dhN+m3T3UyiG1ZVci6rFgw0p
X-Gm-Gg: ATEYQzyPYmtHrf3x+JutTiHUfvXnj588nAQ0kG7+th9H+MsK5eciMV5xL90llSZKXH0
	u2ta5ahTEH88ja/aakprWTrSw0wajLmwbdbSvQWlUQgBiTdxZFNTp6pi9iBYzKJXdi8b2ry91nV
	hlU/IKd+0Dv4SfgKMYzfLaGBzUZAQB4GCEX+ZQ6eGZI9dHsHWjjbkbyrIGRL6cBsN6d7n2OI+8U
	5egp2p0gcxzzPBRXK3S18FVR3F63MHfBkVo8cDyU8GAMcQyExA3fQRq41KoeEh9+BHvfm4J6pRQ
	y6UBivD4Qhw6zQIY6Vsre2M9qPQZtqY47UR9N1CSTWufj21ayuIAVXe7ZP2vn60QkQia7fk63VR
	5YpflwfhsqgKF0kfJniJYP7Zt7bAlb1Seym6PmBxxShhR9BkNoZDIm4PEh+0UxmdbM8Kxgzz3pu
	6SYsDjo9oNlu0LXpCi27ozcUuyrQKBkth/08RLW4sFMXUhNLuoSIDCPo9NIRNl+D90HlmUs9C9a
	tJnpBkAvGhs
X-Received: by 2002:a05:6a20:2592:b0:394:5513:ce5 with SMTP id adf61e73a8af0-39ef774ffadmr2721870637.51.1775030446152;
        Wed, 01 Apr 2026 01:00:46 -0700 (PDT)
Received: from SLSGDTSWING002.tail0ac356.ts.net ([129.126.109.177])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-82ca846e08dsm12865913b3a.24.2026.04.01.01.00.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 01 Apr 2026 01:00:45 -0700 (PDT)
From: Weiming Shi <bestswngs@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	Xiang Mei <xmei5@asu.edu>,
	Weiming Shi <bestswngs@gmail.com>
Subject: [PATCH net v2] ipvs: fix NULL deref in ip_vs_add_service error path
Date: Wed,  1 Apr 2026 15:58:01 +0800
Message-ID: <20260401075800.3344266-2-bestswngs@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When ip_vs_bind_scheduler() succeeds in ip_vs_add_service(), the local
variable sched is set to NULL.  If ip_vs_start_estimator() subsequently
fails, the out_err cleanup calls ip_vs_unbind_scheduler(svc, sched)
with sched == NULL.  ip_vs_unbind_scheduler() passes the cur_sched NULL
check (because svc->scheduler was set by the successful bind) but then
dereferences the NULL sched parameter at sched->done_service, causing a
kernel panic at offset 0x30 from NULL.

 Oops: general protection fault, probably for non-canonical address 0xdffffc0000000006: 0000 [#1] PREEMPT SMP KASAN NOPTI
 KASAN: null-ptr-deref in range [0x0000000000000030-0x0000000000000037]
 RIP: 0010:ip_vs_unbind_scheduler (net/netfilter/ipvs/ip_vs_sched.c:69)
 Call Trace:
  <TASK>
  ip_vs_add_service.isra.0 (net/netfilter/ipvs/ip_vs_ctl.c:1500)
  do_ip_vs_set_ctl (net/netfilter/ipvs/ip_vs_ctl.c:2809)
  nf_setsockopt (net/netfilter/nf_sockopt.c:102)
  ip_setsockopt (net/ipv4/ip_sockglue.c:1427)
  raw_setsockopt (net/ipv4/raw.c:850)
  do_sock_setsockopt (net/socket.c:2322)
  __sys_setsockopt (net/socket.c:2339)
  __x64_sys_setsockopt (net/socket.c:2350)
  do_syscall_64 (arch/x86/entry/syscall_64.c:94)
  entry_SYSCALL_64_after_hwframe (arch/x86/entry/entry_64.S:130)
  </TASK>

Fix by simply not clearing the local sched variable after a successful
bind.  ip_vs_unbind_scheduler() already detects whether a scheduler is
installed via svc->scheduler, and keeping sched non-NULL ensures the
error path passes the correct pointer to both ip_vs_unbind_scheduler()
and ip_vs_scheduler_put().

Fixes: 05f00505a89a ("ipvs: fix crash if scheduler is changed")
Reported-by: Xiang Mei <xmei5@asu.edu>
Signed-off-by: Weiming Shi <bestswngs@gmail.com>
---
v2: Remove "sched = NULL" instead of recovering it in out_err (Julian)

 net/netfilter/ipvs/ip_vs_ctl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 35642de2a0fee..2aaf50f52c8e8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1452,7 +1452,6 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		ret = ip_vs_bind_scheduler(svc, sched);
 		if (ret)
 			goto out_err;
-		sched = NULL;
 	}
 
 	ret = ip_vs_start_estimator(ipvs, &svc->stats);
-- 
2.43.0

