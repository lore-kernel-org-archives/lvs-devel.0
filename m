Received: from sender-op-o17.zoho.eu (sender-op-o17.zoho.eu [136.143.169.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D9B53EB0F0;
	Thu, 25 Jun 2026 17:26:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.17
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782408417; cv=pass; b=s4l8ZoGkB9urABpoqxoooVsCg8DIXj8eGtbbrESULybtatWz+oIvRcR75sEUEpcBGBaNgvb3WGjDoyP5yrrl1R/iEq+9HnIErT0LPkwYbbfG0BQ/5YAJK6R2yBaq6801LLdkzPvtpPj3cKhcA6EQitCiaw+k19E9ePCvK5jBT+k=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782408417; c=relaxed/simple;
	bh=qyVHdsMmvca5GvJEKqj1S7WjNbbBOdiR10TgZhkoRqM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Rd6yU5xh39JdCL8hLmXrR9CGz+l37kJw0sZKNDrpbmi6q2I3Il5b6bRkyphZcG3hv8xM//NrtWOKnV2FMQ2Fs2oCgyFvpiD9+YWRuZAL1u3GcKDMZQTYheY0QS5htL697LdYv3NPM/hn2P3jabHK/cw6ob1AGiNWYeNyQf1FRWQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me; spf=pass smtp.mailfrom=carlosgrillet.me; dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b=OzjvGITH; arc=pass smtp.client-ip=136.143.169.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b="OzjvGITH"
ARC-Seal: i=1; a=rsa-sha256; t=1782408377; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=YQs3O2tfWuLu4BqQ3WfGv5cvjQssOjucsmRkE35O6qCnR3lWQ8Ggw2J2wRCUZut79jQp+NQO6EVdO96Qzx0aOTj7RC1w86ZSHiykh/JSUpxZkXkUudC91qzH02TM7h0OJz+4dHRB07xXiCSH3f0QwDMoFDWiNc4gSOH01KfiK/I=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1782408377; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:In-Reply-To:MIME-Version:Message-ID:References:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=Fgtcgs/n/4lVtcfTx2hoAICPdf54HOIwDkFYTERLlnI=; 
	b=ONpLIiY2GC8zJtrVxRGiJWauRn7EWpRkd1ONe5sKjAtLe0FRrWw3+kkJzmsaRyN0aJv3ymY3bJ17hEWr3QA0dC/YNAm9+eF1Vip3GB0WrrB6RbyEq8o9fNFJkOv0jn5JNcmOwzR4avncOmVjAqQs3pfyRmkPwHNnT43FJQmOEog=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=carlosgrillet.me;
	spf=pass  smtp.mailfrom=carlos@carlosgrillet.me;
	dmarc=pass header.from=<carlos@carlosgrillet.me>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1782408377;
	s=zmail; d=carlosgrillet.me; i=carlos@carlosgrillet.me;
	h=From:From:To:To:Cc:Cc:Subject:Subject:Date:Date:Message-ID:In-Reply-To:References:MIME-Version:Content-Transfer-Encoding:Message-Id:Reply-To;
	bh=Fgtcgs/n/4lVtcfTx2hoAICPdf54HOIwDkFYTERLlnI=;
	b=OzjvGITH9JhJ87iUGAQpSOP+qNMcnKp2P0d2Ey9RGn7wg10RoiaQCltfMvy9CJ12
	oJFM+MTvrJP8hXhHfwm5dJ+s0+UePaW8mGuukNAUBvHKWit4IFqVaPUVYZdVj4oHXfz
	jE+ykRHvSp64IbBcjOmkZ/XLS9J75OyifOefD7Tg=
Received: by mx.zoho.eu with SMTPS id 1782408375291515.214453547314;
	Thu, 25 Jun 2026 19:26:15 +0200 (CEST)
From: Carlos Grillet <carlos@carlosgrillet.me>
To: David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
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
Subject: [PATCH nf-next v2 3/3] netfilter: ip_vs_nfct: replace u_int8_t with u8
Date: Thu, 25 Jun 2026 19:25:48 +0200
Message-ID: <20260625172550.35781-4-carlos@carlosgrillet.me>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260625172550.35781-1-carlos@carlosgrillet.me>
References: <20260625172550.35781-1-carlos@carlosgrillet.me>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

Use preferred kernel integer type u8 instead of the POSIX u_int8_t
variant and update header to match definition.

No functional change.

Signed-off-by: Carlos Grillet <carlos@carlosgrillet.me>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_nfct.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 49297fec448a..ed2e9bc1bb4e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -2123,7 +2123,7 @@ void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
 			    int outin);
 int ip_vs_confirm_conntrack(struct sk_buff *skb);
 void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
-			       struct ip_vs_conn *cp, u_int8_t proto,
+			       struct ip_vs_conn *cp, u8 proto,
 			       const __be16 port, int from_rs);
 void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp);
 
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 81974f69e5bb..347185fd0c8c 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -208,7 +208,7 @@ static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
  * Use port 0 to expect connection from any port.
  */
 void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
-			       struct ip_vs_conn *cp, u_int8_t proto,
+			       struct ip_vs_conn *cp, u8 proto,
 			       const __be16 port, int from_rs)
 {
 	struct nf_conntrack_expect *exp;
-- 
2.54.0

