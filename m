Received: from mail-dy2-f42.google.com (mail-dy2-f42.google.com [74.125.229.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BB583559F8
	for <lvs-devel@vger.kernel.org>; Sun, 27 Sep 2026 06:24:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790490293; cv=none; b=CSYJV6moKtMV99AzDX6RrBylNnVhFaYSSOZ10f0F4glBY68JxE6RS8nBCJwiDhPKptdjXzLEYeSHN0aUWUKFUoI9OPjEvqZVOvR3hYP4ugon4zO9ig8F9ti4rdUGWqwQpyZ/xe8w1nztrJ16N9MRv8Yaj4x/MPxO/fnGwuRuzqo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790490293; c=relaxed/simple;
	bh=eT/fj5vZ0Sj0xWvtck5u0p9IG2kOT0o4JMJn6zf0/qU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=m9hK88DVae2+sj0kye/LnAPC1PibT+GFnODdQ1OQwEati2KPMqTFmMCUm+9LYdJg2pxD3zMxIoMuruJDsS/opAU9a0s9WCBqofWZ0lV5g7qfD5m0BJb5eZ/yUAxvJzN9epOvrFVLPwERLSGrbX+rXFnNXg0BiRsuZKJSpOa21n8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FBqWKevv; arc=none smtp.client-ip=74.125.229.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FBqWKevv"
Received: by mail-dy2-f42.google.com with SMTP id 5a478bee46e88-343241d5d34so47256eec.1
        for <lvs-devel@vger.kernel.org>; Sat, 26 Sep 2026 23:24:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790490291; x=1791095091; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=9lvIFmMP4hhC0qEm4iuvni2Axxi7Wmdx8mVA3p2P2mI=;
        b=FBqWKevvtUd2QdrC97qdrqzsBIb61h0S1+7pNq9x7edXsNUKxvnvhoOusCjDhLUPmz
         AAW8nV4hay+UuN/6Pcw0fABgsGacFzX44OoeXxvPHRnEbJRcVu8UyphbwqBjhhgJ9/R7
         mqeQ2CfV4tB9DWQwuN1DSmwnNVx25CBDwhU39r4qUP4BzGC1jjT/bkfIK4qJ3pN0eCXL
         CoLFnO2wxnuPtfiqPgEkcl0R4KFvEOKFcTxEnVUsHUwUdndlSVNTInYuWptdN+kwE/hN
         ZjrAFr4vFrHywWVWVht1vs6M3Lj/xE9wZkVPq3g6xAIGMLZ9JM6m6FHpMn10X53Ba2SZ
         C05Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790490291; x=1791095091;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9lvIFmMP4hhC0qEm4iuvni2Axxi7Wmdx8mVA3p2P2mI=;
        b=kOl4giILZkk5krV8To+P3xPlJ1syYXPsLucMEWHdnLHqw2E3uQcczCHqe7Zbzo/GGQ
         HfOsSgKRrqQ2gttAUxTX8OrWWQLv7sBPlA5qCxwjmh9/oUsbpV+ITV8pPUChTF0MkBSn
         4kVHgpJqtJYpkulCI9vFYAVAAxqpAGny7fz7gv1NOG++U68xp454nNAO1xpV2zG/Uveu
         GNL4ie/y5vdA/tu3girxd+fv2FULhaPcMXD6zginmSHyAfo1GEecq28PSpFop4yjmaWd
         i3LFx2DfdgUve8BQgZRvwv8mHc1HrgdstsF9soqyvkWQQQGtByS+65JkUwtRHxbrZV3x
         fEQg==
X-Forwarded-Encrypted: i=1; AKwUvByIotb8hpHNU9t0AC0g2XpxI1qLbAcawB2kStAT2eOuuoOHiSNPqSl8RekHp400RhBIklB02zuqcyw=@vger.kernel.org
X-Gm-Message-State: AFq9FYKfkmsrs3dF7S48vsd28ReEtM1VE7mdOgYikfSDTwBaLIxfqm8d
	KRpCQ+lt0w4+oYyWCorgJZE8MF2Z1NecW6ayahkTzOnO0+qAH8vy5liE0oOloEI9CdycEA==
X-Gm-Gg: AYBFou2KxFW/JYROH1P7tYK5hoJXIheEshXKGgAU3zVzYI9CPSmAPUUYPoQCbr/ogKx
	NXNtWwroscypgNrYtXYJGu39YH1oImNt1nDXx6tYKIo8CE61ws1oUIh66BfvrnDsYw7YYTQO53j
	iQIF9jr4dtt+XA71mesBZc6eqgSufkKKpCT2fycP/tNh6ywkyMYms2Lhd6XSnQrhnIZmwPOmK3v
	wTgnQX38lQdteUINxYX/Vo5tK/giqo33qQhOPy0A4zq8fSkkxjqzuuxFZOiruot7SYkNiT6ZUj8
	toKs26uSO7KDjc1EOhnbYvBUUQeX/Ljg9qgCHikqCwDxpRf9zPE3beXkJecZSfMCB0PQRpPHp7y
	6zAZFVI69pmcq0Vs0W1fdCGVDLypQdtSadUsh1mAJyQf12Hr6A5LJPm85MMSZLrj/ZvFA7Bfu/K
	lJ3GW1jfJ54z5WmTkmsPH8LfYEGTb83D9uR8Iz9hu72Xz4uxlFrLYKq7J/5GErgUUxJYcvLltKL
	YNaQcbeQ5+x6jcT+z618kB0ZzLDH/PFfzftpedCqFf2np0TQveAo9H4yDQiwi2+M1mgYnM2n6Xi
	NUMk
X-Received: by 2002:a05:7300:f64b:b0:33e:4e49:d08d with SMTP id 5a478bee46e88-34272b4bc81mr8484339eec.1.1790490291342;
        Sat, 26 Sep 2026 23:24:51 -0700 (PDT)
Received: from localhost.localdomain (95.169.12.199.16clouds.com. [95.169.12.199])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3413fc2413dsm19056291eec.0.2026.09.26.23.24.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 23:24:50 -0700 (PDT)
From: Chengfeng Ye <nicoyip.dev@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Chengfeng Ye <nicoyip.dev@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH net] ipvs: fix protocol data lifetime during namespace teardown
Date: Sun, 27 Sep 2026 14:24:35 +0800
Message-ID: <20260927062435.3690129-1-nicoyip.dev@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

IPVS frees its per-net protocol data before control cleanup cancels
defense work and unregisters the sysctl table. A defense worker can load
a protocol data pointer, then namespace cleanup can unlink and free that
object before the worker dereferences pd->pp or pd->next. The worker's
securetcp_lock does not serialize with protocol cleanup. A concurrent
defense-mode sysctl write can reach the same timeout update path.

KASAN reported:

  BUG: KASAN: slab-use-after-free in ip_vs_protocol_timeout_change
  Workqueue: events_long defense_work_handler
  Call Trace:
   ip_vs_protocol_timeout_change+0x1b4/0x1e0
   update_defense_level+0x63e/0xd80
   defense_work_handler+0x1e/0xc0
  Allocated by task 125:
   ip_vs_protocol_net_init+0xda/0x2f0
   __ip_vs_init+0x16b/0x240
   setup_net+0xfc/0x310
  Freed by task 12:
   ip_vs_protocol_net_cleanup+0x1d6/0x2e0
   __ip_vs_cleanup_batch+0x7d/0x100
   cleanup_net+0x38c/0x770

Run control cleanup before protocol cleanup so that defense work and
active sysctl handlers have finished before their protocol data is freed.
Initialize protocols before exposing the control interface, and unwind
in reverse order, to enforce the same lifetime on initialization failure.
Protocol initialization and exit do not depend on control state.

Fixes: 9330419d9aa4 ("IPVS: netns, use ip_vs_proto_data as param.")
Cc: stable@vger.kernel.org
Signed-off-by: Chengfeng Ye <nicoyip.dev@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd503f0efb57..8a3c880fdb26 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2502,12 +2502,12 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_estimator_net_init(ipvs) < 0)
 		goto estimator_fail;
 
-	if (ip_vs_control_net_init(ipvs) < 0)
-		goto control_fail;
-
 	if (ip_vs_protocol_net_init(ipvs) < 0)
 		goto protocol_fail;
 
+	if (ip_vs_control_net_init(ipvs) < 0)
+		goto control_fail;
+
 	if (ip_vs_app_net_init(ipvs) < 0)
 		goto app_fail;
 
@@ -2527,10 +2527,10 @@ static int __net_init __ip_vs_init(struct net *net)
 conn_fail:
 	ip_vs_app_net_cleanup(ipvs);
 app_fail:
-	ip_vs_protocol_net_cleanup(ipvs);
-protocol_fail:
 	ip_vs_control_net_cleanup(ipvs);
 control_fail:
+	ip_vs_protocol_net_cleanup(ipvs);
+protocol_fail:
 	ip_vs_estimator_net_cleanup(ipvs);
 estimator_fail:
 	net->ipvs = NULL;
@@ -2547,8 +2547,8 @@ static void __net_exit __ip_vs_cleanup_batch(struct list_head *net_list)
 		ipvs = net_ipvs(net);
 		ip_vs_conn_net_cleanup(ipvs);
 		ip_vs_app_net_cleanup(ipvs);
-		ip_vs_protocol_net_cleanup(ipvs);
 		ip_vs_control_net_cleanup(ipvs);
+		ip_vs_protocol_net_cleanup(ipvs);
 		ip_vs_estimator_net_cleanup(ipvs);
 		IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
 		net->ipvs = NULL;
-- 
2.43.0

