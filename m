From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf 0/2] IPVS Fixes for v3.13
Date: Sat, 28 Dec 2013 12:16:43 +0100
Message-ID: <20131228111643.GA4451@localhost>
References: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Dec 27, 2013 at 12:37:35PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following fixes for IPVS for v3.13.
> Or alternatively for v3.14.
> 
> This pull-request consists of two patches from Jesper Dangaard Brouer to
> resolve sequence number problems introduced by 41d73ec053d2 (netfilter:
> nf_conntrack: make sequence number adjustments usuable without NAT) in
> v3.11-rc7.
> 
> I believe they are -stable candidates back to v3.11.
> 
> 
> The following changes since commit 443d20fd188208aa4df2118ad49f9168e411016d:
> 
>   netfilter: nf_ct_timestamp: Fix BUG_ON after netns deletion (2013-12-20 14:58:29 +0100)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.13

Pulled, thanks Simon.
