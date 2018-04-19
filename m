From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/5] netfilter: ipvs: Keep latest weight of destination
Date: Thu, 19 Apr 2018 10:56:11 +0200
Message-ID: <20180419085614.7437-3-horms@verge.net.au>
References: <20180419085614.7437-1-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128186; bh=z7BueV0I7xqWZRCfGCUh+nBXGeiTcV63FL8ClYygRPg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=DE8Yj6MvS6SnUpOrzen9gWV38Z8L/taSjJJrNHqBQJwArJ2dRrip5hY2x/YQvlOZC
         zLyn5UpntIaZ5Bu1536XU5cnExnVK4V0hIYp/9fsrY3DnMn0NLWFlpL9T0gOYCdqU/
         ifAG+laSwO+sHvKGJWHuSDQfyEyJ8rR3P4/32At0=
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Inju Song <inju.song@navercorp.com>, Simon Horman <horms@verge.net.au>

From: Inju Song <inju.song@navercorp.com>

The hashing table in scheduler such as source hash or maglev hash
should ignore the changed weight to 0 and allow changing the weight
from/to non-0 values. So, struct ip_vs_dest needs to keep weight
with latest non-0 weight.

Signed-off-by: Inju Song <inju.song@navercorp.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            | 1 +
 net/netfilter/ipvs/ip_vs_ctl.c | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index eb0bec043c96..0ac795b41ab8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -668,6 +668,7 @@ struct ip_vs_dest {
 	volatile unsigned int	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
+	atomic_t		last_weight;	/* server latest weight */
 
 	refcount_t		refcnt;		/* reference counter */
 	struct ip_vs_stats      stats;          /* statistics */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5ebde4b15810..b91bb70ece92 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -821,6 +821,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	if (add && udest->af != svc->af)
 		ipvs->mixed_address_family_dests++;
 
+	/* keep the last_weight with latest non-0 weight */
+	if (add || udest->weight != 0)
+		atomic_set(&dest->last_weight, udest->weight);
+
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
 	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
-- 
2.11.0

