Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA9CA481B1;
	Wed, 19 Aug 2026 02:30:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106629; cv=none; b=qOF1GR3pjBoLrLL1s2CbufriXXJ3eQ2SZujERF5nQon+C9PvN75bi+PXo3ou1GPSgtB0fSLNG0Hrp5PMXJ+QZbQPm9onK0RJr113JGm+pVWRXDzGr8P57d4oOuoNGaH/JhqgZRGhqyCZ4nnEOXL3Xk20CIu80W6qhgLBzqP2ouM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106629; c=relaxed/simple;
	bh=vUfOIiG3lMRcheFBBxX0asKqrhYKFq5a+zslU3lY20g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RohJ8yap7uzYSSRCgIJnXmUlTW9EYm0YlqfDZGTiofHrrCzTKebxubVbjon9OHJmnUzCJbGCkJ2iX+uspz4f19wRTxjoa9B076kF+HRSyVPhUcR5WD7fKUMx7nxK56ZR3M+vH3fQJoKOYiwYmkP9B/rI9R/eZagtl3+5tDeIuK8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=HrkMDY4X; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="HrkMDY4X"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=bnDCW7/LrZXWETxlVsz0e02k5adMYu/+BGoT1rCaICg=; b=HrkMDY4X+Oq+jraZDgmYtUHhyI
	XP6vLHO8FI0DPZqaCBwosC+1lXhJdekxfcPmQv1a5VRzntv+U9GIFt9AVPuvSrmTzaVRfVs+AevP4
	s5XXLBRqXpgS3rnpYII8tWoSfrKvbvZDzQFUt2N6jjsxBlQfNZBA8kDodC2bXCs+GIP5aITQc03ne
	0MvKYn2y1uzQOZ5xCef/wrdxiO0wsHP/euJ0p2OCtqYB0xAHgKj0iAia/m6qBxkN1xmEDDTkeuScl
	LIB+NVBL1u2O0c2mMjahoMywUOmHtLDyfOnvP7p2KMLWvIVTtiUSj6Lh4pX3FjGo4SN1q0q9RTyNE
	CMQHvKkA==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW4P-005tfG-7k; Wed, 19 Aug 2026 04:30:25 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:11 -0300
Subject: [PATCH RFC v2 12/13] modpost: move addend_*_rel() calls into
 addend_rel()
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-12-d5a69dae5798@igalia.com>
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

