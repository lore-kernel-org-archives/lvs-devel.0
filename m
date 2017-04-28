From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] ipvs: remove unused function ip_vs_set_state_timeout
Date: Fri, 28 Apr 2017 12:11:58 +0200
Message-ID: <20170428101159.9810-2-horms@verge.net.au>
References: <20170428101159.9810-1-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493374324; bh=S/k+keJlHh4YLG4ZmCwFGDE39iIPNBfK/KUsMWOBpLY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=kWW/jr/Gtsy3530iE5oa2EwHfqea56ZB+y/I8azqDvrSr9qQPDgcYxIfmCzHC0j3k
         NPKF0QFHM/pE0DVyc11NUqe3T0G8Gbcm0umsWPAajojWz2a6iQdp2H13vQ8rkAD09h
         QP0T4l4twgl5Hab+tZxhNt6N5ELkLcmawt7dM1hI=
In-Reply-To: <20170428101159.9810-1-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Aaron Conole <aconole@bytheb.org>, Simon Horman <horms@verge.net.au>

From: Aaron Conole <aconole@bytheb.org>

There are no in-tree callers of this function and it isn't exported.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |  2 --
 net/netfilter/ipvs/ip_vs_proto.c | 22 ----------------------
 2 files changed, 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 632082300e77..4f4f786255ef 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1349,8 +1349,6 @@ int ip_vs_protocol_init(void);
 void ip_vs_protocol_cleanup(void);
 void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
 int *ip_vs_create_timeout_table(int *table, int size);
-int ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			    const char *name, int to);
 void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 			       const struct sk_buff *skb, int offset,
 			       const char *msg);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8ae480715cea..ca880a3ad033 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -193,28 +193,6 @@ ip_vs_create_timeout_table(int *table, int size)
 }
 
 
-/*
- *	Set timeout value for state specified by name
- */
-int
-ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			const char *name, int to)
-{
-	int i;
-
-	if (!table || !name || !to)
-		return -EINVAL;
-
-	for (i = 0; i < num; i++) {
-		if (strcmp(names[i], name))
-			continue;
-		table[i] = to * HZ;
-		return 0;
-	}
-	return -ENOENT;
-}
-
