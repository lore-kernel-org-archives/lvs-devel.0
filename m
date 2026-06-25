Received: from sender-op-o17.zoho.eu (sender-op-o17.zoho.eu [136.143.169.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02E253E639E;
	Thu, 25 Jun 2026 17:27:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.17
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782408423; cv=pass; b=AbzEWQB1Dqd7lmQbuYafxR/NBBzN8gO58ljp0fGyM2dMuJa83uD4JzJaH1ASIngf/X+MeCQ1uA94oG6qC90ta87h1x6BjUcA1coFPnZHUvHk9/a/n35JtVBeLwqFY/s93MVaXu9E0ol4lSARm+XDAZpsSsNi91+FXKZtIjZCogk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782408423; c=relaxed/simple;
	bh=Ug0eG1VVaEp7nO7BUGyBVoG5qvI6yMGXn3rxqnFoWAQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bSZ2bkTNQaH6onRMTacJBE9cV29NfpHaFBTjnikG6oV/HSPCD9yTUmf+mvNBqNjJMSR8KWWmTLvWyYhRUawmOJXnCZK3yig/PqTjcyVmjJ91ZSJY9LFbEoI0woGAy3Ujs1ohrdVdgjMbQn4LcEQ5qM+HXLMNlpYAWLTEtgjmXos=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me; spf=pass smtp.mailfrom=carlosgrillet.me; dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b=TIxArBBx; arc=pass smtp.client-ip=136.143.169.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b="TIxArBBx"
ARC-Seal: i=1; a=rsa-sha256; t=1782408371; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=RvTsikr34kprXvmqimSC8UmvW6vKymAppxhUFh3jkL8+zjv7MM/9XDOy/uy1sdWhsSpoljVjPHSSNADCIY7zsNNa61KusbiV3qLKk6FRC7m0idHciFqfOumZLo0YTb9p+xB/o6lMyS52cQBLvTmsSstmVU6u6i3wvNvDknqrl08=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1782408371; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=nqlBUO6e+NBSYVxKJwIybFo1EvvTPef5DEWLeoUqZdc=; 
	b=gIISjy2RQ0pMJv02ZMlfl/KYSyCK2IX+lVFqESuPhWNzfhsMZ+dFwAwnoBujs37vPNGF5hPOVY37fFP8Q9wjh6NLfN7S/Jr1rDVReb7oOmsh0SSNzfqxLkqktgJ1zrsy8V4gBEgRjUtISj06S4HoABz7Ze2+efaQWmCYXhX+hvE=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=carlosgrillet.me;
	spf=pass  smtp.mailfrom=carlos@carlosgrillet.me;
	dmarc=pass header.from=<carlos@carlosgrillet.me>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1782408371;
	s=zmail; d=carlosgrillet.me; i=carlos@carlosgrillet.me;
	h=From:From:To:To:Cc:Cc:Subject:Subject:Date:Date:Message-ID:MIME-Version:Content-Transfer-Encoding:Message-Id:Reply-To;
	bh=nqlBUO6e+NBSYVxKJwIybFo1EvvTPef5DEWLeoUqZdc=;
	b=TIxArBBx9JXpTit9AogkxsZY5uX2EpZtMVD6TMJV1RDn+eWk698dCpq50r1SQ9Pk
	2r0YTE2SOPw0Nd/e6rXgghtEdSTi10xOnsUsWsq1CwybnEhCq/tjqEAQsRN33BI/A4O
	tYYV02zRQVWVc4Sdm0i43HSPEnLLaIaRsz2cmXtI=
Received: by mx.zoho.eu with SMTPS id 178240836812329.259167655362717;
	Thu, 25 Jun 2026 19:26:08 +0200 (CEST)
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
Subject: [PATCH nf-next v2 0/3] netfilter: replace u_int*_t with kernel int types (batch 2)
Date: Thu, 25 Jun 2026 19:25:45 +0200
Message-ID: <20260625172550.35781-1-carlos@carlosgrillet.me>
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

Changes in v2:
- Drop nf_conntrack_sane patch (Florian Westphal: ports[] removal pending)
- link to v1: https://lore.kernel.org/all/20260624184036.71051-1-carlos@carlosgrillet.me

Carlos Grillet (3):
  netfilter: nf_conntrack_h323_main: replace u_int8_t with u8
  netfilter: nf_conntrack_amanda: replace u_int16_t with u16
  netfilter: ip_vs_nfct: replace u_int8_t with u8

 include/net/ip_vs.h                    | 2 +-
 net/netfilter/ipvs/ip_vs_nfct.c        | 2 +-
 net/netfilter/nf_conntrack_amanda.c    | 2 +-
 net/netfilter/nf_conntrack_h323_main.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

-- 
2.54.0

