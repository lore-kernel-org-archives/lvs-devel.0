Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56B494078CB;
	Wed, 19 Aug 2026 18:17:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163430; cv=none; b=XICzgv8ZVN6OeaQsVZqxLtv/LIGMCj6X0rwLkGI2yFJlGQBzy1ou5p7VHEM9yT9xYgpaeetP9xo2UHpqNpl5+JVyBtnx/wM/7OUH9L6c58tRp0pgYAksTtKXt7r6m+8K9GVl5heTdkr2CB1RtDUkyitZMm6pzDS47RzG1PjqWpw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163430; c=relaxed/simple;
	bh=ODFaAlYjAIKhqtF7rrOMrwhagt8MEmMADJR+9fzON34=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=b7sZu/prF5xD5yLmXMB1d2Rw620QDZpitemFl7G1tlOtNoaX7KhJL1Re2UT1D/FMBTJoFrhYYpy/vs3rgubEy6k6X6XLde7emYlnjWl0f2jnN3OAW2bYOwi2Odsc/2byByybH99rZ2a5CXO7OB13N6qgfCI2muotQWJMm+cNCRs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=AfLsSoBT; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="AfLsSoBT"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=47xAFsvg306prpgVajo74hEldqY7N4ca2VW9wdN3GaU=; b=AfLsSoBTiH5F9ZSQRAuAXOY1fp
	bb0y3sYHYFgwyVE6oEAVALFM3R21RF1jwvNv0UbRizwinPs4PkbEA5Rwkx0SFbcYbFbgb45B8Nzmz
	/3rOV3BebiA2wdR8Pl7X9CtORxSnoQiycjNEWBt2c4r2W4kmZ75rQPKk+CJLpai4v9s1afAAGD8nU
	oUO/5t+8EtcAglBFC75PabhKO74r0T6Ja5AveNM6odcKjOovuoslzTOHtsK66tGS52ArovowVe+Vm
	YQjbA+FgflQbpRMbn/6ufY5Scz8/w+WYVUq1cSDUtubabcsEQEF9rzRHM5xPmZEw87jFoyBWwoSK2
	+N2sZ4aQ==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkqY-006ENH-QS; Wed, 19 Aug 2026 20:17:07 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:24 -0300
Subject: [PATCH RFC v3 11/13] sysctl: unrandomize struct ctl_table.procname
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-11-aab90569365d@igalia.com>
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

The 'struct ctl_table.procname' field (sysctl filename) cannot be accessed
by scripts since it is defined in kernel headers (see "don't include kernel
headers into userspace" in file2alias.c) and its offset may be randomized.

Unrandomize '.procname' as the first field so its offset is always zero and
match the 'struct ctl_table' symbol address, which can be found by scripts.

Originally-by: Mauricio Faria de Oliveira <mfo@canonical.com>
Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 include/linux/sysctl.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index b808fbc1d964f453db8e354825fd8800db1eecd3..ccc77bb918614b1de1e44fbef70471c85fb55c09 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -220,7 +220,14 @@ static inline void *proc_sys_poll_event(struct ctl_table_poll *poll)
 
 /* A sysctl table is an array of struct ctl_table: */
 struct ctl_table {
+
+	/* This must be the first field for module aliases (file2alias.c) */
 	const char *procname;		/* Text ID for /proc/sys */
+
+#ifdef CONFIG_SYSCTL_MODULE_ALIASES
+	/* This begins the randomizable portion of the struct. */
+	randomized_struct_fields_start
+#endif
 	void *data;
 	int maxlen;
 	umode_t mode;
@@ -228,7 +235,14 @@ struct ctl_table {
 	struct ctl_table_poll *poll;
 	void *extra1;
 	void *extra2;
+#ifdef CONFIG_SYSCTL_MODULE_ALIASES
+	/* New fields go above here, so they are in the randomized portion. */
+	randomized_struct_fields_end
+};
+static_assert(offsetof(const struct ctl_table, procname) == 0);
+#else
 } __randomize_layout;
+#endif
 
 struct ctl_node {
 	struct rb_node node;

-- 
2.47.3

