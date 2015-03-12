From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 02/22] netfilter: %pF is only for function pointers
Date: Wed, 11 Mar 2015 22:13:37 -0500
Message-ID: <1426130037-17956-2-git-send-email-scottwood@freescale.com>
References: <1426130037-17956-1-git-send-email-scottwood@freescale.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1426130037-17956-1-git-send-email-scottwood@freescale.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trivial@kernel.org, linux-kernel@vger.kernel.org
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Use %pS for actual addresses, otherwise you'll get bad output
on arches like ppc64 where %pF expects a function descriptor.

Signed-off-by: Scott Wood <scottwood@freescale.com>
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b0f7b62..f9f3c3d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -184,7 +184,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		hlist_add_head_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
 		ret = 1;
 	} else {
-		pr_err("%s(): request for already hashed, called from %pF\n",
+		pr_err("%s(): request for already hashed, called from %pS\n",
 		       __func__, __builtin_return_address(0));
 		ret = 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ed99448..bd1ef52 100644
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

