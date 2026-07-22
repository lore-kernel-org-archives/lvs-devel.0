Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 108CC40F722;
	Wed, 22 Jul 2026 10:25:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784715958; cv=none; b=nQIUJSjcnfcaHdpMp0kYS148UlLqoVvKKqWbgVOoSuza3YAYojjwZ7w8+O1jDtA05cWLjmaIAYOgig/ISVSFnH95IPL276By4bFaJQ18bPYBcREzIlMAjObOwNGhjCeCzAZIJxwawg48vo1yJlLlcOYbfp2mGgF42Va1OFv4D/A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784715958; c=relaxed/simple;
	bh=7ATIv4lt7/4UUpYOgKJicT4WUBgft7ynUSm2w/G8uAI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Kyz16QvTLAFci3PLSRGarBhgpGoxhLPwnJbwcuWTpHt3oFG3Dfc2koMyWQAIs3GhiFagChcHKbsyF9CM6dkdQ/p+Bue7/4rIPDq4bNvnKS8bs9whOHSnpbviY75RzeCXB2zigMyg+ZColTr97VAUYt99TbcAu9Wa9unB8SgLFqY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=SC7cZpzn; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="SC7cZpzn"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5A3902188A;
	Wed, 22 Jul 2026 13:25:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=Xuf4cMxo
	66h6jzSi/wuhYPLzQRlqJmUKDuMOkf6sb2k=; b=SC7cZpzn/kpotQGrPQLHogHk
	j9Dei1yJtDhZ1soR/ufWIY+Dtw3LYRAPuzlq+22RJBuAbUkZBjLRaE6K+k3EvgLN
	c+xgjklx8oMaeOtOca0bfCE+R5JZPcAhdnbJAtD5DLiP2lAXsqBVfCOlzB0xvh23
	FYYd2S9ktVqW22HU7wYL5NU9NCozPVXz4T/4cc5Uc7zh+7uWiYCW6FrTiq0PAPw4
	JjbiqKxnbsCh9voQz75wT0JP1PoHApCNqF/hfdL+2NENsYneZNRHXbe5uST7I169
	bYEM+ktTcfKtvJJ3p1WHtMZENKxPIrqvm0Uh0NVUTrZmkCcAbP3K8Oj0ya715MqV
	nKVzd7cvhTLFi2O2zKAkSwh2cjWbTTvfL2L7U+oYrNLLVKCzWJuA7e3Bj6MZI+8K
	DAPxoiAkaz0pmsojgKQmrKdx6n9INi5BPD4F9zvb4A78Qg+9kwPuWIwdNIgGyM44
	GxpTLEmCYuw50MSEWjaTXj1JEfKgs1vhdtDQdF08UhSPJD8IcVmS72OEpinUbDIL
	Ip1vLw0+6aIgC9+BHuDHwwpx4mW54HRLEJzL/Yo8nOglN91Fq9QqHoTpAHWPIzCD
	tmfcd17Hj7YjvcnnlhAz3n5spvD3UFAb7atoGp4hXPSAMk+cHN5a87Wi/7x25/KF
	RHEYY/Y7u2bLa0ONHCM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Jul 2026 13:25:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6F5C460400;
	Wed, 22 Jul 2026 13:25:53 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66MAPqp0037554;
	Wed, 22 Jul 2026 13:25:52 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66MAPqFv037553;
	Wed, 22 Jul 2026 13:25:52 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: clear the nfct flag under lock
Date: Wed, 22 Jul 2026 13:25:39 +0300
Message-ID: <20260722102539.37539-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that cp->flags should be changed under cp->lock

Fixes: 35dfb013149f ("ipvs: queue delayed work to expire no destination connections if expire_nodest_conn=1")
Fixes: f0a5e4d7a594 ("ipvs: allow connection reuse for unconfirmed conntrack")
Link: https://sashiko.dev/#/patchset/CALMqdkR704S2BG_QD_bgHTFp2%2B1QCi7n0T4zoZyTo8mDZevYSA%40mail.gmail.com
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7efa209a517b..6b79e0c4d9e2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2194,8 +2194,11 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		}
 
 		if (resched) {
-			if (!old_ct)
+			if (!old_ct) {
+				spin_lock_bh(&cp->lock);
 				cp->flags &= ~IP_VS_CONN_F_NFCT;
+				spin_unlock_bh(&cp->lock);
+			}
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
@@ -2211,8 +2214,11 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (sysctl_expire_nodest_conn(ipvs)) {
 			bool old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
 
-			if (!old_ct)
+			if (!old_ct) {
+				spin_lock_bh(&cp->lock);
 				cp->flags &= ~IP_VS_CONN_F_NFCT;
+				spin_unlock_bh(&cp->lock);
+			}
 
 			ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
-- 
2.55.0


