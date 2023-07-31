From: Joel Granados <joel.granados@gmail.com>
Subject: [PATCH v2 14/14] sysctl: Use ctl_table_size as stopping criteria for list macro
Date: Mon, 31 Jul 2023 09:17:28 +0200
Message-ID: <20230731071728.3493794-15-j.granados@samsung.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1690787878; x=1691392678;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=q2sRNbI2azaNM3epQYqeDbNNvVsnx+uOoBBxcjhRKfE=;
        b=FX60aiiY2KctEUh+j9yuK0cGnmKW2WpFZ3k1hVMZjIYTseBraxngepIWNvfcXGsPq1
         7xSVdY+8zc9yIZ57nKdT+hlUE0Ql178jQsRiH723XYn4HhHTr/pv49QmaTcNQ2XsUNAi
         PWzt+UqFr/sg0NpYqkGyiJNK7oFd9qBYvtgDfg+keM7SyoPlJi+mcwnnV0qqy8UUXXH+
         yEQM7BNRR98OhKiErQTxzAomz+aqzdV0nWU9PRrMuhWCCwSQ75cIObdPL85tLs8lZ4Tp
         84iwFiXBPFqH6x90lqRFXFaxycKbeNqBugndgd7V/GFzGnSbrjoxW1nQKlMiaVkRQI3W
         1DjQ==
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: mcgrof@kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Jakub Kicinski <kuba@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org

This is a preparation commit to make it easy to remove the sentinel
elements (empty end markers) from the ctl_table arrays. It both allows
the systematic removal of the sentinels and adds the ctl_table_size
variable to the stopping criteria of the list_for_each_table_entry macro
that traverses all ctl_table arrays. Once all the sentinels are removed
by subsequent commits, ctl_table_size will become the only stopping
criteria in the macro. We don't actually remove any elements in this
commit, but it sets things up to for the removal process to take place.

By adding header->ctl_table_size as an additional stopping criteria for
the list_for_each_table_entry macro, it will execute until it finds an
"empty" ->procname or until the size runs out. Therefore if a ctl_table
array with a sentinel is passed its size will be too big (by one
element) but it will stop on the sentinel. On the other hand, if the
ctl_table array without a sentinel is passed its size will be just write
and there will be no need for a sentinel.

Signed-off-by: Joel Granados <j.granados@samsung.com>
Suggested-by: Jani Nikula <jani.nikula@linux.intel.com>
---
 fs/proc/proc_sysctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 817bc51c58d8..504e847c2a3a 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -19,8 +19,9 @@
 #include <linux/kmemleak.h>
 #include "internal.h"
 
-#define list_for_each_table_entry(entry, header) \
-	for ((entry) = (header->ctl_table); (entry)->procname; (entry)++)
+#define list_for_each_table_entry(entry, header)	\
+	entry = header->ctl_table;			\
+	for (size_t i = 0 ; i < header->ctl_table_size && entry->procname; ++i, entry++)
 
 static const struct dentry_operations proc_sys_dentry_operations;
 static const struct file_operations proc_sys_file_operations;
-- 
2.30.2

