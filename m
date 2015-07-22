From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf 0/6] IPVS Fixes for v4.2
Date: Wed, 22 Jul 2015 21:52:43 +0200
Message-ID: <20150722195243.GA3989@salvia>
References: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Simon,

On Thu, Jul 16, 2015 at 11:14:07AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix for v4.2.
> For reasons that are not clear to me it is a bumper crop.
> 
> It seems to me that they are all relevant to stable.
> Please let me know if you need my help to get the fixes into stable.

Several comments below regarding -stable.

> * ipvs: fix ipv6 route unreach panic
> 
>   This problem appears to be present since IPv6 support was added to
>   IPVS in v2.6.28.
> 
> * ipvs: skb_orphan in case of forwarding
> 
>   This appears to resolve a problem resulting from a side effect of
>   41063e9dd119 ("ipv4: Early TCP socket demux.") which was included in v3.6.
> 
> * ipvs: do not use random local source address for tunnels
> 
>   This appears to resolve a problem introduced by
>   026ace060dfe ("ipvs: optimize dst usage for real server") in v3.10.
> 
> * ipvs: fix crash if scheduler is changed
> 
>   This appears to resolve a problem introduced by
>   ceec4c381681 ("ipvs: convert services to rcu") in v3.10.
> 
>   Julian has provided backports of the fix:
>   * [PATCHv2 3.10.81] ipvs: fix crash if scheduler is changed
>     http://www.spinics.net/lists/lvs-devel/msg04008.html
>   * [PATCHv2 3.12.44,3.14.45,3.18.16,4.0.6] ipvs: fix crash if scheduler is changed
>     http://www.spinics.net/lists/lvs-devel/msg04007.html

OK, I have enqueued these from Julian.

Next time, it would be easier for me if I can fetch these from
patchwork. So either you request a patchwork space for IPVS to Jeremy
Kerr or you Cc netfilter-devel including -stable in the prefix.

>   Please let me know how you would like to handle guiding these
>   backports into stable.
> 
> * ipvs: fix crash with sync protocol v0 and FTP
> 
>   This appears to resolve a problem introduced by
>   749c42b620a9 ("ipvs: reduce sync rate with time thresholds") in v3.5

These three patches:

* ipvs: fix ipv6 route unreach panic
* ipvs: do not use random local source address for tunnels
* ipvs: fix crash with sync protocol v0 and FTP

apply cleanly via git-am to:

v3.10.x, 3.12.x, 3.14.x, 3.18.x, 4.0.x, 4.1.x

but I didn't compile test, so if you want to have this in -stable, it
would be good to validate that all dependencies are in place.

Regarding this one:

* ipvs: skb_orphan in case of forwarding

This only applies cleanly to 4.1.x here.

> The following changes since commit 484836ec2de24d9a7c6471f022b746d947698725:
> 
>   netfilter: IDLETIMER: fix lockdep warning (2015-07-13 17:23:25 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.2

Pulled, thanks Simon.
