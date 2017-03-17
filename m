From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL 0/5] IPVS Updates for v4.12
Date: Fri, 17 Mar 2017 12:39:32 +0100
Message-ID: <20170317113932.GA3099@salvia>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Mar 16, 2017 at 01:43:10PM +0100, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS for v4.12.
> 
> * Update sysctl documentation
> * Remove unnecessary printk in __ip_vs_init
> 
> The following changes since commit 03e5fd0e9bcc1f34b7a542786b34b8f771e7c260:
> 
>   netfilter: nft_set_rbtree: use per-set rwlock to improve the scalability (2017-03-13 19:30:43 +0100)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.12

Pulled, thanks Simon!
