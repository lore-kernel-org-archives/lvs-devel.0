From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] Second Round of IPVS Fixes for v3.18
Date: Thu, 13 Nov 2014 12:38:18 +0100
Message-ID: <20141113113818.GA7570@salvia>
References: <1415758920-32578-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415758920-32578-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Nov 12, 2014 at 11:21:59AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v3.18.
> 
> It fixes handling of skb->sk which may cause incorrect handling
> of connections from a local process.
> 
> This problem was introduced in its current form by 8052ba292559f907e
> ("ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding") in
> v3.18-rc1.

Pulled, thanks Simon.

> I believe it also exists in a different form in older kernels.
> No fix for that is available at this time.

AFAIK -stable also accepts backports if there's a clear relation
between this original patch in mainstream and the backported version.
