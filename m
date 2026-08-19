Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C681948EBF3;
	Wed, 19 Aug 2026 18:16:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163379; cv=none; b=gJdGUEwrLNySLPSUkJoyi8sSJuCSnF1fcjTjK2yFACL8ceilJKPvRL1+lMJh0QUc+LAsVF4wKR2S2qtCWO0s6Q0D/Fie3X6TJQHUcFuXawXiOPBvN1k5rpP+e4Ej99pgh6f3McNw1+eNeUvq+iMPkFWpA8huzkeRm5/KNHMZPfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163379; c=relaxed/simple;
	bh=RxzO2M6rN+H/ytlw4MDw0CINZz2xTYppSZUTyip3o2Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Ifk2SZtncxuqwPNF/TeB0MHHqbbFfeeH+tq6NewXV3LYIXgHHJTTxoonoYO7lITkvSqmRL5GBrqCrOwFPAGb4BzrHqPhnycor1Oi3p6RaJSN7S6nZRGFm1M34T3EhuFJlfSN11oeEzcOcHA1tNSOpVTlqHmj8V1E8rHREZqzyLc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=GHUD+eSq; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="GHUD+eSq"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=AtbmO4sa1oP/x2/XURayQU2LL3evZi0sG28P1WYB6lk=; b=GHUD+eSqTJFBG8gtCXuG49kvMx
	4GJsACyzrHb3fWzJJY7y/D/5eq6nn/U3ZNu1Tka3B1PBHsDGsI2GaD0szzqcJ6iMMGqF8i5AgbjNj
	tHleJ9w365Klk2yMAkuKzctw3WNTGzFMmCq0lvQNIURqsg8QEVE/j+wxXw7peByZjQX0Sblp8Dr1R
	FmC/5GyNzCe7I6ZyPBx0xJeUmQjYZa/F3e6Zfn1mzVtaxLkonUNTYkDedCjGdhzQwZMUBVasfL2c7
	C+prvWhkaEltCrnJ71Wo9H/CDjBVL047v+PgaYl29id1EUcy6Cb4GFfF1gvK0oqXI7Jctx49iqChA
	3RpNymkg==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkpd-006ENH-64; Wed, 19 Aug 2026 20:16:09 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:16 -0300
Subject: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
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

The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table variable
with pointers to a sysctl table's path and entries, and table/entry sizes.

That symbol will be handled by file2alias.c (modpost) with the changes in
mod_devicetable.h and devicetable-offsets.c.

The option macros MODULE_SYSCTL_TABLE_{DISABLE,UNIQUE_ID} can be used on
a per-file basis to disable the macro and change the symbol name pattern.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 include/linux/mod_devicetable.h   |  7 +++++++
 include/linux/sysctl.h            | 42 +++++++++++++++++++++++++++++++++++++++
 scripts/mod/devicetable-offsets.c |  6 ++++++
 3 files changed, 55 insertions(+)

diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index a397213bedace6e81ac600691b3b50ae0f88356b..818a4a53448dba2088e3dbd1ef2c2d4dbb190fcc 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -78,4 +78,11 @@ struct cpu_feature {
 	__u16	feature;
 };
 
+struct module_sysctl_table {
+	kernel_ulong_t path;
+	kernel_ulong_t table;
+	__u16 table_size;
+	__u16 entry_size;
+};
+
 #endif /* LINUX_MOD_DEVICETABLE_H */
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index e5d7226ab6f5af34a33829883ad5d1b405e19c86..0adc056ff54d895500c376361fe966bfa5126a3e 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -293,6 +293,48 @@ struct ctl_table_root {
 	int (*permissions)(struct ctl_table_header *head, const struct ctl_table *table);
 };
 
+/*
+ * Creates a symbol so file2alias.c can find the sysctl table.
+ *
+ * MODULE_SYSCTL_TABLE() is the sysctl equivalent of MODULE_DEVICE_TABLE(),
+ * with pointers to a sysctl table's path and entries, and table/entry sizes.
+ *
+ * The parameters 'path' and 'table' must be static (e.g., string literal or
+ * static char[]; static struct ctl_table[]) as both are used as initializer
+ * elements for a static struct variable.
+ *
+ * The generated symbol name contains 'table' by default. However, if 'table'
+ * is a struct field (contains '.' or '->'), in order to avoid syntax errors,
+ * define the macro SYSCTL_MODULE_ALIASES_UNIQUE_ID.
+ *
+ * Define the macro SYSCTL_MODULE_ALIASES_DISABLE to disable this.
+ */
+#if defined(CONFIG_SYSCTL_MODULE_ALIASES) && defined(MODULE) &&			\
+    !defined(SYSCTL_MODULE_ALIASES_DISABLE)
+
+#include <linux/module.h>
+#include <linux/mod_devicetable.h>
+
+#if defined(SYSCTL_MODULE_ALIASES_UNIQUE_ID)
+#define __MODULE_SYSCTL_TABLE_NAME(table)					\
+	__mod_device_table(sysctl, __UNIQUE_ID(sysctl))
+#else
+#define __MODULE_SYSCTL_TABLE_NAME(table)					\
+	__mod_device_table(sysctl, table)
+#endif
+
+#define MODULE_SYSCTL_TABLE(path, table)					\
+	static struct module_sysctl_table __used				\
+		__MODULE_SYSCTL_TABLE_NAME(table) = {				\
+			(kernel_ulong_t) path,					\
+			(kernel_ulong_t) table,					\
+			(u16) sizeof(table) + __must_be_array(table),		\
+			(u16) sizeof(const struct ctl_table)			\
+		}
+#else
+#define MODULE_SYSCTL_TABLE(path, table)
+#endif
+
 #define register_sysctl(path, table)	\
 	register_sysctl_sz(path, table, ARRAY_SIZE(table))
 
diff --git a/scripts/mod/devicetable-offsets.c b/scripts/mod/devicetable-offsets.c
index b4178c42d08f50dfaba4d50d5c1d48b8aff88db4..e3b8855e6ebcf8d16f486f71d62900584ee884b1 100644
--- a/scripts/mod/devicetable-offsets.c
+++ b/scripts/mod/devicetable-offsets.c
@@ -284,5 +284,11 @@ int main(void)
 	DEVID(coreboot_device_id);
 	DEVID_FIELD(coreboot_device_id, tag);
 
+	DEVID(module_sysctl_table);
+	DEVID_FIELD(module_sysctl_table, path);
+	DEVID_FIELD(module_sysctl_table, table);
+	DEVID_FIELD(module_sysctl_table, table_size);
+	DEVID_FIELD(module_sysctl_table, entry_size);
+
 	return 0;
 }

-- 
2.47.3

