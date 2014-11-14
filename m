From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf] Second Round of IPVS Fixes for v3.18
Date: Fri, 14 Nov 2014 10:59:02 +0900
Message-ID: <20141114015902.GB28021@verge.net.au>
References: <1415758920-32578-1-git-send-email-horms@verge.net.au>
 <20141113113818.GA7570@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141113113818.GA7570@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Nov 13, 2014 at 12:38:18PM +0100, Pablo Neira Ayuso wrote:
> On Wed, Nov 12, 2014 at 11:21:59AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider this fix for v3.18.
> > 
> > It fixes handling of skb->sk which may cause incorrect handling
> > of connections from a local process.
> > 
> > This problem was introduced in its current form by 8052ba292559f907e
> > ("ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding") in
> > v3.18-rc1.
> 
> Pulled, thanks Simon.
> 
> > I believe it also exists in a different form in older kernels.
> > No fix for that is available at this time.
> 
> AFAIK -stable also accepts backports if there's a clear relation
> between this original patch in mainstream and the backported version.

Thanks. I will see about making one.
