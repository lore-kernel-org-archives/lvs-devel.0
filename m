From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next 0/2] IPVS Updates for v4.10
Date: Sun, 4 Dec 2016 20:46:16 +0100
Message-ID: <20161204194616.GA4505@salvia>
References: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Nov 15, 2016 at 10:01:41AM +0100, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS for v4.10.
> 
> * Decrement the IP ttl in all the modes in order to prevent infinite
>   route loops. Thanks to Dwip Banerjee.
> * Use IS_ERR_OR_NULL macro. Clean-up from Gao Feng.
> 
> 
> The following changes since commit 7d384846b9987f7b611357adf3cdfecfdcf0c402:
> 
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next (2016-11-13 22:41:25 -0500)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.10

Pulled, thanks Simon.
