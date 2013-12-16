From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH 1/2] netfilter: WARN about wrong usage of sequence number
	adjustments
Date: Mon, 16 Dec 2013 17:09:41 +0100
Message-ID: <20131216160941.22853.46561.stgit@dragon>
References: <20131216160840.22853.39918.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131216160840.22853.39918.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Since commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
number adjustments usuable without NAT), the sequence number extension
is dynamically allocated.

Instead of dying, give a WARN splash, in case of wrong usage of the
seqadj code, e.g. when forgetting to allocate via nfct_seqadj_ext_add().

Wrong usage have been seen in the IPVS code path.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/netfilter/nf_conntrack_seqadj.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

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

