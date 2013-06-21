From: junwei.zhang@6wind.com
Subject: [PATCH 1/2] kernel: remove unnecessary head file
Date: Fri, 21 Jun 2013 10:19:16 +0800
Message-ID: <1371781157-16743-1-git-send-email-junwei.zhang@6wind.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, JunweiZhang <junwei.zhang@6wind.com>, Nicolas Dichtel <nicolas.dichtel@6wind.com>

From: JunweiZhang <junwei.zhang@6wind.com>

ip_vs.h is not necessary for sysctl_binary.c.

prepare for the next patch to avoid compile issue.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 kernel/sysctl_binary.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index aea4a9e..b609213 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -3,7 +3,6 @@
 #include "../fs/xfs/xfs_sysctl.h"
 #include <linux/sunrpc/debug.h>
 #include <linux/string.h>
-#include <net/ip_vs.h>
 #include <linux/syscalls.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-- 
1.8.1.2

