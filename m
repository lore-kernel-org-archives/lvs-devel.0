From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.16
Date: Mon, 16 Jun 2014 13:11:15 +0200
Message-ID: <20140616111115.GA25199@localhost>
References: <1402645029-21756-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402645029-21756-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Jun 13, 2014 at 04:37:08PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> Please consider this IPVS fix for v3.16.
> 
> Fix for panic due use of tot_stats estimator outside of CONFIG_SYSCTL
> 
> It has been present since v3.6.39.
> 
> I would like this fix considered for -stable and I have checked that it
> applies cleanly on top of v3.15, v3.14.7, v3.12.22, v3.10.43 and v3.2.60.
> 
> 
> The following changes since commit f44a5f45f544561302e855e7bd104e5f506ec01b:
> 
>   ipvs: Fix panic due to non-linear skb (2014-05-26 10:22:46 +0900)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git ipvs-fixes-for-v3.16

Pulled, thanks Simon.
