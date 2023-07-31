From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 06/14] sysctl: Add size to register_sysctl
Date: Mon, 31 Jul 2023 09:17:20 +0200
Message-ID: <20230731071728.3493794-7-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-22704-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787862; x=1691392662;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Jc/kMJ2DPFYVg7IBTR4njcXwjXlJ4l2BnySUNEp3oa4=;
        b=hJgIvldLZA0OhGFpk11i3Fjk/VJsj9CVT2ooNjiYKvtcHZqAqiDONo5VGSYD87a86L
         MPIA6zwApEoQ52sxaPBoXFj7HyegND2jDBUHzLOdUIiZyhfVsQT/r2dN70mLtWHegO74
         a+qt+vSg07/Xjo57Djls3PrxV4aFXk3C/myDIbvcjeoscDHMDnkUmtu9ZEqF2T5VWnkQ
         /bIwD+PmPzdzzLkvtyeedsU8FopQf9Ily6U/+VGKcIMZO97c66UjPVTRrK/Wh1HHu8tG
         4xz1rppsaeXkF/0rts/CIkaA30DkRr2Sk+rAs5M2wTVET++k1/m7A/URXDWimehHstFx
         7YNg==
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Jakub Kicinski <kuba@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, Joerg Reuter <jreuter@yaina.de>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsahern@kernel.org>, netfilter-devel@vger.ker

This commit adds table_size to register_sysctl in preparation for the
removal of the sentinel elements in the ctl_table arrays (last empty
markers). And though we do *not* remove any sentinels in this commit, we
set things up by either passing the table_size explicitly or using
ARRAY_SIZE on the ctl_table arrays.

We replace the register_syctl function with a macro that will add the
ARRAY_SIZE to the new register_sysctl_sz function. In this way the
callers that are already using an array of ctl_table structs do not
change. For the callers that pass a ctl_table array pointer, we pass the
table_size to register_sysctl_sz instead of the macro.

Signed-off-by: Joel Granados <j.granados@samsung.com>
Suggested-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/arm64/kernel/armv8_deprecated.c |  2 +-
 arch/s390/appldata/appldata_base.c   |  2 +-
 fs/proc/proc_sysctl.c                | 30 +++++++++++++++-------------
 include/linux/sysctl.h               | 10 ++++++++--
 kernel/ucount.c                      |  2 +-
 net/sysctl_net.c                     |  2 +-
 6 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/arch/arm64/kernel/armv8_deprecated.c b/arch/arm64/kernel/armv8_deprecated.c
index 1febd412b4d2..e459cfd33711 100644
--- a/arch/arm64/kernel/armv8_deprecated.c
+++ b/arch/arm64/kernel/armv8_deprecated.c
@@ -569,7 +569,7 @@ static void __init register_insn_emulation(struct insn_emulation *insn)
 		sysctl->extra2 = &insn->max;
 		sysctl->proc_handler = emulation_proc_handler;
 
-		register_sysctl("abi", sysctl);
+		register_sysctl_sz("abi", sysctl, 1);
 	}
 }
 
diff --git a/arch/s390/appldata/appldata_base.c b/arch/s390/appldata/appldata_base.c
index bbefe5e86bdf..3b0994625652 100644
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -365,7 +365,7 @@ int appldata_register_ops(struct appldata_ops *ops)
 	ops->ctl_table[0].proc_handler = appldata_generic_handler;
 	ops->ctl_table[0].data = ops;
 
-	ops->sysctl_header = register_sysctl(appldata_proc_name, ops->ctl_table);
+	ops->sysctl_header = register_sysctl_sz(appldata_proc_name, ops->ctl_table, 1);
 	if (!ops->sysctl_header)
 		goto out;
 	return 0;
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index b8dd78e344ff..80d3e2f61947 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -43,7 +43,7 @@ static struct ctl_table sysctl_mount_point[] = {
  */
 struct ctl_table_header *register_sysctl_mount_point(const char *path)
 {
-	return register_sysctl(path, sysctl_mount_point);
+	return register_sysctl_sz(path, sysctl_mount_point, 0);
 }
 EXPORT_SYMBOL(register_sysctl_mount_point);
 
@@ -1399,7 +1399,7 @@ struct ctl_table_header *__register_sysctl_table(
 }
 
 /**
- * register_sysctl - register a sysctl table
+ * register_sysctl_sz - register a sysctl table
  * @path: The path to the directory the sysctl table is in. If the path
  * 	doesn't exist we will create it for you.
  * @table: the table structure. The calller must ensure the life of the @table
@@ -1409,25 +1409,20 @@ struct ctl_table_header *__register_sysctl_table(
  * 	to call unregister_sysctl_table() and can instead use something like
  * 	register_sysctl_init() which does not care for the result of the syctl
  * 	registration.
+ * @table_size: The number of elements in table.
  *
  * Register a sysctl table. @table should be a filled in ctl_table
  * array. A completely 0 filled entry terminates the table.
  *
  * See __register_sysctl_table for more details.
  */
-struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table)
+struct ctl_table_header *register_sysctl_sz(const char *path, struct ctl_table *table,
+					    size_t table_size)
 {
-	int count = 0;
-	struct ctl_table *entry;
-	struct ctl_table_header t_hdr;
-
-	t_hdr.ctl_table = table;
-	list_for_each_table_entry(entry, (&t_hdr))
-		count++;
 	return __register_sysctl_table(&sysctl_table_root.default_set,
-					path, table, count);
+					path, table, table_size);
 }
-EXPORT_SYMBOL(register_sysctl);
+EXPORT_SYMBOL(register_sysctl_sz);
 
 /**
  * __register_sysctl_init() - register sysctl table to path
@@ -1452,10 +1447,17 @@ EXPORT_SYMBOL(register_sysctl);
 void __init __register_sysctl_init(const char *path, struct ctl_table *table,
 				 const char *table_name)
 {
-	struct ctl_table_header *hdr = register_sysctl(path, table);
+	int count = 0;
+	struct ctl_table *entry;
+	struct ctl_table_header t_hdr, *hdr;
+
+	t_hdr.ctl_table = table;
+	list_for_each_table_entry(entry, (&t_hdr))
+		count++;
+	hdr = register_sysctl_sz(path, table, count);
 
 	if (unlikely(!hdr)) {
-		pr_err("failed when register_sysctl %s to %s\n", table_name, path);
+		pr_err("failed when register_sysctl_sz %s to %s\n", table_name, path);
 		return;
 	}
 	kmemleak_not_leak(hdr);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 0495c858989f..b1168ae281c9 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -215,6 +215,9 @@ struct ctl_path {
 	const char *procname;
 };
 
+#define register_sysctl(path, table)	\
+	register_sysctl_sz(path, table, ARRAY_SIZE(table))
+
 #ifdef CONFIG_SYSCTL
 
 void proc_sys_poll_notify(struct ctl_table_poll *poll);
@@ -227,7 +230,8 @@ extern void retire_sysctl_set(struct ctl_table_set *set);
 struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_set *set,
 	const char *path, struct ctl_table *table, size_t table_size);
-struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table);
+struct ctl_table_header *register_sysctl_sz(const char *path, struct ctl_table *table,
+					    size_t table_size);
 void unregister_sysctl_table(struct ctl_table_header * table);
 
 extern int sysctl_init_bases(void);
@@ -262,7 +266,9 @@ static inline struct ctl_table_header *register_sysctl_mount_point(const char *p
 	return NULL;
 }
 
-static inline struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table)
+static inline struct ctl_table_header *register_sysctl_sz(const char *path,
+							  struct ctl_table *table,
+							  size_t table_size)
 {
 	return NULL;
 }
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 2b80264bb79f..4aa6166cb856 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -365,7 +365,7 @@ static __init int user_namespace_sysctl_init(void)
 	 * default set so that registrations in the child sets work
 	 * properly.
 	 */
-	user_header = register_sysctl("user", empty);
+	user_header = register_sysctl_sz("user", empty, 0);
 	kmemleak_ignore(user_header);
 	BUG_ON(!user_header);
 	BUG_ON(!setup_userns_sysctls(&init_user_ns));
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 8ee4b74bc009..d9cbbb51b143 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -101,7 +101,7 @@ __init int net_sysctl_init(void)
 	 * registering "/proc/sys/net" as an empty directory not in a
 	 * network namespace.
 	 */
-	net_header = register_sysctl("net", empty);
+	net_header = register_sysctl_sz("net", empty, 0);
 	if (!net_header)
 		goto out;
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
-- 
2.30.2


