From: Simon Horman <horms@verge.net.au>
Subject: Re: [net PATCH 0/2] Fixing OOPSes in seqadj code
Date: Tue, 17 Dec 2013 10:36:37 +0900
Message-ID: <20131217013637.GI27171@verge.net.au>
References: <20131213214023.14478.74738.stgit@dragon>
 <20131216160840.22853.39918.stgit@dragon>
 <alpine.LFD.2.11.1312162308120.2063@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1312162308120.2063@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

On Mon, Dec 16, 2013 at 11:11:51PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 16 Dec 2013, Jesper Dangaard Brouer wrote:
> 
> > The following series address issues with netfilter conntrack sequence
> > number adjustments, introduced with commit 41d73ec053d2 (netfilter:
> > nf_conntrack: make sequence number adjustments usuable without NAT).
> > 
> >  Patch1: give us a WARN splash when using seqadj incorrectly
> > 
> >  Patch2: fixes a wrong usage of seqadj in IPVS code
> 
> 	Both patches look good to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> > I'm not sure, which maintainer will take these fixes?!?
> 
> 	I think, Simon can take them, if there are no
> objections...

I have no objections.
I'll wait a day to see if anyone else does.

> 
> > Jesper Dangaard Brouer (2):
> >       ipvs: correct usage/allocation of seqadj ext in ipvs
> >       netfilter: WARN about wrong usage of sequence number adjustments
> > 
> > 
> >  net/netfilter/ipvs/ip_vs_nfct.c     |    6 ++++++
> >  net/netfilter/nf_conntrack_seqadj.c |    5 +++++
> >  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
