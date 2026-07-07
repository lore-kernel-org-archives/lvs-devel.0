Received: from sender-op-o17.zoho.eu (sender-op-o17.zoho.eu [136.143.169.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCE023BE644;
	Tue,  7 Jul 2026 19:52:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.17
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783453948; cv=pass; b=R2nSUy4AhrG9zjwAyoKo5qtjKvPGb1K1K3g1z0NCrrQuJ9FEzgPtedUw2ocum8s2LP5kSeIdqniUqPSS2TUowXJyQcVoOry/qaJH4rm7Nh1P8S5DQ0cdWbpJ6mdawSuwTFWGu7mC+X2+hz6KH8lghpdzNdcLoYQ8xRJ32iFdTgI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783453948; c=relaxed/simple;
	bh=mQwXGZluo0e/rOz6em/H3KPFLAzljDc4xuigN/YjoWw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ZD6u84doNbiRr9EjibsomyPzAVNzR3u4Bhrxy9jVE0hnTVzkTHNIsdVhDHaaNhvFyhiwgi8EEXeJYJ9lucJuMjgDuwy1wHKjedvOFnIHLPpeEqxwB540TTyZiiWPWaYmvwWy1o+Rvr7KI6ErlwpRU8Kbk0zs+kFGm/EFvClFKKc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me; spf=pass smtp.mailfrom=carlosgrillet.me; dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b=B3AP22/A; arc=pass smtp.client-ip=136.143.169.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b="B3AP22/A"
ARC-Seal: i=1; a=rsa-sha256; t=1783453886; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=IjjF0DTdO5cT/dT4SLrpDA5Ha/QFyV6hnjlStruEB7YvmxcVMD4BtjdmfYK4nYFM+TR9GjBYZU55CJYFBoIZz+1YjpkCSQhuDcGusl6Oe0mFau9pakYkKC1dVtjJ9ToMmHyNkvVpufxpqXKWf4ePGaMdvGY/k8guTIf0eD6LOyM=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1783453886; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=STRIjG+QS7Hua/lM7GQwd7GhTYTw8rS7AqdX4cPkG5c=; 
	b=PIATY/mDGl5RLpR1f8XcNe+M3m7esmNdRG81VOpTs1y1hV4WupWwkXAqqKOSVbw12T8MCdShtgvZ1j0sNtn/MBxOBEqT3aVNHgfyFJA2/inXyEBTgWpFrgjEHJ+rxcd0y3TlRqgkF5KRIzpm9+w9q6qrMxUm6KQy4TA7Jvkm6i8=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=carlosgrillet.me;
	spf=pass  smtp.mailfrom=carlos@carlosgrillet.me;
	dmarc=pass header.from=<carlos@carlosgrillet.me>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1783453886;
	s=zmail; d=carlosgrillet.me; i=carlos@carlosgrillet.me;
	h=From:From:To:To:Cc:Cc:Subject:Subject:Date:Date:Message-ID:MIME-Version:Content-Transfer-Encoding:Message-Id:Reply-To;
	bh=STRIjG+QS7Hua/lM7GQwd7GhTYTw8rS7AqdX4cPkG5c=;
	b=B3AP22/AFfWxaHJ0cB1oVTAJPcduG315s9f4zWFILYkkwyJFVZkKJDGvH6T2DEku
	Smoi8UWvP8wneB2SPhODmXCqVI6fogHQjq1b0fYBf5RxaeB127tVn55CjJZwP+k2Z1k
	Z7PQnrqEvyMZ2CKRaPeIXkNzG+zjwDbvc+T1KfK4=
Received: by mx.zoho.eu with SMTPS id 1783453883610391.61290214611824;
	Tue, 7 Jul 2026 21:51:23 +0200 (CEST)
From: Carlos Grillet <carlos@carlosgrillet.me>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
Subject: [PATCH nf-next 0/4] netfilter: replace u_int*_t with kernel int types (batch 3)
Date: Tue,  7 Jul 2026 21:51:05 +0200
Message-ID: <20260707195111.34899-1-carlos@carlosgrillet.me>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

This patch series replaces POSIX u_int8_t/u_int16_t/u_int32_t with the
preferred kernel types u8/u16/u32 across several netfilter files and
updates the corresponding header definition.

This continues the work started in:
https://lore.kernel.org/all/20260616182948.96865-1-carlos@carlosgrillet.me

No functional changes.

Carlos Grillet (4):
  netfilter: ip_vs_core: replace u_int32_t with u32
  netfilter: nf_conntrack_sip: replace u_int16_t with u16
  netfilter: nf_nat_amanda: replace u_int16_t with u16
  netfilter: nfnetlink_osf: replace u_int8_t with u8

 include/linux/netfilter/nfnetlink_osf.h | 2 +-
 net/netfilter/ipvs/ip_vs_core.c         | 2 +-
 net/netfilter/nf_conntrack_sip.c        | 2 +-
 net/netfilter/nf_nat_amanda.c           | 2 +-
 net/netfilter/nfnetlink_osf.c           | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

-- 
2.55.0

