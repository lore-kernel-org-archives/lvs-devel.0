From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next 00/21] Second Round of IPVS Updates for v3.18
Date: Tue, 16 Sep 2014 19:25:56 +0200
Message-ID: <20140916172556.GA21545@salvia>
References: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Simon,

On Tue, Sep 16, 2014 at 09:34:14AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS updates for v3.18.
> 
> * Add simple weighted failover scheduler
>   - Thanks to Kenny Mathis
> * Support v6 real servers in v4 pools and vice versa
>   - Thanks to Alex Gartrell and Julian Anastasov

I need a slightly larger description of this series.

I think you can merge patches 13-19 too. They are mostly two liners
with a similar description, so they naturally belong to the same
logical change. I would like to reduce the patchbomb pull request for
David.

Thanks.
