Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8EBF415B6C;
	Wed, 19 Aug 2026 18:17:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163438; cv=none; b=DKPfdhD6BlAjc0yDqIhF5a4izavH0hQ6eAzT4t7cVCdsTNpImhsYdM3lbZxvhL+tS6Pwf9pJoLjUI5BGkZEZX5c8Tsz2jtIG1KsKPsgZz+H+arqCfsljllvIbA2FN8QSNvoT+s7Botd31mdv08EIPirChQ52FAOCckg8I0+bAuI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163438; c=relaxed/simple;
	bh=vUfOIiG3lMRcheFBBxX0asKqrhYKFq5a+zslU3lY20g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=m3x2nD4CsAilwkVDB3Rf/rx5mjHeecmfc0PKUcJwp67PxhzjguyS+M2qLE5kQ9r3MG+Gh0dnRibDl2ifUQRP7nJNQp3Nb5nV7gBwI93wpC5rLA2/C9HNbhmh2e0ZOojOMKfopI0L+Oqy4jdLGKPREkgMnKfFdhqDtnXPf1t354M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=oBGbw0t3; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="oBGbw0t3"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=bnDCW7/LrZXWETxlVsz0e02k5adMYu/+BGoT1rCaICg=; b=oBGbw0t3FHxrW1LvQvHvsKnuz2
	M97XEKa1cu10N3eaVs1S7lPRFzvNZeCzlqwpN7OgC9P7IeRF1TJIcf6JguJgXUKV2OIOgoEM/kf8q
	T1LXmcoiKqfkgF2uC5AuBHbOFW6w5ooKcgiO/IhKyp/GGKMPwfHjUwAvLOtER5GZ8AyO41RbdGdsw
	U5ftvELHATXaV012sqP5g3dfsnZPVBWxjJBH0fT3LkYNB90kB2D8imhdpIUYYbl3sgG0ji2ZLqdiw
	aZ903J8GL8ZhBhdO9dZJxBvky5op5p1YXFU8Nw51cg+60PgWnZ5vCVkqFe7EJ1Pxi0D6E5qf26Eb0
	lXq+FUTA==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkqg-006ENH-14; Wed, 19 Aug 2026 20:17:14 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:25 -0300
Subject: [PATCH RFC v3 12/13] modpost: move addend_*_rel() calls into
 addend_rel()
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-12-aab90569365d@igalia.com>
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

Move the arch-based addend_*_rel() calls into addend_rel() to be reused.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 scripts/mod/modpost.c | 35 +++++++++++++++++++----------------
 scripts/mod/modpost.h |  2 ++
 2 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 75374c64b8cc78bb4d01fa4c64254c7d7cd80e8f..d18a87b882a67f06d5f75ee92f4c26dc713d83b8 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -1296,6 +1296,24 @@ static Elf_Addr addend_mips_rel(uint32_t *location, unsigned int r_type)
 	return (Elf_Addr)(-1);
 }
 
+Elf_Addr addend_rel(struct elf_info *elf, unsigned int secndx,
+		    unsigned int r_type, Elf_Addr r_offset, Elf_Sym *tsym)
+{
+	void *loc = sym_get_data_by_offset(elf, secndx, r_offset);
+
+	switch (elf->hdr->e_machine) {
+	case EM_386:
+		return addend_386_rel(loc, r_type);
+	case EM_ARM:
+		return addend_arm_rel(loc, tsym, r_type);
+	case EM_MIPS:
+		return addend_mips_rel(loc, r_type);
+	}
+
+	fatal("Please add code to calculate addend for this architecture\n");
+	return (Elf_Addr)(-1);
+}
+
 #ifndef EM_RISCV
 #define EM_RISCV		243
 #endif
@@ -1402,27 +1420,12 @@ static void section_rel(struct module *mod, struct elf_info *elf,
 		Elf_Sym *tsym;
 		Elf_Addr taddr, r_offset;
 		unsigned int r_type, r_sym;
-		void *loc;
 
 		r_offset = TO_NATIVE(rel->r_offset);
 		get_rel_type_and_sym(elf, rel->r_info, &r_type, &r_sym);
 
-		loc = sym_get_data_by_offset(elf, fsecndx, r_offset);
 		tsym = elf->symtab_start + r_sym;
-
-		switch (elf->hdr->e_machine) {
-		case EM_386:
-			taddr = addend_386_rel(loc, r_type);
-			break;
-		case EM_ARM:
-			taddr = addend_arm_rel(loc, tsym, r_type);
-			break;
-		case EM_MIPS:
-			taddr = addend_mips_rel(loc, r_type);
-			break;
-		default:
-			fatal("Please add code to calculate addend for this architecture\n");
-		}
+		taddr = addend_rel(elf, fsecndx, r_type, r_offset, tsym);
 
 		check_section_mismatch(mod, elf, tsym,
 				       fsecndx, fromsec, r_offset, taddr);
diff --git a/scripts/mod/modpost.h b/scripts/mod/modpost.h
index d5f6d82837d5b4fbd671ff9dab9bbe353442f6cf..a98811552bd2996c31cf73fd3619e6c58bac8a6d 100644
--- a/scripts/mod/modpost.h
+++ b/scripts/mod/modpost.h
@@ -222,6 +222,8 @@ const char *get_basename(const char *path);
 char *read_text_file(const char *filename);
 char *get_line(char **stringp);
 void *sym_get_data(const struct elf_info *info, const Elf_Sym *sym);
+Elf_Addr addend_rel(struct elf_info *elf, unsigned int secndx,
+		    unsigned int r_type, Elf_Addr r_offset, Elf_Sym *tsym);
 
 void __attribute__((format(printf, 3, 4)))
 modpost_log(bool is_error, struct module *mod, const char *fmt, ...);

-- 
2.47.3

