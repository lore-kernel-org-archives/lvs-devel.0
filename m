From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 01/14] sysctl: Prefer ctl_table_header in proc_sysctl
Date: Mon, 31 Jul 2023 09:17:15 +0200
Message-ID: <20230731071728.3493794-2-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev+bounces-22698-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787851; x=1691392651;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=9/+5UTOZSoINBQX5Idlq9s7Q/YjlqMmFruSJ92+I5og=;
        b=aa90vhrzpcWfje6OipbZcbSYmqsQOrKCRcOH+mXZEBSAe4e9SYO9KbJpgMCHttr/yA
         zdFVQR1LOnV+D7hAiD+KrUS2ISlvjUkq+b7yUFbiR01dxQnjTtlB3gUvsDsEdzqxQBra
         VtmXCBuFRC2NHa/MDl3j3RRH7oueh+fFARArWcE6cGtzhOQHhoEyDoaWBNB9BNxyNorT
         Vsk7HiljVefekG81Lh7gDtS9SFSWp6bx3r/GStCaxRX7m39RSXK/U9SkwJ+la8Y3+Sa+
         bicaAOoBwyN9hsG7EPZFDiSfvHQfnOEmdljFsJjOX5Tmk2pevqcpTLWxI8xhB+d6ZiQD
         aq0g==
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Jakub Kicinski <kuba@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, Joerg Reuter <jreuter@yaina.de>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsahern@kernel.org>, netfilter-devel@vger.ker

This is a preparation commit that replaces ctl_table with
ctl_table_header as the pointer that is passed around in proc_sysctl.c.
This will become necessary in subsequent commits when the size of the
ctl_table array can no longer be calculated by searching for an empty
sentinel (last empty ctl_table element) but will be carried along inside
the ctl_table_header struct.

Signed-off-by: Joel Granados <j.granados@samsung.com>
---
 fs/proc/proc_sysctl.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 5ea42653126e..94d71446da39 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1125,11 +1125,11 @@ static int sysctl_check_table_array(const char *path, struct ctl_table *table)
 	return err;
 }
 
-static int sysctl_check_table(const char *path, struct ctl_table *table)
+static int sysctl_check_table(const char *path, struct ctl_table_header *header)
 {
 	struct ctl_table *entry;
 	int err = 0;
-	list_for_each_table_entry(entry, table) {
+	list_for_each_table_entry(entry, header->ctl_table) {
 		if ((entry->proc_handler == proc_dostring) ||
 		    (entry->proc_handler == proc_dobool) ||
 		    (entry->proc_handler == proc_dointvec) ||
@@ -1159,8 +1159,7 @@ static int sysctl_check_table(const char *path, struct ctl_table *table)
 	return err;
 }
 
-static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table *table,
-	struct ctl_table_root *link_root)
+static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table_header *head)
 {
 	struct ctl_table *link_table, *entry, *link;
 	struct ctl_table_header *links;
@@ -1170,7 +1169,7 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 
 	name_bytes = 0;
 	nr_entries = 0;
-	list_for_each_table_entry(entry, table) {
+	list_for_each_table_entry(entry, head->ctl_table) {
 		nr_entries++;
 		name_bytes += strlen(entry->procname) + 1;
 	}
@@ -1189,12 +1188,12 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 	link_name = (char *)&link_table[nr_entries + 1];
 	link = link_table;
 
-	list_for_each_table_entry(entry, table) {
+	list_for_each_table_entry(entry, head->ctl_table) {
 		int len = strlen(entry->procname) + 1;
 		memcpy(link_name, entry->procname, len);
 		link->procname = link_name;
 		link->mode = S_IFLNK|S_IRWXUGO;
-		link->data = link_root;
+		link->data = head->root;
 		link_name += len;
 		link++;
 	}
@@ -1205,15 +1204,16 @@ static struct ctl_table_header *new_links(struct ctl_dir *dir, struct ctl_table
 }
 
 static bool get_links(struct ctl_dir *dir,
-	struct ctl_table *table, struct ctl_table_root *link_root)
+		      struct ctl_table_header *header,
+		      struct ctl_table_root *link_root)
 {
-	struct ctl_table_header *head;
+	struct ctl_table_header *tmp_head;
 	struct ctl_table *entry, *link;
 
 	/* Are there links available for every entry in table? */
-	list_for_each_table_entry(entry, table) {
+	list_for_each_table_entry(entry, header->ctl_table) {
 		const char *procname = entry->procname;
-		link = find_entry(&head, dir, procname, strlen(procname));
+		link = find_entry(&tmp_head, dir, procname, strlen(procname));
 		if (!link)
 			return false;
 		if (S_ISDIR(link->mode) && S_ISDIR(entry->mode))
@@ -1224,10 +1224,10 @@ static bool get_links(struct ctl_dir *dir,
 	}
 
 	/* The checks passed.  Increase the registration count on the links */
-	list_for_each_table_entry(entry, table) {
+	list_for_each_table_entry(entry, header->ctl_table) {
 		const char *procname = entry->procname;
-		link = find_entry(&head, dir, procname, strlen(procname));
-		head->nreg++;
+		link = find_entry(&tmp_head, dir, procname, strlen(procname));
+		tmp_head->nreg++;
 	}
 	return true;
 }
@@ -1246,13 +1246,13 @@ static int insert_links(struct ctl_table_header *head)
 	if (IS_ERR(core_parent))
 		return 0;
 
-	if (get_links(core_parent, head->ctl_table, head->root))
+	if (get_links(core_parent, head, head->root))
 		return 0;
 
 	core_parent->header.nreg++;
 	spin_unlock(&sysctl_lock);
 
-	links = new_links(core_parent, head->ctl_table, head->root);
+	links = new_links(core_parent, head);
 
 	spin_lock(&sysctl_lock);
 	err = -ENOMEM;
@@ -1260,7 +1260,7 @@ static int insert_links(struct ctl_table_header *head)
 		goto out;
 
 	err = 0;
-	if (get_links(core_parent, head->ctl_table, head->root)) {
+	if (get_links(core_parent, head, head->root)) {
 		kfree(links);
 		goto out;
 	}
@@ -1371,7 +1371,7 @@ struct ctl_table_header *__register_sysctl_table(
 
 	node = (struct ctl_node *)(header + 1);
 	init_header(header, root, set, node, table);
-	if (sysctl_check_table(path, table))
+	if (sysctl_check_table(path, header))
 		goto fail;
 
 	spin_lock(&sysctl_lock);
-- 
2.30.2


