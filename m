Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 501A43BBA0F;
	Wed, 19 Aug 2026 02:30:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106615; cv=none; b=Q+qyLUm8ibMhT9a+PZTGFqG/u4yfxYfZQgwpVuPNx9CDDf7/P9EQRMA2avnVyiJd43dAjanvx87T1m7dAdZA1j0c4NlbPmggGqP1ohatyWWmCRI8jUytsOxF7YXbLgWofTkSMzQNcX/pNmO8sN+nMLYUuSBHdoQUZI0maD8ghfI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106615; c=relaxed/simple;
	bh=8ufdlGQoDs+51tVl3N2x5MnJ7S98wl7FolVU0AHZNNA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oKbZM/ZNb8ZTgzsZR3HAdpp1ZtjYHE8o9iC4OAmur2uWdAKSre51icF2ytlgItGp9ce/9veD/4NcWLMt9KRJec65dWFSVTPF+sqRylxfGIN1ZZOKn2BUuQ87rZJccGhmsVyZqE71DrCiMaPvMc/NoJtstY/WzMoyaDl6+Mk1iW4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=GNwOgvD1; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="GNwOgvD1"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=IuE38fL6h7PEmzt/UNWdPfgVu72Lk4CiXzTD+qO+pWo=; b=GNwOgvD1AZmUImC0F5BHb4J4CH
	J4W97Eo0NkLvb5hoXYMflby0Bjo1H2wBsJFdmKWDTh869qriEPgapAimR58yHbMEIt8eAU8WIdMFD
	Beq0RuAkALqd6jSDkwAmeC9JafZ037OIGKKfczG4HnQqy0lP8dLDffdZ9n7Ooc+wmWeKZF7rdicud
	keGSVF7hEkO2GLVq7tToxxmSj/Aq6vkBYY4UvPxBmpZTbjlyekrRFJC5axfOKE3VLoF40QnFI31Aq
	nvlFuRiaeB/SLm0R1MVCeEVWlvSFEW6CkHiRr7MqI+ah6buGMEfc6jhXXFHXKHmiWazlZai3FLQ77
	Pr1VBPQg==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW4B-005tfG-0q; Wed, 19 Aug 2026 04:30:11 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:09 -0300
Subject: [PATCH RFC v2 10/13] sysctl, net: update register_net_sysctl_sz()
 edge case
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-10-d5a69dae5798@igalia.com>
References: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
In-Reply-To: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
To: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>, 
 Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>
Cc: kernel-dev@igalia.com, linux-riscv@lists.infradead.org, 
 linux-kernel@vger.kernel.org, fsverity@lists.linux.dev, 
 keyrings@vger.kernel.org, bpf@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org, 
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org, 
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 coreteam@netfilter.org, linux-sctp@vger.kernel.org, 
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, 
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com, 
 virtualization@lists.linux.dev, Mauricio Faria de Oliveira <mfo@igalia.com>
X-Mailer: b4 0.14.2

Handle the last (edge) case:
- nf_log.c: ignore sysctl table with template set at run-time.

And re-enable the macro.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 include/linux/sysctl.h | 3 ---
 net/netfilter/nf_log.c | 9 +++++----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 9e00a086ff1d47ab18021b3d79b0e8a93037cb2d..7e05fafd5544e1c4a3283dc13b0692f39515d01e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -309,9 +309,6 @@ struct ctl_table_root {
  *
  * Define the macro SYSCTL_MODULE_ALIASES_DISABLE to disable this.
  */
-
-#define SYSCTL_MODULE_ALIASES_DISABLE
-
 #if defined(CONFIG_SYSCTL_MODULE_ALIASES) && defined(MODULE) &&			\
     !defined(SYSCTL_MODULE_ALIASES_DISABLE)
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index f4d80654dfe6ab6abd886e224f400e4444bcd29b..ed4a5a6b8d95b82676397f6747ef5d988c9060ea 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -518,10 +518,11 @@ static int netfilter_log_sysctl_init(struct net *net)
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 		table[i].extra2 = net;
 
-	net->nf.nf_log_dir_header = register_net_sysctl_sz(net,
-							   "net/netfilter/nf_log",
-							   table,
-							   ARRAY_SIZE(nf_log_sysctl_table));
+	/* MODULE_SYSCTL_TABLE(): template table's .procname set at run-time. */
+	net->nf.nf_log_dir_header = __register_net_sysctl_sz(net,
+							     "net/netfilter/nf_log",
+							     table,
+							     ARRAY_SIZE(nf_log_sysctl_table));
 	if (!net->nf.nf_log_dir_header)
 		goto err_reg;
 

-- 
2.47.3

