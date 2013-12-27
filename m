From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 1/2] netfilter: WARN about wrong usage of sequence number adjustments
Date: Fri, 27 Dec 2013 12:37:36 +0900
Message-ID: <1388115457-9873-2-git-send-email-horms@verge.net.au>
References: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Since commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
number adjustments usuable without NAT), the sequence number extension
is dynamically allocated.

Instead of dying, give a WARN splash, in case of wrong usage of the
seqadj code, e.g. when forgetting to allocate via nfct_seqadj_ext_add().

Wrong usage have been seen in the IPVS code path.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/nf_conntrack_seqadj.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index 17c1bcb..b2d38da 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -36,6 +36,11 @@ int nf_ct_seqadj_set(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 	if (off == 0)
 		return 0;
 
+	if (unlikely(!seqadj)) {
+		WARN(1, "Wrong seqadj usage, missing nfct_seqadj_ext_add()\n");
+		return 0;
+	}
+
 	set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 
 	spin_lock_bh(&ct->lock);
-- 
1.8.4

