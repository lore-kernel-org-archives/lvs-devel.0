From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: use div_s64 for signed division
Date: Fri, 16 Dec 2022 11:10:41 +0100
Message-ID: <Y5xEITNJkry8uy/h@salvia>
References: <20221215170324.2579685-1-arnd@kernel.org>
 <e1fea67-7425-f13d-e5bd-3d80d9a8afb8@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e1fea67-7425-f13d-e5bd-3d80d9a8afb8@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Arnd Bergmann <arnd@kernel.org>, Simon Horman <horms@verge.net.au>, Arnd Bergmann <arnd@arndb.de>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Jiri Wiesner <jwiesner@suse.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

Hi Julian,

On Thu, Dec 15, 2022 at 09:01:59PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 15 Dec 2022, Arnd Bergmann wrote:
> 
> > From: Arnd Bergmann <arnd@arndb.de>
> > 
> > do_div() is only well-behaved for positive numbers, and now warns
> > when the first argument is a an s64:
> > 
> > net/netfilter/ipvs/ip_vs_est.c: In function 'ip_vs_est_calc_limits':
> > include/asm-generic/div64.h:222:35: error: comparison of distinct pointer types lacks a cast [-Werror]
> >   222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
> >       |                                   ^~
> > net/netfilter/ipvs/ip_vs_est.c:694:17: note: in expansion of macro 'do_div'
> >   694 |                 do_div(val, loops);
> 
> 	net-next already contains fix for this warning
> and changes val to u64.

Arnd's patch applies fine on top of net-next, maybe he is addressing
something else?

> > Convert to using the more appropriate div_s64(), which also
> > simplifies the code a bit.
> > 
> > Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  net/netfilter/ipvs/ip_vs_est.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> > index ce2a1549b304..dbc32f8cf1f9 100644
> > --- a/net/netfilter/ipvs/ip_vs_est.c
> > +++ b/net/netfilter/ipvs/ip_vs_est.c
> > @@ -691,15 +691,13 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
> >  		}
> >  		if (diff >= NSEC_PER_SEC)
> >  			continue;
> > -		val = diff;
> > -		do_div(val, loops);
> > +		val = div_s64(diff, loops);
> 
> 	On CONFIG_X86_32 both versions execute single divl
> for our case but div_s64 is not inlined. I'm not expert in
> this area but if you think div_u64 is more appropriate then
> post another patch. Note that now val is u64 and
> min_est is still s32 (can be u32).
> 
> >  		if (!min_est || val < min_est) {
> >  			min_est = val;
> >  			/* goal: 95usec per chain */
> >  			val = 95 * NSEC_PER_USEC;
> >  			if (val >= min_est) {
> > -				do_div(val, min_est);
> > -				max = (int)val;
> > +				max = div_s64(val, min_est);
> >  			} else {
> >  				max = 1;
> >  			}
> > -- 
> > 2.35.1
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
