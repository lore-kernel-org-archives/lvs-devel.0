Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C3344A2E27;
	Wed, 19 Aug 2026 18:17:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163424; cv=none; b=u4Y9ekpDAoS1VM1RlnnCHif4HLz0g9F3GqfEay35hSPmWRXBkKOiVETK1CObO5BGtP37HfzQejRfVAXI4jkW1Ti6T+jV8XyqIAjV8KrE+GCuh52EZQ7YydJYt/m+wFaGN9UKb9oKBZKo4BH7rskTkbSjm+3THMrvAp4HZVit+u0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163424; c=relaxed/simple;
	bh=vFnsgdfm+Ez1FVcoXh/WpI0AqAZzytkPHB4D3sXGHrY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=TES5unrZLTpcYjGpFO+sstEJN4iJEvlRg5elSnaG6yv7M2kJXWMyZeSYjplH/bkQP7+p2sXSRWzEb677ZVRSGo943Mx0oC+a+YXQ9TxzvPNCdVnitxSQeJGkNMko9B+Wx2y4Bo+/fmuUhyjoIMmoZM+qyriZ3z5GVc1gN5gdSBw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=lYzkzf1N; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="lYzkzf1N"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=tQqqNi/yFOJx7LxHx0ugW5QhRFDQCKpFVzx/5PXbrcs=; b=lYzkzf1NaKmAELu1yafK3W+x+V
	oGdrM9zBjAFWyqADLV6q58FDgLa4N219iK9fDvirIdC8ydA2VwVGS9zgacLmIbHxVDRHAe5TMHYLX
	VBTQROh7W10FE7EQz7noq9hTrlsn2tOYtJi6OpYPnuHx8NVeeepTMv6uLNdVMRnAiv2ahKzFbtv7d
	uTuIgLQhMnoH4USfXP/vGV3qvU/heEOAfGXqmluLU7H0THUvhXRbVxPQB5Tx/S1SjPzu5sN6qivET
	0ZEGng167tVdBnv8wP8WHH9uv0XzNxyZjveSnpe15MZZhi90rufObQunqfUnPnDiz4++88ZzVCEGR
	Qfdd3kfg==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkqR-006ENH-Jd; Wed, 19 Aug 2026 20:16:59 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:23 -0300
Subject: [PATCH RFC v3 10/13] sysctl, net: update register_net_sysctl_sz()
 edge case
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-10-aab90569365d@igalia.com>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
In-Reply-To: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
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
index 7241dbf7eb81ce9f906e33645d03944671c5e6f1..b808fbc1d964f453db8e354825fd8800db1eecd3 100644
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

