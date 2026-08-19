Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BEE1350285;
	Wed, 19 Aug 2026 02:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106552; cv=none; b=rr6KSn/XVCLpGk9c18lEkjXzRUyIGr0XAQ4CzFa+W3xYcow9zbinH40WnSWUmYmmnOBrc/IcInV7LA0PaTo3LuHWuPRLxFIQOBbvSbhjflUAFZfKnAZA8OzbMM2lXrnh0V1un8vOA/YxITqC4W62FEdYlzrrmhqsOZr5nFn1ofE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106552; c=relaxed/simple;
	bh=hSDaHlp+AtiPrqNRHKQvKu/6PNks2N1dJWDbN7fuL1I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=M3obCYh3yuV3cLmZLquVY2dZPjBiW1NRdl9M6VCITfSdhHphNAxMcyx29s7CRPvqKBa0ZTUGYG2V8bDMpa//O6zS2EZvmJ28jiYC0UrDzRQSj+Op6VXElFgsEyrrQO3ONauN7G9osrwf9s7ec77g9KF2tJn2nTYQsuSjs4GH4xw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=n2z84/Bk; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="n2z84/Bk"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=gXUB1QrnxsrjbOi4xhXBQHCEC2KmzTwW0NuAmy9Ikto=; b=n2z84/Bkg38wflHDu1N8jwEOo2
	ZhL3oGXbc/uFEJNt0XoVhkQqsRre2N2fOyTCQuNQcmupM5U4xH/zfSaLtYI1aRIDo/YO0g1gqt4Ju
	7p9NoN2QQbxE+l00ISPoz7HIP+7oCZcG92EJgUl3QzGaqJjQh9auxNr8bS4ZA9nATHJaFhzpDvRmO
	UlKyIzG3ehc7I51bRyD7vFd+x0m4H27sXkgltjUagvY3qf8XeMChZzB0feZbvbrgL7xapazL7ucBq
	NhoOXUbeOhAb812rK3zQurHa3LPJNqJjitOwEpKMCimzS3v+RLDXhGMeQuH+MLoIeR1UI6irvfMur
	sXWvDxfA==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW39-005tfG-1g; Wed, 19 Aug 2026 04:29:07 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:00 -0300
Subject: [PATCH RFC v2 01/13] keys, pidns, fs/verity, riscv/vector: reorder
 '#include <linux/sysctl.h>'
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260818-sysctl-module-aliases-v2-1-d5a69dae5798@igalia.com>
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

Fix an include loop error in preparation for sysctl.h to include module.h:

    CC [M]  arch/x86/events/amd/uncore.o
  In file included from .../include/linux/fs.h:44,         <<<
                   from .../include/linux/compat.h:17,
                   from .../arch/x86/include/asm/ia32.h:7,
                   from .../arch/x86/include/asm/elf.h:10,
                   from .../include/linux/elf.h:6,
                   from .../include/linux/module.h:20,     <<<
                   from .../include/linux/sysctl.h:245,    <<<
                   from .../include/linux/key.h:17,        <<<
                   from .../include/linux/cred.h:13,       <<<
                   from .../include/linux/sched/signal.h:10,
                   from .../include/linux/ptrace.h:7,
                   from .../include/uapi/asm-generic/bpf_perf_event.h:4,
                   from ./arch/x86/include/generated/uapi/asm/
                        bpf_perf_event.h:1,
                   from .../include/uapi/linux/bpf_perf_event.h:11,
                   from .../include/linux/perf_event.h:18,
                   from .../arch/x86/events/amd/uncore.c:8:
  .../include/linux/mnt_idmapping.h: In function ‘mapped_fsuid’:
  .../include/linux/mnt_idmapping.h:231:59: error: implicit declaration
    of function ‘current_fsuid’ [-Wimplicit-function-declaration]

Reason:
 - cred.h includes key.h *before* defining current_fsuid();
 - key.h includes sysctl.h;
 - sysctl.h includes module.h;
 - module.h includes fs.h via elf.h > asm/elf.h > asm/ia32.h > compat.h;
 - fs.h includes mnt_idmapping.h, which uses *undefined* current_fsuid().

Note that fs.h does include cred.h (which defines current_fsuid()) right
before mnt_idmapping.h (which uses it), but it is not parsed because the
include guard of cred.h is defined earlier.

Address this by removing sysctl.h from key.h, which does not need it,
and adding it to files that actually need it.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 arch/riscv/kernel/vector.c    | 1 +
 fs/verity/init.c              | 1 +
 include/linux/key.h           | 1 -
 include/linux/pid_namespace.h | 1 +
 4 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/riscv/kernel/vector.c b/arch/riscv/kernel/vector.c
index b112166d51e9f584f84c52d0f84feb92ccd60df1..9eac47c99f114304521fdc539018f3f84507e75f 100644
--- a/arch/riscv/kernel/vector.c
+++ b/arch/riscv/kernel/vector.c
@@ -10,6 +10,7 @@
 #include <linux/sched.h>
 #include <linux/uaccess.h>
 #include <linux/prctl.h>
+#include <linux/sysctl.h>
 
 #include <asm/thread_info.h>
 #include <asm/processor.h>
diff --git a/fs/verity/init.c b/fs/verity/init.c
index 3aa55dec88fc919792a2cb4be476f8481ef78a9e..d460eef74fcfe49f6cf69974a8194a65de486819 100644
--- a/fs/verity/init.c
+++ b/fs/verity/init.c
@@ -9,6 +9,7 @@
 #include "fsverity_private.h"
 
 #include <linux/ratelimit.h>
+#include <linux/sysctl.h>
 
 #ifdef CONFIG_SYSCTL
 static const struct ctl_table fsverity_sysctl_table[] = {
diff --git a/include/linux/key.h b/include/linux/key.h
index 81b8f05c68985c6f0a5c5bbe0f1fd6661912c618..a74f8f1b7936d6ede584c0a8cd520f858f6a9758 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -14,7 +14,6 @@
 #include <linux/list.h>
 #include <linux/rbtree.h>
 #include <linux/rcupdate.h>
-#include <linux/sysctl.h>
 #include <linux/rwsem.h>
 #include <linux/atomic.h>
 #include <linux/assoc_array.h>
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index b20baaa7e62b755e7e561fcd8018e2b61213503e..94b23471c7dec135e24c4c0c1fdbf841cea2e5de 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -10,6 +10,7 @@
 #include <linux/nsproxy.h>
 #include <linux/ns_common.h>
 #include <linux/idr.h>
+#include <linux/sysctl.h>
 
 /* MAX_PID_NS_LEVEL is needed for limiting size of 'struct pid' */
 #define MAX_PID_NS_LEVEL 32

-- 
2.47.3

