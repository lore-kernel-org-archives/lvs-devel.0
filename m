From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/5] IPVS remove unused var from migration to netns
Date: Wed, 15 Jun 2011 08:43:18 +0900
Message-ID: <1308095001-21002-3-git-send-email-horms@verge.net.au>
References: <1308095001-21002-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1308095001-21002-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Remove variable ctl_key from struct netns_ipvs,
it's a leftover from early netns work.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 481f856..34a6fa8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -836,8 +836,6 @@ struct netns_ipvs {
 	int			num_services;    /* no of virtual services */
 
 	rwlock_t		rs_lock;         /* real services table */
-	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
-	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
 	/* Trash for destinations */
 	struct list_head	dest_trash;
 	/* Service counters */
-- 
1.7.4.4

