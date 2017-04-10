From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/3] netfilter: ipvs: Replace kzalloc with kcalloc.
Date: Mon, 10 Apr 2017 09:58:34 -0700
Message-ID: <1491843515-1627-3-git-send-email-horms@verge.net.au>
References: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1491843523; bh=NvqHA1sFAc1FDdY0vFVSM8YTmxU9Ap1k+My1ta9EyH4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=B1ke4hSN44zQ5kIQxnxdZdQHnOC5dWluKdYqzv5wL/EEmk9eh725172dRIu5VP4lu
         Az1D5CToJWX29y01JnK+HZluKSHftrUjrvD8ZP2VrL0UQi0Y6Z9ZraAxxRCpwbf87Q
         1g1g2HzBAYzT188H6Gjlt/aXtmhWOqZRCL1B1Fwo=
In-Reply-To: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Varsha Rao <rvarsha016@gmail.com>

From: Varsha Rao <rvarsha016@gmail.com>

Replace kzalloc with kcalloc. As kcalloc is preferred for allocating an
array instead of kzalloc. This patch fixes the checkpatch issue.

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b03c28084f81..30d6b2cc00a0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1849,7 +1849,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 	if (state == IP_VS_STATE_MASTER) {
 		struct ipvs_master_sync_state *ms;
 
-		ipvs->ms = kzalloc(count * sizeof(ipvs->ms[0]), GFP_KERNEL);
+		ipvs->ms = kcalloc(count, sizeof(ipvs->ms[0]), GFP_KERNEL);
 		if (!ipvs->ms)
 			goto out;
 		ms = ipvs->ms;
@@ -1862,7 +1862,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 			ms->ipvs = ipvs;
 		}
 	} else {
-		array = kzalloc(count * sizeof(struct task_struct *),
+		array = kcalloc(count, sizeof(struct task_struct *),
 				GFP_KERNEL);
 		if (!array)
 			goto out;
-- 
2.7.0.rc3.207.g0ac5344

