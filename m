From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net PATCH 0/2] Fixing OOPSes in seqadj code
Date: Mon, 16 Dec 2013 23:11:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1312162308120.2063@ja.home.ssi.bg>
References: <20131213214023.14478.74738.stgit@dragon> <20131216160840.22853.39918.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131216160840.22853.39918.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Mon, 16 Dec 2013, Jesper Dangaard Brouer wrote:

> The following series address issues with netfilter conntrack sequence
> number adjustments, introduced with commit 41d73ec053d2 (netfilter:
> nf_conntrack: make sequence number adjustments usuable without NAT).
> 
>  Patch1: give us a WARN splash when using seqadj incorrectly
> 
>  Patch2: fixes a wrong usage of seqadj in IPVS code

	Both patches look good to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

> I'm not sure, which maintainer will take these fixes?!?

	I think, Simon can take them, if there are no
objections...

> Jesper Dangaard Brouer (2):
>       ipvs: correct usage/allocation of seqadj ext in ipvs
>       netfilter: WARN about wrong usage of sequence number adjustments
> 
> 
>  net/netfilter/ipvs/ip_vs_nfct.c     |    6 ++++++
>  net/netfilter/nf_conntrack_seqadj.c |    5 +++++
>  2 files changed, 11 insertions(+), 0 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>
