From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH 0/2] Fixing OOPSes in seqadj code
Date: Mon, 16 Dec 2013 17:09:36 +0100
Message-ID: <20131216160840.22853.39918.stgit@dragon>
References: <20131213214023.14478.74738.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131213214023.14478.74738.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

The following series address issues with netfilter conntrack sequence
number adjustments, introduced with commit 41d73ec053d2 (netfilter:
nf_conntrack: make sequence number adjustments usuable without NAT).

 Patch1: give us a WARN splash when using seqadj incorrectly

 Patch2: fixes a wrong usage of seqadj in IPVS code

I'm not sure, which maintainer will take these fixes?!?

---

Jesper Dangaard Brouer (2):
      ipvs: correct usage/allocation of seqadj ext in ipvs
      netfilter: WARN about wrong usage of sequence number adjustments


 net/netfilter/ipvs/ip_vs_nfct.c     |    6 ++++++
 net/netfilter/nf_conntrack_seqadj.c |    5 +++++
 2 files changed, 11 insertions(+), 0 deletions(-)

