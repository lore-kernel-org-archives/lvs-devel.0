From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL 0/1] IPVS Fixes for v4.12
Date: Mon, 15 May 2017 18:45:34 +0200
Message-ID: <20170515164534.GA3918@salvia>
References: <1494236923-8015-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1494236923-8015-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Mon, May 08, 2017 at 11:48:42AM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this fix to IPVS for v4.12.
> 
> * It is a fix from Julian Anastasov to only SNAT SNAT packet replies only for
>   NATed connections
> 
> 
> My understanding is that this fix is appropriate for 4.9.25, 4.10.13, 4.11
> as well as the nf tree. Julian has separately posted backports for other
> -stable kernels; please see:
> 
> * [PATCH 3.2.88,3.4.113 -stable 1/3] ipvs: SNAT packet replies only for
>         NATed connections
> * [PATCH 3.10.105,3.12.73,3.16.43,4.1.39 -stable 2/3] ipvs: SNAT packet
>         replies only for NATed connections 
> * [PATCH 4.4.65 -stable 3/3] ipvs: SNAT packet replies only for NATed
>         connections

Pulled, thanks.

Please, resubmit your stable backport patches once this patch hits
Linus' linux.git tree, Cc: stable@lists.kernel.org, I'll be glad to
ack them.
