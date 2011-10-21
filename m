From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS
Date: Fri, 21 Oct 2011 09:27:15 +0200
Message-ID: <20111021072715.GA842@1984>
References: <1319160783-28422-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1319160783-28422-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

On Fri, Oct 21, 2011 at 10:33:01AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider pulling the following to get compile fix
> and cleanup patches from Krzysztof Wilczynski.
> 
> The following changes since commit 2ca5b853f1dd81c605ddc8a55e06bdad85636597:
> 
>   netfilter: export NAT definitions through linux/netfilter_ipv4/nf_nat.h (2011-10-11 03:32:34 +0200)
> 
> are available in the git repository at:
>   git://github.com/horms/ipvs-next.git master

Pulled, thanks.

http://1984.lsi.us.es/git/?p=net-next/.git;a=shortlog;h=refs/heads/nf-next

> Krzysztof Wilczynski (2):
>       ipvs: Remove unused variable "cs" from ip_vs_leave function.
>       ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.

Strange, I have all IPVS configs enabled here and I didn't hit this error.
