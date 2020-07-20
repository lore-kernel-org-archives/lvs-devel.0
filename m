From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 03/24] net: add a new sockptr_t type
Date: Mon, 20 Jul 2020 14:47:16 +0200
Message-ID: <20200720124737.118617-4-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=v9KgsOSWea1bJKFDijg05Yu/Lxnc3rcc50PR6ELHK4E=; b=MadyBZx0Wf8x+2kw7O1nJxOIOd
        FbU4MH1JyD5v78V7lQ/HRw45yXpPVs9JO/G+kH4DiN1QWFmw0WGQv/S2d22ogQPe/4gqcuswjDMxD
        UA+RyowobKCKhwuLpSB8o4bKj8XVpqEmqj4r0KjhkUO/Xe3omvaNi1zO6Mu7Ul5xJ63b84wq7p4uE
        igF3dMEhdDGLmF1UIoeXtgDt60qeorgzwuf6irI/HPydWG6GGi42y2nO3TPoyuU57ddcRPRbw8sYq
        A124JUfae++O65R5yqh735FbvAIm2bAY6i4tx8g4ymy/GWe+BCXCPTa9ItoQv2rd6m2uecW1hKmJ+
        VToa8WXQ==;
In-Reply-To: <20200720124737.118617-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Add a uptr_t type that can hold a pointer to either a user or kernel
memory region, and simply helpers to copy to and from it.  For
architectures like x86 that have non-overlapping user and kernel
address space it just is a union and uses a TASK_SIZE check to
select the proper copy routine.  For architectures with overlapping
address spaces a flag to indicate the address space is used instead.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 include/linux/sockptr.h | 121 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 121 insertions(+)
 create mode 100644 include/linux/sockptr.h

diff --git a/include/linux/sockptr.h b/include/linux/sockptr.h
new file mode 100644
index 00000000000000..e41dfa52555dec
--- /dev/null
+++ b/include/linux/sockptr.h
@@ -0,0 +1,121 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+/*
+ * Copyright (c) 2020 Christoph Hellwig.
+ *
+ * Support for "universal" pointers that can point to either kernel or userspace
+ * memory.
+ */
+#ifndef _LINUX_SOCKPTR_H
+#define _LINUX_SOCKPTR_H
+
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+
+#ifdef CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE
+typedef union {
+	void		*kernel;
+	void __user	*user;
+} sockptr_t;
+
+static inline bool sockptr_is_kernel(sockptr_t sockptr)
+{
+	return (unsigned long)sockptr.kernel >= TASK_SIZE;
+}
+
+static inline sockptr_t KERNEL_SOCKPTR(void *p)
+{
+	return (sockptr_t) { .kernel = p };
+}
+#else /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
+typedef struct {
+	union {
+		void		*kernel;
+		void __user	*user;
+	};
+	bool		is_kernel : 1;
+} sockptr_t;
+
+static inline bool sockptr_is_kernel(sockptr_t sockptr)
+{
+	return sockptr.is_kernel;
+}
+
+static inline sockptr_t KERNEL_SOCKPTR(void *p)
+{
+	return (sockptr_t) { .kernel = p, .is_kernel = true };
+}
+#endif /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
+
+static inline sockptr_t USER_SOCKPTR(void __user *p)
+{
+	return (sockptr_t) { .user = p };
+}
+
+static inline bool sockptr_is_null(sockptr_t sockptr)
+{
+	return !sockptr.user && !sockptr.kernel;
+}
+
+static inline int copy_from_sockptr(void *dst, sockptr_t src, size_t size)
+{
+	if (!sockptr_is_kernel(src))
+		return copy_from_user(dst, src.user, size);
+	memcpy(dst, src.kernel, size);
+	return 0;
+}
+
+static inline int copy_to_sockptr(sockptr_t dst, const void *src, size_t size)
+{
+	if (!sockptr_is_kernel(dst))
+		return copy_to_user(dst.user, src, size);
+	memcpy(dst.kernel, src, size);
+	return 0;
+}
+
+static inline void *memdup_sockptr(sockptr_t src, size_t len)
+{
+	void *p = kmalloc_track_caller(len, GFP_USER | __GFP_NOWARN);
+
+	if (!p)
+		return ERR_PTR(-ENOMEM);
+	if (copy_from_sockptr(p, src, len)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+	return p;
+}
+
+static inline void *memdup_sockptr_nul(sockptr_t src, size_t len)
+{
+	char *p = kmalloc_track_caller(len + 1, GFP_KERNEL);
+
+	if (!p)
+		return ERR_PTR(-ENOMEM);
+	if (copy_from_sockptr(p, src, len)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+	p[len] = '\0';
+	return p;
+}
+
+static inline void sockptr_advance(sockptr_t sockptr, size_t len)
+{
+	if (sockptr_is_kernel(sockptr))
+		sockptr.kernel += len;
+	else
+		sockptr.user += len;
+}
+
+static inline long strncpy_from_sockptr(char *dst, sockptr_t src, size_t count)
+{
+	if (sockptr_is_kernel(src)) {
+		size_t len = min(strnlen(src.kernel, count - 1) + 1, count);
+
+		memcpy(dst, src.kernel, len);
+		return len;
+	}
+	return strncpy_from_user(dst, src.user, count);
+}
+
+#endif /* _LINUX_SOCKPTR_H */
-- 
2.27.0

