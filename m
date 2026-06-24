Received: from sender-op-o17.zoho.eu (sender-op-o17.zoho.eu [136.143.169.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27BA2331EBB;
	Wed, 24 Jun 2026 18:41:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=136.143.169.17
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782326519; cv=pass; b=G6mdDKoet04G3WgTPS2iwJItWgsslkLKRvjGLaORd5p51adbs2A3cPs9dyDVpGAlnZtuzeJNvc+4RwzrPdGyZFYCHdBQfXb/R2JYf6Gfit4JBOqyP+DK8JCwLy3cgyN1+WiSUjZfyowCbiw7BLspE7x1xxEnsnRczvzfYAO5O1Q=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782326519; c=relaxed/simple;
	bh=qyVHdsMmvca5GvJEKqj1S7WjNbbBOdiR10TgZhkoRqM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tTQ8pAr8guPJ3+PVbwJ2KCR2obJunQyosoitOlnbivyAvPN3xGgVCDKgZnd6I/3y7kDn8tHGNPHFc9bdB67lQ0HZZC1oTZ2p/xuqbE8RiUzAjtIi4WT+vqnGC99dl5gVz6MZ4UtWUptW161ZThb9jDv37lwEIo4ImqjQ7IgQ4uY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me; spf=pass smtp.mailfrom=carlosgrillet.me; dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b=PnOVtkZt; arc=pass smtp.client-ip=136.143.169.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=carlosgrillet.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=carlosgrillet.me header.i=carlos@carlosgrillet.me header.b="PnOVtkZt"
ARC-Seal: i=1; a=rsa-sha256; t=1782326473; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=hPijog/HoFtEwCAqXy7bRsQ8bOLKH+OcHPgmaHcTfnPF7FN8q890Coz3JmTWiTo5UgKOOaFN5PbK+0cJWbfoH0aexnlu6ILK6RZ35VUU1m+75FXFUx7F49MZon83RXNSJEV98EhBxxbKliwYWg8tf15a1GcPPArAE3YJPN8twWw=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1782326473; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:In-Reply-To:MIME-Version:Message-ID:References:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=Fgtcgs/n/4lVtcfTx2hoAICPdf54HOIwDkFYTERLlnI=; 
	b=Lq45nHoDMxV3QOhGFToOUYhh0YJdrYCjDljr1C3Y3J6UkpnDctyJ22fzxtyfihJPT0XnICIrWSO06t70ACZYCDfgf4wNbu4sCFZpU2iW+CeJxeAnq+y18JPLz/+I+PFGWGNEayYc+TJLA1VBMzEZmJgMV4zXuiHjHTCc1Yl+O2w=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=carlosgrillet.me;
	spf=pass  smtp.mailfrom=carlos@carlosgrillet.me;
	dmarc=pass header.from=<carlos@carlosgrillet.me>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; t=1782326473;
	s=zmail; d=carlosgrillet.me; i=carlos@carlosgrillet.me;
	h=From:From:To:To:Cc:Cc:Subject:Subject:Date:Date:Message-ID:In-Reply-To:References:MIME-Version:Content-Transfer-Encoding:Message-Id:Reply-To;
	bh=Fgtcgs/n/4lVtcfTx2hoAICPdf54HOIwDkFYTERLlnI=;
	b=PnOVtkZt/pjKi/JReoem7A9133cbSsJ1Fhwo/nv+vQMk4KeXSap2tVY/R6Yn6LYb
	bkB0iwM1SEmSpLMfciYgKfKBZIny7Eg23/S5g5oTNdJTn6wPoFaTBqYTqKUTvUzlS8c
	wTaI2sAY68fK5pD9oiFruuH7xus+QN5039oWZLvQ=
Received: by mx.zoho.eu with SMTPS id 1782326472233543.8798641031913;
	Wed, 24 Jun 2026 20:41:12 +0200 (CEST)
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
Subject: [PATCH nf-next 4/4] netfilter: ip_vs_nfct: replace u_int8_t with u8
Date: Wed, 24 Jun 2026 20:40:34 +0200
Message-ID: <20260624184036.71051-5-carlos@carlosgrillet.me>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260624184036.71051-1-carlos@carlosgrillet.me>
References: <20260624184036.71051-1-carlos@carlosgrillet.me>
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

