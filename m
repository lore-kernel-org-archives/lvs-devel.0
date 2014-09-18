From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL v2 00/15] Second Round of IPVS Updates for v3.18
Date: Thu, 18 Sep 2014 11:03:31 +0200
Message-ID: <20140918090331.GA24111@salvia>
References: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Sep 18, 2014 at 09:25:46AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS updates for v3.18.
> 
> I hope that v2 of this pull request addresses the issues you raised
> in v1. In particular "ipvs: use correct address family in scheduler logs"
> patch consolidates what was previously 7 patches. And I have provided
> a longer description: I hope the tone is closer to what you need.
> 
> This pull requests makes the following changes:
> 
> * Add simple weighted fail-over scheduler.
>   - Unlike other IPVS schedulers this offers fail-over rather than load
>     balancing. Connections are directed to the appropriate server based
>     solely on highest weight value and server availability.
>   - Thanks to Kenny Mathis
> 
> * Support IPv6 real servers in IPv4 virtual-services and vice versa
>   - This feature is supported in conjunction with the tunnel (IPIP)
>     forwarding mechanism. That is, IPv4 may be forwarded in IPv6 and
>     vice versa.
>   - The motivation for this is to allow more flexibility in the
>     choice of IP version offered by both virtual-servers and
>     real-servers as they no longer need to match: An IPv4 connection from an
>     end-user may be forwarded to a real-server using IPv6 and vice versa.
>   - Further work need to be done to support this feature in conjunction
>     with connection synchronisation. For now such configurations are
>     not allowed.
>   - This change includes update to netlink protocol, adding a new
>     destination address family attribute. And the necessary changes
>     to plumb this information throughout IPVS.
>   - Thanks to Alex Gartrell and Julian Anastasov
> 
> The following changes since commit 0bbe80e571c7b866afd92a98edd32a969467a7a9:
> 
>   netfilter: masquerading needs to be independent of x_tables in Kconfig (2014-09-12 09:40:18 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.18

Pulled, thanks a lot Simon.

