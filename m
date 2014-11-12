From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.18
Date: Wed, 12 Nov 2014 11:24:07 +0900
Message-ID: <20141112022407.GF11597@verge.net.au>
References: <1414458334-22479-1-git-send-email-horms@verge.net.au>
 <20141104175717.GA25184@salvia>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141104175717.GA25184@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Nov 04, 2014 at 06:57:17PM +0100, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Tue, Oct 28, 2014 at 10:05:33AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider this fix for v3.18.
> > 
> > It fixes a null-pointer dereference that may occur when logging
> > errors.
> > 
> > This problem was introduced by 4a4739d56b0 ("ipvs: Pull out
> > crosses_local_route_boundary logic") in v3.17-rc5. As such I would
> > also like it considered for 3.17-stable.
> 
> Regarding your request to pass this to 3.17-stable. According to git
> am and my scripts:
> 
> 3d53666 ipvs: Avoid null-pointer deref in debug code
> 
> doesn't apply cleanly 3.17.x. Please re-check and send me a backport if
> you want to see this in 3.17.x. Let me know, sorry.

Sorry for creating some confusion here and sorry for not
cleaning it up earlier.

On further inspection I believe that 4a4739d56b0 was included
in v3.18-rc1 rather than v3.17. So this fix is not relevant to
v3.17 after all.
