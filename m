From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 2/2] ipvs: correct usage/allocation of seqadj ext in ipvs
Date: Fri, 27 Dec 2013 12:37:37 +0900
Message-ID: <1388115457-9873-3-git-send-email-horms@verge.net.au>
References: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Jesper Dangaard Brouer <brouer@redhat.com>

The IPVS FTP helper ip_vs_ftp could trigger an OOPS in nf_ct_seqadj_set,
after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence number
adjustments usuable without NAT).

This is because, the seqadj ext is now allocated dynamically, and the
IPVS code didn't handle this situation.  Fix this in the IPVS nfct
code by invoking the alloc function nfct_seqadj_ext_add().

Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_nfct.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index c8beafd..5a355a4 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -63,6 +63,7 @@
 #include <net/ip_vs.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -97,6 +98,11 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return;
 
+	/* Applications may adjust TCP seqs */
+	if (cp->app && nf_ct_protonum(ct) == IPPROTO_TCP &&
+	    !nfct_seqadj(ct) && !nfct_seqadj_ext_add(ct))
+		return;
+
 	/*
 	 * The connection is not yet in the hashtable, so we update it.
 	 * CIP->VIP will remain the same, so leave the tuple in
-- 
1.8.4
