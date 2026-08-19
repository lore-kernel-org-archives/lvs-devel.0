Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D63F35F5E4;
	Wed, 19 Aug 2026 02:29:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106587; cv=none; b=tQQ4JIbn1ZDCrcbSDE+UCDu8GEuBepsGeHs1nwG4bq3k4L8EC3iqULbl6HLUMcjCzbqFuPuSFq4AfDNvNxkMISoTX6Cdg1GxfV5mZgBATh4+FWNZRRLQ5R1DwUL3NTmJ+mAZoaqLfVUPWLfuhj2DhYsXDsztFfZ2ZMIM3UtYAXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106587; c=relaxed/simple;
	bh=iZwaJ3oD8KyUeg6N+UUPwC38Zx2YF2Ev+VgEDruYIo4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=cbGPBOmUsQI2th3PZokwgVK2fUi5Sy5Gbi34c1KMhiXNeptK1mtzHgbDAueJH0gomG7aHkJ/NyjIsWPhniuHrTnQmkNjegV8eoMmUOXp12DdU9zFjJp79hhUS7bq0bykjbmO6Ab4ulxPCTvBb3g3zf2+XqAYKzdQC99jM9GyFeU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=F02TB5U6; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="F02TB5U6"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=H3/V/omVPqP4Gcds9KJ2/iTD0AqO6b8ovtPsauoO5pw=; b=F02TB5U6Jtdvw9GjI/DlMJdVA6
	WgdZESCP0ESz8mcgfH2cBSxq1QLo66nufXCxAbTgYXq7Jw0xA2PXJ13tZw79sVkb0687Nbxf1oXfG
	nb1PeNKdOrGkgUeJjSgurgLoLonvot5NVK7zAVdcjA+1z8o6F5ObHclXoAV59OLFvhiCnp4Lz5SW/
	DTKEzrYhnGOp3/wc2hUvsyE0Ax/J8d58ENGeNhxlara+KhUqn9SeHJ69+os0/kk+n/euedei5caij
	RuaDPuRWYjtxmF4zAZTKu9tbDL5t0qOBirnjurvu084nDJmi4BWstyzBB+PQ+XtqsSiqcmU6wGcln
	GkkVegIg==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW3i-005tfG-JG; Wed, 19 Aug 2026 04:29:42 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:05 -0300
Subject: [PATCH RFC v2 06/13] sysctl, net: add register_net_sysctl{_sz}()
 wrappers for MODULE_SYSCTL_TABLE
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-6-d5a69dae5798@igalia.com>
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

Add a MODULE_SYSCTL_TABLE call into register_net_sysctl{_sz}() for existing
callers to automatically use it.

Add optional 'template arguments' to support a dynamic table/path defined
at run-time based on a 'template' available at build-time.

Split the update of callers with template arguments into separate commits,
disabling the macro for now.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 include/linux/sysctl.h      |  3 +++
 include/net/net_namespace.h | 45 ++++++++++++++++++++++++++++++++++++++++-----
 net/sysctl_net.c            | 10 +++++-----
 3 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 7e05fafd5544e1c4a3283dc13b0692f39515d01e..9e00a086ff1d47ab18021b3d79b0e8a93037cb2d 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -309,6 +309,9 @@ struct ctl_table_root {
  *
  * Define the macro SYSCTL_MODULE_ALIASES_DISABLE to disable this.
  */
+
+#define SYSCTL_MODULE_ALIASES_DISABLE
+
 #if defined(CONFIG_SYSCTL_MODULE_ALIASES) && defined(MODULE) &&			\
     !defined(SYSCTL_MODULE_ALIASES_DISABLE)
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index e5ee673b9fcf846aefcc309d4cca1a8fc870aae2..2127049c71cedade45922d7f0d3b7a3ce0af67e0 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -520,13 +520,48 @@ void unregister_pernet_device(struct pernet_operations *);
 
 struct ctl_table;
 
-#define register_net_sysctl(net, path, table)	\
-	register_net_sysctl_sz(net, path, table, ARRAY_SIZE(table))
+/*
+ * The register_net_sysctl{_sz}() wrappers for MODULE_SYSCTL_TABLE
+ * automatically create symbols in sysctl registration sites.
+ *
+ * See register_sysctl() and MODULE_SYSCTL_TABLE() in <linux/sysctl.h>
+ * for information about template arguments and options for the macro.
+ *
+ * Usage:
+ * - register_net_sysctl(net, path, table);
+ * - register_net_sysctl(net, path, table, table_tmpl);
+ * - register_net_sysctl(net, path, table, table_tmpl, path_tmpl);
+ * - register_net_sysctl_sz(net, path, table, size);
+ * - register_net_sysctl_sz(net, path, table, size, table_tmpl);
+ * - register_net_sysctl_sz(net, path, table, size, table_tmpl, path_tmpl);
+ */
+#define _register_net_sysctl_sz(net, path, table, size, table_tmpl, path_tmpl)	\
+({										\
+	MODULE_SYSCTL_TABLE(path_tmpl, table_tmpl);				\
+	__register_net_sysctl_sz(net, path, table, size);			\
+})
+
+#define register_net_sysctl_sz(net, path, table, size, tmpl_args...)		\
+	_register_net_sysctl_sz(net, path, table, size,				\
+				__sysctl_table_tmpl_or_default(table,		\
+							       ## tmpl_args),	\
+				__sysctl_path_tmpl_or_default(path,		\
+							      ## tmpl_args))
+#define register_net_sysctl(net, path, table, tmpl_args...)			\
+	register_net_sysctl_sz(net, path, table,				\
+			       __sysctl_table_array_size(table, ## tmpl_args),	\
+			       ## tmpl_args)
+
+/* Helper macro for optional template arguments */
+#define __sysctl_table_array_size(table, tmpl_args...)	\
+	ARRAY_SIZE(__sysctl_table_tmpl_or_default(table, ## tmpl_args))
+
 #ifdef CONFIG_SYSCTL
 int net_sysctl_init(void);
-struct ctl_table_header *register_net_sysctl_sz(struct net *net, const char *path,
-						const struct ctl_table *table,
-						size_t table_size);
+struct ctl_table_header *__register_net_sysctl_sz(struct net *net,
+						  const char *path,
+						  const struct ctl_table *table,
+						  size_t table_size);
 void unregister_net_sysctl_table(struct ctl_table_header *header);
 #else
 static inline int net_sysctl_init(void) { return 0; }
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index e190a639eef2f6929c4aed85ad625aaf8a6ebd6a..e003210e0917760b707dae1e738c50d7c3969deb 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -160,10 +160,10 @@ static int ensure_safe_net_sysctl(struct net *net, const char *path,
 	return 0;
 }
 
-struct ctl_table_header *register_net_sysctl_sz(struct net *net,
-						const char *path,
-						const struct ctl_table *table,
-						size_t table_size)
+struct ctl_table_header *__register_net_sysctl_sz(struct net *net,
+						  const char *path,
+						  const struct ctl_table *table,
+						  size_t table_size)
 {
 	if (!net_eq(net, &init_net))
 		if (ensure_safe_net_sysctl(net, path, table, table_size))
@@ -171,7 +171,7 @@ struct ctl_table_header *register_net_sysctl_sz(struct net *net,
 
 	return __register_sysctl_table(&net->sysctls, path, table, table_size);
 }
-EXPORT_SYMBOL_GPL(register_net_sysctl_sz);
+EXPORT_SYMBOL_GPL(__register_net_sysctl_sz);
 
 void unregister_net_sysctl_table(struct ctl_table_header *header)
 {

-- 
2.47.3

