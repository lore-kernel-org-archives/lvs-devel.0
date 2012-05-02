From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 18/18] export sysctl symbols needed by ip_vs_sync
Date: Wed,  2 May 2012 15:22:42 +0900
Message-ID: <1335939762-1912-19-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

To build ip_vs as a module sysctl_rmem_max and sysctl_wmem_max
needs to be exported.
The dependency was added by "ipvs: wakeup master thread" patch

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/core/sock.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index c7e60ea..ac3131a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -258,7 +258,9 @@ static struct lock_class_key af_callback_keys[AF_MAX];
 
 /* Run time adjustable parameters. */
 __u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
+EXPORT_SYMBOL(sysctl_wmem_max);
 __u32 sysctl_rmem_max __read_mostly = SK_RMEM_MAX;
+EXPORT_SYMBOL(sysctl_rmem_max);
 __u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
 __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 
-- 
1.7.10

