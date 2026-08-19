Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A524481B1;
	Wed, 19 Aug 2026 02:30:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106622; cv=none; b=I303VjCtYg2oUbEJDqPt8NgnUetX6pWcdfDNSB2IDNiNu5uTFznym6Isi6j7nwl8xUDi6F7SniVrrZes4d/GxzLTNIeqNJB0ovmVCgMj1jqiP9y+2ZMc90vCkQD2BabiS1HFVefmqahp3VB/VIZ+SumzlFMofQ5wl/aHJWZKy+8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106622; c=relaxed/simple;
	bh=WnJK16aZlJCfl4caW7N9hPaZqf5/RToHwGPjPgIoN7A=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IU0Co4Cp6z95FoDHKKttbqJC1awIyCGjU/mCHOKF22jJhA4lwulnegKF8E8X8LmJJsUOk0C5VAytqCW7+ShEziBF63AhjiLn/h5uFqecuDFCi1X0goK5YZ0nDItb0c9L6rRloKjahPTACyGNBbozRdtZOyzPWG8s+1pT1/dt7t4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=BEOtuYvk; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="BEOtuYvk"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=jcWdQbXP/kHWb1xcpo26FcJ2qHm9uH6N5DjjZNrZnS8=; b=BEOtuYvkZx34qtwPCbyxsdAsY6
	wt1vEcZkneUIRDRvOjlvxWGKMLwGz4LB5AulnRi+hi2VF/YgQJMigWj0G6OcRTrnRRPIc+u6lHxVh
	99019UvHalg7deeX6cY5LcGi0gXIBYrLkTjmdTrJYnpVZT9fHkcr9vwcCQC2P5RHnhEyleMv/iMRE
	0b5a0cSslBLc+6mj05KF9pvvh0jLjS6JdJY9ktYVFg09l74rRgKv9MJ3cLq153lIfP3dnq0tPLyfe
	T/8v3hIBd+X+5ToJ4s7UaHrOB4QhkU3y7ZFvMM++E59w9yj7Vl+gJa2tbVAEv9aYQeGp+IdxQEzSj
	5vaLg+wQ==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW4I-005tfG-44; Wed, 19 Aug 2026 04:30:18 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:10 -0300
Subject: [PATCH RFC v2 11/13] sysctl: unrandomize struct ctl_table.procname
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-11-d5a69dae5798@igalia.com>
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
index 7e05fafd5544e1c4a3283dc13b0692f39515d01e..120c0f05bd083e08d8104ff05136138f2e8cdb07 100644
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

