Received: from sender-op-o17.zoho.eu (sender-op-o17.zoho.eu [136.143.169.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A01B5369204
	for <lvs-devel@vger.kernel.org>; Wed, 24 Jun 2026 18:42:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.17
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782326528; cv=pass; b=D8UajtajrWYo7e04SI+YwsYzbAXf856ZPZomGhuwJbUa4ziPCDNG+WlZot3DXUz05bs056YWpOcd2Q+fcKAXxm+txTXsxF/ADYTK+NPBMBoRLbXTQo6Q4QSX8CMGWtsM+UVxfxMWN+Zac70et5qB8AIKn2g+rj5LO4cFztJbo9Q=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782326528; c=relaxed/simple;
	bh=IkQsTtpNf5O8v6teUrL9vw29Pt8sEnlFUc9uGuBtbXk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=n0Zxov/SJ/0nEEVZXT/ZCvyEhbM0fsJbcP1WiVtXx5jTerMn8v0j8f3SROO7vr4AexgZ8b/7L/bPzyKB4HqOqJD5FLdsI/bp2EOtivq5KoLiLsoS6GqUQpce9N+xyWHQGwc2M781yytl752o2DKJ1tf1GwjkdKS3OuLrgCbwD5U=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me; spf=pass smtp.mailfrom=carlosgrillet.me; dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b=fZYk/96p; arc=pass smtp.client-ip=136.143.169.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b="fZYk/96p"
ARC-Seal: i=1; a=rsa-sha256; t=1782326465; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=X9SYeuu16TSyQRPsN/alANO7/n+yOqQZCqLp9jT44wyyJ3dZyaeaCEKeLOWrr2ZLu0tMKyCOBhkYksAlIMYi5Rxlb6plqIXpmrkD1inLNljSDmLtTlBc4EH+swA/MkZtRLDkNoQ6+Q59NsReTrm/OLifSfvl63fXJSuka9dE9R0=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1782326465; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=N9PyBqyjrYTdl1NJmQEata3xoHGmh+KLI2s/D41VKiI=; 
	b=Q128i4nqxxMV2rfJecspTNId5oAQ9PDMzdefje4s5Ii99mdqbI8TC6YNhxSsMiZlqRy1t/gsIlj2qA5Knu/1ydt8s8P70IZQzDVkidDIaMeJZMUD4TG+boE525mYaEDYvqiYRBdbrImDuCcCWF/yGjM/FwE1BuO3Nt1hR1w4gfE=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=carlosgrillet.me;
	spf=pass  smtp.mailfrom=carlos@carlosgrillet.me;
	dmarc=pass header.from=<carlos@carlosgrillet.me>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1782326465;
	s=zmail; d=carlosgrillet.me; i=carlos@carlosgrillet.me;
	h=From:From:To:To:Cc:Cc:Subject:Subject:Date:Date:Message-ID:MIME-Version:Content-Transfer-Encoding:Message-Id:Reply-To;
	bh=N9PyBqyjrYTdl1NJmQEata3xoHGmh+KLI2s/D41VKiI=;
	b=fZYk/96pH5kZJoPf2V9RR3NxqL//UlfEjzozI3OWmFiKnyq+7rpOuwXjgX3/sGoZ
	nmaqV7/zQ8HTEQ+5Y6hejne6maTfW9iOhnmytFov3iKWPp/bP6lubPX8Es/JgwoPR5u
	sL4a4H5zq81jPgPUys7VCZB89AVfWd87T1iWW7Gw=
Received: by mx.zoho.eu with SMTPS id 1782326463388745.8448071704419;
	Wed, 24 Jun 2026 20:41:03 +0200 (CEST)
From: Carlos Grillet <carlos@carlosgrillet.me>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH nf-next 0/4] netfilter: replace u_int*_t with kernel int types (batch 2)
Date: Wed, 24 Jun 2026 20:40:30 +0200
Message-ID: <20260624184036.71051-1-carlos@carlosgrillet.me>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

This patch series replaces POSIX u_int8_t/u_int16_t with the preferred
kernel types u8/u16 across several netfilter files and updates the
corresponding header definitions.

This continues the work started in:
https://lore.kernel.org/all/20260616182948.96865-1-carlos@carlosgrillet.me

No functional changes.

Carlos Grillet (4):
  netfilter: nf_conntrack_sane: replace u_int16_t with u16
  netfilter: nf_conntrack_h323_main: replace u_int8_t with u8
  netfilter: nf_conntrack_amanda: replace u_int16_t with u16
  netfilter: ip_vs_nfct: replace u_int8_t with u8

 include/net/ip_vs.h                    | 2 +-
 net/netfilter/ipvs/ip_vs_nfct.c        | 2 +-
 net/netfilter/nf_conntrack_amanda.c    | 2 +-
 net/netfilter/nf_conntrack_h323_main.c | 2 +-
 net/netfilter/nf_conntrack_sane.c      | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

-- 
2.54.0

