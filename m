Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EFCA3BADA9;
	Wed, 19 Aug 2026 02:29:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106576; cv=none; b=rhegZn/lCDOgcoDl4DZ8kdjQq/kPx8g7rgNlMhY7URw5MGDzrYj+C4UMd7L2o3JxvArFniGx4ep1BmRNTHvk178IaPmCv9or2nK98gAherTibR65RvO5cevEMYmZyG0Oi29Oh53r7z99uPKSdl2QFqJ+y4CbAilBh30/1hwPh28=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106576; c=relaxed/simple;
	bh=O9XYwa7yAn4nrumcNR9l1To+tQ/PPu/6nFL/o0V1g4o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=r3EIBVLYUgMqb2X7fOTRg9W8uPJarAG72YrfdF0daousWKubox01B98S5d9PXvJY0oHJb13HqRI7+UlDHq0jdhcwim9ZkG1UaByTQhgmHH02zPWW6vU2QwU5wSA9hUKf+0RKoW+0OpRj1NhgOTlBVqvNwczLJHKTIo/7WPbdcoM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=WFIwbDwf; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="WFIwbDwf"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=iJ7zO28rhwgh2iY91IivmtIIfG4kkjgiEZp5znqK2CA=; b=WFIwbDwfSLMv+t0GggmUXvUkEL
	fuMxSplCr1E6k93B/pmfgDEy4kbcB/VwZew72gwidfjH4bfXp60x2CZgCB43b5Iro41RTRfygfMby
	fDoIzwDySLE2qe+I47Ehydz1nCwXKOHYuMQGHzyjafQ8ynkvluTPmW/cuI3RUfZLARxft0hPIuF40
	M0tfotxNDpG4MGwan8WPum4E5hI4malrjFvopubnaQp5dsyrDq3AX5XbWPA6yKb/lPNT/pE0rxVcD
	ytr80BMMm/tcOJcV5QbkPaXOfzjg5IGFUvklPVraNO20IUILLisOFVGi4PLaWxKteOzkqfsdu8sq8
	9PbEVRuQ==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW3U-005tfG-Cs; Wed, 19 Aug 2026 04:29:28 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:03 -0300
Subject: [PATCH RFC v2 04/13] sysctl: add register_sysctl() wrapper for
 MODULE_SYSCTL_TABLE
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-4-d5a69dae5798@igalia.com>
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

Add a MODULE_SYSCTL_TABLE call into register_sysctl() for existing callers
to automatically use it.

Add optional 'template arguments' to support a dynamic table/path defined
at run-time based on a 'template' table/path available at build-time.

Split the update of callers with template arguments into another commit for
clarity, disabling them for now.

Note: there is no register_sysctl_sz() wrapper, as it is used in even more
dynamic cases (e.g., table generated at run-time not based on a template).

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 drivers/parport/procfs.c |  2 ++
 include/linux/sysctl.h   | 54 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 3880460e67f25a7d8708a734c6f4d9e6c363c726..cda3221e386ed7a4afc898b3d0313081dee5b49b 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -13,6 +13,8 @@
  * Cleaned up include files - Russell King <linux@arm.uk.linux.org>
  */
 
+#define SYSCTL_MODULE_ALIASES_DISABLE
+
 #include <linux/string.h>
 #include <linux/init.h>
 #include <linux/module.h>
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 6960fe22c50bfd8a9acc79870e494c2775fa040a..7e05fafd5544e1c4a3283dc13b0692f39515d01e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -335,8 +335,58 @@ struct ctl_table_root {
 #define MODULE_SYSCTL_TABLE(path, table)
 #endif
 
-#define register_sysctl(path, table)	\
-	register_sysctl_sz(path, table, ARRAY_SIZE(table))
+/*
+ * The register_sysctl() wrapper for the MODULE_SYSCTL_TABLE macro
+ * automatically creates symbols in sysctl table registration sites.
+ *
+ * Usage:
+ * - register_sysctl(path, table);
+ * - register_sysctl(path, table, table_tmpl);
+ * - register_sysctl(path, table, table_tmpl, path_tmpl);
+ *
+ * The optional 'template arguments' ('table_tmpl' and 'path_tmpl')
+ * can support callers with non-static variables: dynamic table/path
+ * defined at run-time based on a 'template' available at build-time.
+ *
+ * For example, a sysctl table, or table and path, which is/are:
+ *
+ * - per-namespace: different tables based on a template table
+ *   (i.e., same files in each namespace) with identical path
+ *   (i.e., same path in each namespace).
+ *
+ * - per-device: different tables based on a template table
+ *   (i.e., same files for each device) with different paths
+ *   (i.e., diff paths for each device) based on a template path.
+ *
+ * The wrapper passes the build-time parameters (templates) to the macro
+ * and the dynamic/run-time parameters (instances) to the wrapped function.
+ *
+ * The wrapper reduces to the wrapped function when either the macro or the
+ * config option is disabled.
+ */
+#define _register_sysctl(path, table, table_tmpl, path_tmpl)			\
+({										\
+	MODULE_SYSCTL_TABLE(path_tmpl, table_tmpl);				\
+	register_sysctl_sz(path, table, ARRAY_SIZE(table));			\
+})
+
+#define register_sysctl(path, table, tmpl_args...)				\
+	_register_sysctl(path, table,						\
+			 __sysctl_table_tmpl_or_default(table, ## tmpl_args),	\
+			 __sysctl_path_tmpl_or_default(path, ## tmpl_args))	\
+
+/* Helper macros for optional template arguments */
+#define __sysctl_table_tmpl(skip, table_tmpl, ...)				\
+	table_tmpl
+
+#define __sysctl_path_tmpl(skip, table_tmpl, path_tmpl, ...)			\
+	path_tmpl
+
+#define __sysctl_table_tmpl_or_default(default, tmpl_args...)			\
+	__sysctl_table_tmpl(, ## tmpl_args, default)
+
+#define __sysctl_path_tmpl_or_default(default, tmpl_args...)			\
+	__sysctl_path_tmpl(, ## tmpl_args, default, default)
 
 #ifdef CONFIG_SYSCTL
 

-- 
2.47.3

