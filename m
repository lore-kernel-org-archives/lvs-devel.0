From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 01/34] net: add skb_dst_set_noref_force
Date: Tue, 2 Apr 2013 10:11:32 +0900
Message-ID: <20130402011132.GF14785@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
 <1364530311-11512-2-git-send-email-horms@verge.net.au>
 <20130401120644.GA4882@localhost>
 <20130401.125733.1045325402548119287.davem@davemloft.net>
 <20130401224230.GA12356@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130401224230.GA12356@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: David Miller <davem@davemloft.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Tue, Apr 02, 2013 at 12:42:30AM +0200, Pablo Neira Ayuso wrote:
> On Mon, Apr 01, 2013 at 12:57:33PM -0400, David Miller wrote:
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > Date: Mon, 1 Apr 2013 14:06:44 +0200
> > 
> > > Hi Simon,
> > > 
> > > On Fri, Mar 29, 2013 at 01:11:18PM +0900, Simon Horman wrote:
> > >> From: Julian Anastasov <ja@ssi.bg>
> > >> 
> > >> Rename skb_dst_set_noref to __skb_dst_set_noref and
> > >> add force flag as suggested by David Miller. The new wrapper
> > >> skb_dst_set_noref_force will force dst entries that are not
> > >> cached to be attached as skb dst without taking reference
> > >> as long as provided dst is reclaimed after RCU grace period.
> > >> 
> > >> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > >> Signed-off by: Hans Schillstrom <hans@schillstrom.com>
> > >> Signed-off-by: Simon Horman <horms@verge.net.au>
> > > 
> > > I think was acked by David, right?
> > 
> > It was:
> > 
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> I have added this missing Acked-by to the patch. Simon, you'll have to
> rebase your tree, sorry.

Thanks. Sorry for the mix up.
