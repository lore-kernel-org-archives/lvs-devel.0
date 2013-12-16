From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH 2/2] ipvs: correct usage/allocation of seqadj ext in ipvs
Date: Mon, 16 Dec 2013 17:09:47 +0100
Message-ID: <20131216160947.22853.1454.stgit@dragon>
References: <20131216160840.22853.39918.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20131216160840.22853.39918.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

The IPVS FTP helper ip_vs_ftp could trigger an OOPS in nf_ct_seqadj_set,
after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence number
adjustments usuable without NAT).

This is because, the seqadj ext is now allocated dynamically, and the
IPVS code didn't handle this situation.  Fix this in the IPVS nfct
code by invoking the alloc function nfct_seqadj_ext_add().

Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/netfilter/ipvs/ip_vs_nfct.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index d5f4151..5882bbf 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -62,6 +62,7 @@
 #include <net/ip_vs.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -96,6 +97,11 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
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
