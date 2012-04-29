From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/5] ipvs: null check of net->ipvs in lblc(r) shedulers
Date: Mon, 30 Apr 2012 01:43:01 +0200
Message-ID: <20120429234301.GA4790@1984>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
 <1335488039-13471-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335488039-13471-4-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Apr 27, 2012 at 09:53:57AM +0900, Simon Horman wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> Avoid crash when registering shedulers after
> the IPVS core initialization for netns fails. Do this by
> checking for present core (net->ipvs).
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Julian Anastasov <ja@ssi.bg>

This incomplete tag has slipped through, right?

Looking at the archive, I don't see any comment from Julian on this,
so I'll just remove it from the patch description.

I'll fix this minor nitppick myself. No need to resend. But you'll
have to rebase your tree, sorry.
