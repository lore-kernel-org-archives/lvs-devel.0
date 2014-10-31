From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.18
Date: Fri, 31 Oct 2014 12:47:09 +0100
Message-ID: <20141031114709.GA4510@salvia>
References: <1414458334-22479-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414458334-22479-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Oct 28, 2014 at 10:05:33AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v3.18.
> 
> It fixes a null-pointer dereference that may occur when logging
> errors.
> 
> This problem was introduced by 4a4739d56b0 ("ipvs: Pull out
> crosses_local_route_boundary logic") in v3.17-rc5. As such I would
> also like it considered for 3.17-stable.
> 
> 
> The following changes since commit 7965ee93719921ea5978f331da653dfa2d7b99f5:
> 
>   netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops() (2014-10-27 22:17:46 +0100)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.18

Pulled, thanks Simon.
