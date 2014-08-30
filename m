From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] Second round of IPVS fixes for v3.17
Date: Sat, 30 Aug 2014 13:08:45 +0200
Message-ID: <20140830110845.GB4601@salvia>
References: <1409191468-28013-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409191468-28013-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Aug 28, 2014 at 11:04:27AM +0900, Simon Horman wrote:
> This fix resolves a problem with conflicting hooks whereby DNAT support for
> the local server would drop outgoing IPv4 packets if the kernel was
> compiled CONFIG_IP_VS_IPV6=y.
> 
> This problem dates back to v3.6.37 when the feature in question was added.
> 
> I would like this fix considered for -stable.

Enqueue for -stable.

> The following changes since commit ea1d5d7755a3e556de78cc757d1895d5c7180548:
> 
>   ipvs: properly declare tunnel encapsulation (2014-08-27 14:31:56 +0900)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.17

Pulled, thanks Simon.
