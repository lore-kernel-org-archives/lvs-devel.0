From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] Second Round of IPVS Fixes for v4.7
Date: Mon, 11 Jul 2016 12:04:42 +0200
Message-ID: <20160711100442.GB6412@salvia>
References: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Jul 07, 2016 at 08:30:21PM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this IPVS fix for v4.7.
> 
> The fix from Quentin Armitage allows the backup sync daemon to
> be bound to a link-local mcast IPv6 address as is already the case
> for IPv4.
> 
> The following changes since commit 62131e5d735226074cba53095545d76b491e5003:
> 
>   netfilter: nft_meta: set skb->nf_trace appropriately (2016-06-23 14:15:33 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v4.7

Also pulled, thanks.
