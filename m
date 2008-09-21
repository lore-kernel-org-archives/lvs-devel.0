From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix unused label warning
Date: Mon, 22 Sep 2008 09:57:51 +1000
Message-ID: <20080921235750.GD1342@verge.net.au>
References: <20080916071318.939200044@vergenet.net> <20080916071610.390873215@vergenet.net> <alpine.LNX.2.00.0809201142570.22510@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809201142570.22510@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Sat, Sep 20, 2008 at 11:48:33AM +0200, Sven Wegener wrote:
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  net/ipv4/ipvs/ip_vs_ctl.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> Simon, small fixup patch for your patch. It wasn't obvious from the patch, 
> that now only the IPV6 support needs this label.

Thanks, sorry for messing that up.

Applied

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

