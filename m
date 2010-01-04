From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Mon, 04 Jan 2010 14:59:47 +0100
Message-ID: <4B41F453.1090802@trash.net>
References: <20091229015822.GF10172@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20091229015822.GF10172@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Arjan van de Ven <arjan@linux.intel.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>

Simon Horman wrote:
> From: Arjan van de Ven <arjan@linux.intel.com>
> 
> ipvs: Add boundary check on ioctl arguments
> 
> The ipvs code has a nifty system for doing the size of ioctl command
> copies; it defines an array with values into which it indexes the cmd
> to find the right length.
> 
> Unfortunately, the ipvs code forgot to check if the cmd was in the
> range that the array provides, allowing for an index outside of the
> array, which then gives a "garbage" result into the length, which
> then gets used for copying into a stack buffer.
> 
> Fix this by adding sanity checks on these as well as the copy size.
> 
> [ horms@verge.net.au: adjusted limit to IP_VS_SO_GET_MAX ]
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> ---
> 
>  net/netfilter/ipvs/ip_vs_ctl.c |   14 +++++++++++++-
>  1 files changed, 13 insertions(+), 1 deletions(-)
> 
> Hi Arjen,
> 
> this is the 4th response to your patch. I am guessing the previous
> ones didn't reach you for some reason. And I guess this one wont
> for the same reason.
> 
> I agree with Julian's assessment that your patch shouldn't be
> necessary, but on the other hand I think that the checks are
> reasonable. Your original patch made checks of the form of
> "cmd > IP_VS_SO_GET_MAX + 1". I have updated this to
> "cmd > IP_VS_SO_GET_MAX", as suggested by Julian, as the optmax
> elements of struct nf_sockopt_ops set a non-inclusive range.
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/00852.html
> 
> Index: net-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c

As a bugfix, this seems more appropriate for net-2.6.git. Please let
me know which tree you want me to apply this to.
