Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEAB72E888A;
	Wed, 19 Aug 2026 02:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106636; cv=none; b=qiH46Y6T8QTdtl4fAlhGvh02RdDKA5i4numzoyckglTQsGImeDI1QA/H5NEEjYvzoA7bpFveOOX9JxUQk2pgCnNXL3pJByE05S7F3d+h0tnuLyzYLkGnqH1JVT8I7W/uJKZYJpUnWGlqr8BQob1L3kjh/N/b/Jx6Do0LSP72lDk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106636; c=relaxed/simple;
	bh=f5o2O9UPHv5pX2VWOxwFtCNED6SACshLVdHxs505Pu8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jCRkZn2Wg4jwLS+1bl4MFS3QyjGhpCS56p3nOggZkkv16Co4BsFEJa9H1MjLq0US4qCSrBEp5hyVQ6+1Quw9r927ZUb9FlsHkBLohr3+M0hSryuQy/CdrICx/xPO100itJxeZeYwSC6L+RAzgx22572hDfhJ+ezZIbFZuAiRZAE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=giJOjMqU; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="giJOjMqU"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=wddugAF1IEM+cZdWDVa5PB4xseG8bsMauhbh/5skNPc=; b=giJOjMqUhmbHyNS+EgzZmF35wF
	ORFZgD/3YorjInbQI8oHNtL6VUZzZaDvelmiT4s7DmbmAKhQjMJRu3fjqqAA6pAUQZv0xrla2k8/A
	oc4ZNUzP6xTkwASejvoefETSBHm9I+J6S9lDuinbYAeVXnuSYQShxIx6ys7nktysLLq5zcGcM2mYj
	WjvdyfO8WL489Tf/YtFncC3dj8B1EI5bwPW8kAE9iyuEpgblK4AKH+mZlQQTCXC/yAzKXJB0A3bZG
	oY6KeZy3VpEba6Sqsib/YR1CnpLtdf+JoEYHjGnWXmVshPCIokphl8tuQmEhCoedfSVynLKFpTyP5
	0ZrTKzjg==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW4W-005tfG-BK; Wed, 19 Aug 2026 04:30:32 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:12 -0300
Subject: [PATCH RFC v2 13/13] modpost: handle MODULE_SYSCTL_TABLE symbols
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-13-d5a69dae5798@igalia.com>
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

Update file2alias.c to handle 'mod_devicetable' symbols with type 'sysctl'.

The key operation is to iterate over relocation entries, so add the helper
for_each_reloc() with a function callback, and the functions to:

1) Find the sysctl path and table in the 'sysctl' module symbol.

2) Find the sysctl table's entries and their '.procname' field,
   adding a module alias 'sysctl:*/<path>/<procname>' for each.

Originally-by: Mauricio Faria de Oliveira <mfo@canonical.com>
Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 scripts/mod/file2alias.c | 230 +++++++++++++++++++++++++++++++++++++++++++++++
 scripts/mod/modpost.c    |  11 ++-
 scripts/mod/modpost.h    |  23 +++++
 3 files changed, 262 insertions(+), 2 deletions(-)

diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index 8d36c74dec2d55840de60b3f8ec22b646d16ff8b..797cfc2f478e25dd2ba5f9a5a063a2919fe58cc5 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -1531,6 +1531,231 @@ static const struct devtable devtable[] = {
 	{"pnp_card", SIZE_pnp_card_device_id, do_pnp_card_entry},
 };
 
+// Looks like: sysctl:*/path/procname
+static void do_sysctl_entry(const char *procname, const char *path,
+			    struct module *mod)
+{
+	const char *src;
+	char *dst, buf[256], *end = buf + sizeof(buf) - 1; /* -1 for NUL byte */
+
+	/* Replace '%s' from path template with '*' for wildcard in modprobe. */
+	for (src = path, dst = buf; *src && dst < end; src++, dst++)
+		*dst = (*src == '%') ? (src++, '*') : *src;
+	*dst = '\0';
+
+	module_alias_printf(mod, false, "sysctl:*/%s/%s", buf, procname);
+}
+
+/*
+ * Execute a callback function for each relocation entry in relocation section.
+ * The caller must ensure sechdr->sh_type is SHT_RELA or SHT_REL.
+ */
+static void for_each_reloc(struct elf_info *elf, unsigned int shndx,
+			   bool (*fn)(struct elf_info *elf, Elf_Shdr *sechdr,
+				      Elf_Sym *sym, Elf_Addr r_offset,
+				      Elf_Addr r_addend, void *data),
+			   void *data)
+{
+	Elf_Shdr *sechdr = &elf->sechdrs[shndx];
+	const Elf_Rela *rela; /* used as Elf_Rel[a] on SHT_REL[A] */
+	const Elf_Rela *start = (void *) elf->hdr + sechdr->sh_offset;
+	const Elf_Rela *stop = (void *) start + sechdr->sh_size;
+	size_t size = (sechdr->sh_type == SHT_RELA) ? sizeof(Elf_Rela)
+						    : sizeof(Elf_Rel);
+
+	for (rela = start; rela < stop; rela = (Elf_Rela *)((void *) rela + size)) {
+		Elf_Sym *sym;
+		Elf_Addr r_offset, r_addend;
+		unsigned int r_type, r_sym;
+
+		r_offset = TO_NATIVE(rela->r_offset);
+		get_rel_type_and_sym(elf, rela->r_info, &r_type, &r_sym);
+
+		sym = elf->symtab_start + r_sym;
+		r_addend = (sechdr->sh_type == SHT_RELA)
+					? TO_NATIVE(rela->r_addend)
+					: addend_rel(elf, sechdr->sh_info,
+						     r_type, r_offset, sym);
+
+		if (fn(elf, sechdr, sym, r_offset, r_addend, data))
+			break;
+	}
+}
+
+/*
+ * Callback parameters and function to loop over the sysctl entries in struct
+ * module_sysctl_table's .table symbol (found below) in its reloction section.
+ */
+struct sysctl_entries {
+	Elf_Addr table_offset;
+	ssize_t table_size;
+	ssize_t entry_size;
+	const char *path;
+	const char *modsymname;
+	struct module *mod;
+};
+
+static bool do_sysctl_entries(struct elf_info *elf, Elf_Shdr *sechdr, Elf_Sym *sym,
+			      Elf_Addr r_offset, Elf_Addr r_addend, void *data)
+{
+	struct sysctl_entries *sysctl_entries = (struct sysctl_entries *) data;
+
+	/* Skip until .table starts */
+	if (r_offset < sysctl_entries->table_offset)
+		return false;
+
+	/* Stop after .table ends */
+	if (r_offset >= sysctl_entries->table_offset + sysctl_entries->table_size)
+		return true;
+
+	/* Check for alignment with an array entry (.procname at offset zero) */
+	if ((r_offset - sysctl_entries->table_offset) % sysctl_entries->entry_size == 0) {
+
+		/* The symbol for .procname points to a string */
+		const char *procname = (const char *)
+				       sym_get_data_addend(elf, sym, r_addend);
+
+		if (!procname) {
+			warn("%s [%s] found entry with NULL .procname (skip)\n",
+			     sysctl_entries->modsymname, sysctl_entries->mod->name);
+			return false;
+		}
+
+		do_sysctl_entry(procname, sysctl_entries->path, sysctl_entries->mod);
+	}
+
+	/* Continue at next entry */
+	return false;
+}
+
+/*
+ * Callback parameters and function to search for struct module_sysctl_table's
+ * pointers (.path and .table) in relocation entries of a relocation section.
+ */
+struct sysctl_pointers {
+	/* Input: offsets */
+	Elf_Addr path_offset;
+	Elf_Addr table_offset;
+
+	/* Output: symbols and relocation addends */
+	Elf_Sym *path_sym;
+	Elf_Sym *table_sym;
+	Elf_Addr path_r_addend;
+	Elf_Addr table_r_addend;
+};
+
+static bool do_sysctl_pointers(struct elf_info *elf, Elf_Shdr *sechdr, Elf_Sym *sym,
+			       Elf_Addr r_offset, Elf_Addr r_addend, void *data)
+{
+	struct sysctl_pointers *sysctl_pointers = (struct sysctl_pointers *) data;
+
+	/* Check for relocation entry's offset matching .path or .table */
+	if (!sysctl_pointers->path_sym &&
+	     sysctl_pointers->path_offset == r_offset) {
+		sysctl_pointers->path_sym = sym;
+		sysctl_pointers->path_r_addend = r_addend;
+	} else if (!sysctl_pointers->table_sym &&
+		    sysctl_pointers->table_offset == r_offset) {
+		sysctl_pointers->table_sym = sym;
+		sysctl_pointers->table_r_addend = r_addend;
+	}
+
+	/* Stop once both .path and .table are found */
+	return (sysctl_pointers->path_sym && sysctl_pointers->table_sym);
+}
+
+static void do_sysctl_table(const char *modsymname, void *modsymval,
+			    Elf_Sym *modsym, struct module *mod,
+			    struct elf_info *info)
+{
+	/*
+	 * The struct module_sysctl_table symbol contains 4 fields:
+	 *  .path: pointer to string with the dirname in /proc/sys
+	 *  .table: pointer to struct ctl_table array with filenames (.procname)
+	 *  .table_size: size of struct ctl_table array
+	 *  .entry_size: size of struct ctl_table entry in the array
+	 */
+
+	/* The size values can be read directly. */
+	DEF_FIELD(modsymval, module_sysctl_table, table_size);
+	DEF_FIELD(modsymval, module_sysctl_table, entry_size);
+
+	struct sysctl_entries sysctl_entries = {
+		.table_size = table_size,
+		.entry_size = entry_size,
+		.modsymname = modsymname,
+		.mod = mod,
+	};
+
+	/*
+	 * Step 1:
+	 *
+	 * Each pointer has a relocation entry in a relocation section,
+	 * that links the pointer with the symbol it points to.
+	 *
+	 * In order to access the symbols pointed to by .path and .table pointers:
+	 * 1) find the relocation section of the struct module_sysctl_table symbol;
+	 * 2) find the relocation entries for these pointers by their field offset;
+	 * 3) then use the symbols found in these relocation entries.
+	 */
+
+	struct sysctl_pointers sysctl_pointers = {
+		.path_offset = modsym->st_value + OFF_module_sysctl_table_path,
+		.path_sym = NULL,
+		.table_offset = modsym->st_value + OFF_module_sysctl_table_table,
+		.table_sym = NULL,
+	};
+
+	unsigned int shndx;
+
+	/* Find the relocation section for struct module_sysctl_table symbol. */
+	shndx = get_reloc_secindex(info, modsym);
+	if (shndx == SHN_UNDEF) {
+		error("%s [%s.ko] cannot find relocation section for symbol\n",
+		      modsymname, mod->name);
+		return;
+	}
+
+	/* Find the relocation entries for the .path and .table pointers. */
+	for_each_reloc(info, shndx, do_sysctl_pointers, &sysctl_pointers);
+	if (!sysctl_pointers.path_sym || !sysctl_pointers.table_sym) {
+		error("%s [%s.ko] cannot find relocation entry for path/table\n",
+		      modsymname, mod->name);
+		return;
+	}
+
+	/*
+	 * Step 2:
+	 *
+	 * The .table symbol is the struct ctl_table array where each entry has
+	 * a .procname pointer with a relocation entry for the filename string.
+	 *
+	 * In order to access the strings pointed to by .procname pointers:
+	 * 1) Find the relocation section of the struct ctl_table array symbol;
+	 * 2) Find the relocation entries for these pointers by their field offset;
+	 * 3) Then use the symbols found in these relocation entries.
+	 */
+
+	/* Find the relocation section for the struct ctl_table array. */
+	shndx = get_reloc_secindex(info, sysctl_pointers.table_sym);
+	if (shndx == SHN_UNDEF) {
+		/* Edge case: empty .table: no relocation section. */
+		return;
+	}
+
+	/* The .path symbol can be read directly. */
+	sysctl_entries.path = (const char *)
+			   sym_get_data_addend(info, sysctl_pointers.path_sym,
+						sysctl_pointers.path_r_addend);
+
+	/* The .table symbol is the struct ctl_table array. */
+	sysctl_entries.table_offset = sysctl_pointers.table_sym->st_value +
+				   sysctl_pointers.table_r_addend;
+
+	/* Add module aliases for entries in the struct ctl_table array. */
+	for_each_reloc(info, shndx, do_sysctl_entries, &sysctl_entries);
+}
+
 /* Create MODULE_ALIAS() statements.
  * At this time, we cannot write the actual output C source yet,
  * so we write into the mod->dev_table_buf buffer. */
@@ -1542,6 +1767,7 @@ void handle_moddevtable(struct module *mod, struct elf_info *info,
 	const char *type, *name, *modname;
 	size_t typelen, modnamelen;
 	static const char *prefix = "__mod_device_table__";
+	bool sym_is_devtable = false;
 
 	/* We're looking for a section relative symbol */
 	if (!sym->st_shndx || get_secindex(info, sym) >= info->num_sections)
@@ -1586,10 +1812,14 @@ void handle_moddevtable(struct module *mod, struct elf_info *info,
 		if (sym_is(type, typelen, p->device_id)) {
 			do_table(name, symval, sym->st_size, p->id_size,
 				 p->device_id, p->do_entry, mod);
+			sym_is_devtable = true;
 			break;
 		}
 	}
 
+	if (!sym_is_devtable && sym_is(type, typelen, "sysctl"))
+		do_sysctl_table(name, symval, sym, mod, info);
+
 	if (mod->is_vmlinux) {
 		struct module_alias *alias;
 
diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index d18a87b882a67f06d5f75ee92f4c26dc713d83b8..10eb7273cdd817da788fa3bce87d695661dd1b93 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -340,6 +340,13 @@ void *sym_get_data(const struct elf_info *info, const Elf_Sym *sym)
 				      sym->st_value);
 }
 
+void *sym_get_data_addend(const struct elf_info *info, const Elf_Sym *sym,
+			  Elf_Addr r_addend)
+{
+	return sym_get_data_by_offset(info, get_secindex(info, sym),
+				      sym->st_value + r_addend);
+}
+
 static const char *sech_name(const struct elf_info *info, Elf_Shdr *sechdr)
 {
 	return sym_get_data_by_offset(info, info->secindex_strings,
@@ -1338,8 +1345,8 @@ Elf_Addr addend_rel(struct elf_info *elf, unsigned int secndx,
 #define R_LARCH_ALIGN		102
 #endif
 
-static void get_rel_type_and_sym(struct elf_info *elf, uint64_t r_info,
-				 unsigned int *r_type, unsigned int *r_sym)
+void get_rel_type_and_sym(struct elf_info *elf, uint64_t r_info,
+			  unsigned int *r_type, unsigned int *r_sym)
 {
 	typedef struct {
 		Elf64_Word    r_sym;	/* Symbol index */
diff --git a/scripts/mod/modpost.h b/scripts/mod/modpost.h
index a98811552bd2996c31cf73fd3619e6c58bac8a6d..409fdfc844c4bfcea30fd6ae758f4042384e3e56 100644
--- a/scripts/mod/modpost.h
+++ b/scripts/mod/modpost.h
@@ -186,6 +186,25 @@ static inline unsigned int get_secindex(const struct elf_info *info,
 	return index;
 }
 
+/* Find the relocation section for the section of a symbol */
+static inline unsigned int get_reloc_secindex(const struct elf_info *info,
+					      const Elf_Sym *sym)
+{
+	unsigned int sym_secindex = get_secindex(info, sym);
+	unsigned int secindex;
+
+	for (secindex = 0; secindex < info->num_sections; secindex++) {
+		Elf_Shdr *shdr = &info->sechdrs[secindex];
+
+		if ((shdr->sh_type == SHT_RELA || shdr->sh_type == SHT_REL) &&
+		    (shdr->sh_flags & SHF_INFO_LINK) &&
+		    shdr->sh_info == sym_secindex)
+			return secindex;
+	}
+
+	return SHN_UNDEF;
+}
+
 /*
  * If there's no name there, ignore it; likewise, ignore it if it's
  * one of the magic symbols emitted used by current tools.
@@ -222,8 +241,12 @@ const char *get_basename(const char *path);
 char *read_text_file(const char *filename);
 char *get_line(char **stringp);
 void *sym_get_data(const struct elf_info *info, const Elf_Sym *sym);
+void *sym_get_data_addend(const struct elf_info *info, const Elf_Sym *sym,
+			  Elf_Addr r_addend);
 Elf_Addr addend_rel(struct elf_info *elf, unsigned int secndx,
 		    unsigned int r_type, Elf_Addr r_offset, Elf_Sym *tsym);
+void get_rel_type_and_sym(struct elf_info *elf, uint64_t r_info,
+			  unsigned int *r_type, unsigned int *r_sym);
 
 void __attribute__((format(printf, 3, 4)))
 modpost_log(bool is_error, struct module *mod, const char *fmt, ...);

-- 
2.47.3

