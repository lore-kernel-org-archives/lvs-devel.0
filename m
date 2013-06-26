From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 7/8] kernel: remove unnecessary head file
Date: Wed, 26 Jun 2013 18:11:29 +0900
Message-ID: <1372237890-28211-8-git-send-email-horms@verge.net.au>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, JunweiZhang <junwei.zhang@6wind.com>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Simon Horman <horms@verge.net.au>

From: JunweiZhang <junwei.zhang@6wind.com>

ip_vs.h is not necessary for sysctl_binary.c.

prepare for the next patch to avoid compile issue.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reviewed-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
1.8.2.1
