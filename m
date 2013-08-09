From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Use 64-bit comparisons (connections * weight) to
 avoid overflow
Date: Fri, 9 Aug 2013 12:02:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308091114230.1702@ja.ssi.bg>
References: <20130413064355.GB24319@hostway.ca> <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg> <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg> <20130523165836.GC436@hostway.ca> <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg> <20130524004318.GB14587@hostway.ca>
 <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg> <20130806024150.GA2393@hostway.ca> <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg> <20130808235434.GD7147@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130808235434.GD7147@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>


	Hello,

On Thu, 8 Aug 2013, Simon Kirby wrote:

> On Tue, Aug 06, 2013 at 09:45:24AM +0300, Julian Anastasov wrote:
> 
> > 	Reading your reply I see that the key issue you are
> > missing here is that the type of loh/doh matters, it should
> > match the type of atomic_read (and its signedness).
> 
> I'm not missing it, I was just trying to determine if the weight _should_
> be signed or not. :) I've never seen a negative weight documented
> anywhere.

	Weight should be >= 0, there is a
'server weight less than zero' error otherwise.

> > 	It is faster because your loh/doh are u32 and single mul is
> > generated while for u64*s32 we have u64=u32*s32 which obviously
> > is not implemented with single imul/mul. Our goal is single imul.
> 
> Ok, well, it turns out that GCC doesn't care and uses the signal register
> instruction form of imull anyway :) ->

	OK, so everything is as expected :)

> Ok, here is a patch (on current ipvs-next) that makes everything "int"
> and adds only a (__s64) cast in front of the loh and doh during
> multiplication to solve the original overflow problem.

	Very good, thanks!

> Simon-
> 
> 
> Some scheduling modules such as lblc and lblcr require weight to be as
> high as the maximum number of expected active connections. Meanwhile,
> commit b552f7e3a9524abcbcdf, which appeared in 2.6.39-rc, cleaned up the
> consideration of inactconns and activeconns to always count activeconns
> as 256 times more important than inactconns.
> 
> In our case, this exposed an integer overflow because we regularly exceed
> 3000 active connections to a real server. A weight of 3000 * 256 * 3000
> connections overflows the signed integer used when determining when to
> reschedule. The original factor of 50 did not overflow, though was close.
> 
> On amd64, this merely changes the multiply and comparison instructions to
> 64-bit. On x86, the 64-bit result is already present from imull, so only
> a few more comparisons are emitted.
> 
> Signed-off-by: Simon Kirby <sim@hostway.ca>

	Looks good to me, even if you add space
between "(__s64)" cast and "loh"/"doh".

	But after your fix for ip_vs_dest_conn_overhead
I see that also ip_vs_nq_dest_overhead and ip_vs_sed_dest_overhead
need to return int instead of unsigned int. I'll ack
v2 with these changes.

	Also, shorter subject is preferred, you can use
'ipvs: fix overflow on dest weight multiply' or something
else that you feel is better, '()' and '*' does not look
good in subject. Thanks!

> ---
>  include/net/ip_vs.h              |  2 +-
>  net/netfilter/ipvs/ip_vs_lblc.c  |  4 ++--
>  net/netfilter/ipvs/ip_vs_lblcr.c | 12 ++++++------
>  net/netfilter/ipvs/ip_vs_nq.c    |  6 +++---
>  net/netfilter/ipvs/ip_vs_sed.c   |  6 +++---
>  net/netfilter/ipvs/ip_vs_wlc.c   |  6 +++---
>  6 files changed, 18 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index f0d70f0..fe782ed 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1649,7 +1649,7 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
>  /* CONFIG_IP_VS_NFCT */
>  #endif
>  
> -static inline unsigned int
> +static inline int
>  ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
>  {
>  	/*

Regards

--
Julian Anastasov <ja@ssi.bg>
