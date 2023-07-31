From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 05/14] sysctl: Add a size arg to __register_sysctl_table
Date: Mon, 31 Jul 2023 09:17:19 +0200
Message-ID: <20230731071728.3493794-6-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-22703-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787859; x=1691392659;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=n8WLnI9NId3N3IQiFQMWfeeUSr/hiuHAn49PsdG5OBk=;
        b=fWz9AGo64wf2+C7stN9V8xlGYS4jyeYSZJ8G3McUGqYEoWgaOcr/WYoGJihB+IvgQ5
         zrRoDN05ZS7sjdNjgtlwTbetshiZpgTJJzbo7fHFXy8P5FCMpFcb/qq1fhRMp1Dcp/8/
         bEj8fLGxqRjff8cDAgkwGM6/8C9vS+E0cDa9Jo7NjzXABkw20TB993m6EW77S36Glnd0
         UCsvpAt9lMm1yb6xwJPs6QIDyVGtp7uXiEwKVBNw5mL6QaXZlYiUhcAjjqpe+Fx7wnuj
         pDlLRmjux6hHckW7kFTIEsvv95a4EAIzWQDHsgnOdky9tbq3MZlsxOKxJPjVBTrTaZpj
         b9nw==
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Jakub Kicinski <kuba@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, Joerg Reuter <jreuter@yaina.de>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsahern@kernel.org>, netfilter-devel@vger.ker

We make these changes in order to prepare __register_sysctl_table and
its callers for when we remove the sentinel element (empty element at
the end of ctl_table arrays). We don't actually remove any sentinels in
this commit, but we *do* make sure to use ARRAY_SIZE so the table_size
is available when the removal occurs.

We add a table_size argument to __register_sysctl_table and adjust
callers, all of which pass ctl_table pointers and need an explicit call
to ARRAY_SIZE. We implement a size calculation in register_net_sysctl in
order to forward the size of the array pointer received from the network
register calls.

The new table_size argument does not yet have any effect in the
init_header call which is still dependent on the sentinel's presence.
table_size *does* however drive the `kzalloc` allocation in
__register_sysctl_table with no adverse effects as the allocated memory
is either one element greater than the calculated ctl_table array (for
the calls in ipc_sysctl.c, mq_sysctl.c and ucount.c) or the exact size
of the calculated ctl_table array (for the call from sysctl_net.c and
register_sysctl). This approach will allows us to "just" remove the
sentinel without further changes to __register_sysctl_table as
table_size will represent the exact size for all the callers at that
point.

Signed-off-by: Joel Granados <j.granados@samsung.com>
---
 fs/proc/proc_sysctl.c  | 23 ++++++++++++-----------
 include/linux/sysctl.h |  2 +-
 ipc/ipc_sysctl.c       |  4 +++-
 ipc/mq_sysctl.c        |  4 +++-
 kernel/ucount.c        |  3 ++-
 net/sysctl_net.c       |  8 +++++++-
 6 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index fa1438f1a355..b8dd78e344ff 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1312,6 +1312,7 @@ static struct ctl_dir *sysctl_mkdir_p(struct ctl_dir *dir, const char *path)
  * 	 should not be free'd after registration. So it should not be
  * 	 used on stack. It can either be a global or dynamically allocated
  * 	 by the caller and free'd later after sysctl unregistration.
+ * @table_size : The number of elements in table
  *
  * Register a sysctl table hierarchy. @table should be a filled in ctl_table
  * array. A completely 0 filled entry terminates the table.
@@ -1354,27 +1355,20 @@ static struct ctl_dir *sysctl_mkdir_p(struct ctl_dir *dir, const char *path)
  */
 struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_set *set,
-	const char *path, struct ctl_table *table)
+	const char *path, struct ctl_table *table, size_t table_size)
 {
 	struct ctl_table_root *root = set->dir.header.root;
 	struct ctl_table_header *header;
-	struct ctl_table_header h_tmp;
 	struct ctl_dir *dir;
-	struct ctl_table *entry;
 	struct ctl_node *node;
-	int nr_entries = 0;
-
-	h_tmp.ctl_table = table;
-	list_for_each_table_entry(entry, (&h_tmp))
-		nr_entries++;
 
 	header = kzalloc(sizeof(struct ctl_table_header) +
-			 sizeof(struct ctl_node)*nr_entries, GFP_KERNEL_ACCOUNT);
+			 sizeof(struct ctl_node)*table_size, GFP_KERNEL_ACCOUNT);
 	if (!header)
 		return NULL;
 
 	node = (struct ctl_node *)(header + 1);
-	init_header(header, root, set, node, table, nr_entries);
+	init_header(header, root, set, node, table, table_size);
 	if (sysctl_check_table(path, header))
 		goto fail;
 
@@ -1423,8 +1417,15 @@ struct ctl_table_header *__register_sysctl_table(
  */
 struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table)
 {
+	int count = 0;
+	struct ctl_table *entry;
+	struct ctl_table_header t_hdr;
+
+	t_hdr.ctl_table = table;
+	list_for_each_table_entry(entry, (&t_hdr))
+		count++;
 	return __register_sysctl_table(&sysctl_table_root.default_set,
-					path, table);
+					path, table, count);
 }
 EXPORT_SYMBOL(register_sysctl);
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 33252ad58ebe..0495c858989f 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -226,7 +226,7 @@ extern void retire_sysctl_set(struct ctl_table_set *set);
 
 struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_set *set,
-	const char *path, struct ctl_table *table);
+	const char *path, struct ctl_table *table, size_t table_size);
 struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table);
 void unregister_sysctl_table(struct ctl_table_header * table);
 
diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index ef313ecfb53a..8c62e443f78b 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -259,7 +259,9 @@ bool setup_ipc_sysctls(struct ipc_namespace *ns)
 				tbl[i].data = NULL;
 		}
 
-		ns->ipc_sysctls = __register_sysctl_table(&ns->ipc_set, "kernel", tbl);
+		ns->ipc_sysctls = __register_sysctl_table(&ns->ipc_set,
+							  "kernel", tbl,
+							  ARRAY_SIZE(ipc_sysctls));
 	}
 	if (!ns->ipc_sysctls) {
 		kfree(tbl);
diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
index fbf6a8b93a26..ebb5ed81c151 100644
--- a/ipc/mq_sysctl.c
+++ b/ipc/mq_sysctl.c
@@ -109,7 +109,9 @@ bool setup_mq_sysctls(struct ipc_namespace *ns)
 				tbl[i].data = NULL;
 		}
 
-		ns->mq_sysctls = __register_sysctl_table(&ns->mq_set, "fs/mqueue", tbl);
+		ns->mq_sysctls = __register_sysctl_table(&ns->mq_set,
+							 "fs/mqueue", tbl,
+							 ARRAY_SIZE(mq_sysctls));
 	}
 	if (!ns->mq_sysctls) {
 		kfree(tbl);
diff --git a/kernel/ucount.c b/kernel/ucount.c
index ee8e57fd6f90..2b80264bb79f 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -104,7 +104,8 @@ bool setup_userns_sysctls(struct user_namespace *ns)
 		for (i = 0; i < UCOUNT_COUNTS; i++) {
 			tbl[i].data = &ns->ucount_max[i];
 		}
-		ns->sysctls = __register_sysctl_table(&ns->set, "user", tbl);
+		ns->sysctls = __register_sysctl_table(&ns->set, "user", tbl,
+						      ARRAY_SIZE(user_table));
 	}
 	if (!ns->sysctls) {
 		kfree(tbl);
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 4b45ed631eb8..8ee4b74bc009 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -163,10 +163,16 @@ static void ensure_safe_net_sysctl(struct net *net, const char *path,
 struct ctl_table_header *register_net_sysctl(struct net *net,
 	const char *path, struct ctl_table *table)
 {
+	int count = 0;
+	struct ctl_table *entry;
+
 	if (!net_eq(net, &init_net))
 		ensure_safe_net_sysctl(net, path, table);
 
-	return __register_sysctl_table(&net->sysctls, path, table);
+	for (entry = table; entry->procname; entry++)
+		count++;
+
+	return __register_sysctl_table(&net->sysctls, path, table, count);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl);
 
-- 
2.30.2


