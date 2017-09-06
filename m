From: Helge Deller <deller@gmx.de>
Subject: [PATCH 13/14] netfilter/ipvs: Use %pS printk format for direct addresses
Date: Wed,  6 Sep 2017 22:28:00 +0200
Message-ID: <1504729681-3504-14-git-send-email-deller@gmx.de>
References: <1504729681-3504-1-git-send-email-deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1504729681-3504-1-git-send-email-deller@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

The debug and error printk functions in ipvs uses wrongly the %pF instead of
the %pS printk format specifier for printing symbols for the address returned
by _builtin_return_address(0). Fix it for the ia64, ppc64 and parisc64
architectures.

Signed-off-by: Helge Deller <deller@gmx.de>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 3d2ac71a..f73561c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -185,7 +185,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		hlist_add_head_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
 		ret = 1;
 	} else {
-		pr_err("%s(): request for already hashed, called from %pF\n",
+		pr_err("%s(): request for already hashed, called from %pS\n",
 		       __func__, __builtin_return_address(0));
 		ret = 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 1fa3c23..88fc58a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -300,7 +300,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 	unsigned int hash;
 
 	if (svc->flags & IP_VS_SVC_F_HASHED) {
-		pr_err("%s(): request for already hashed, called from %pF\n",
+		pr_err("%s(): request for already hashed, called from %pS\n",
 		       __func__, __builtin_return_address(0));
 		return 0;
 	}
@@ -334,7 +334,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 {
 	if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
-		pr_err("%s(): request for unhash flagged, called from %pF\n",
+		pr_err("%s(): request for unhash flagged, called from %pS\n",
 		       __func__, __builtin_return_address(0));
 		return 0;
 	}
-- 
2.1.0

