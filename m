From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.20
Date: Tue, 10 Feb 2015 06:31:41 +0100
Message-ID: <20150210053141.GA3248@salvia>
References: <1423459508-15517-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423459508-15517-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Mon, Feb 09, 2015 at 02:25:07PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v3.20
> 
> This patch prevents the kernel getting into a situation whereby a
> real-server may not be removed from a heterogeneous IPVS virtual server.
> 
> This problem was introduced by  bc18d37f676f ("ipvs: Allow heterogeneous
> pools now that we support them") in v3.18. This patch seems appropriate
> for stable and I have checked that it applies cleanly to both v3.19 and
> v3.18.6.
> 
> 
> The following changes since commit 42b5212fee4f57907e9415b18fe19c13e65574bc:
> 
>   xen-netback: stop the guest rx thread after a fatal error (2015-02-02 19:39:04 -0800)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.20

Pulled, thanks Simon.
