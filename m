From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net 4/4] ipvs: stats should not depend on CPU 0
Date: Fri, 30 Aug 2013 10:17:51 +0900
Message-ID: <20130830011751.GB8360@verge.net.au>
References: <1377707376-4362-1-git-send-email-ja@ssi.bg>
 <1377707376-4362-5-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377707376-4362-5-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

[ Cc: Hans Schillstrom ]

On Wed, Aug 28, 2013 at 07:29:36PM +0300, Julian Anastasov wrote:
> When reading percpu stats we need to properly reset
> the sum when CPU 0 is not present in the possible mask.

It seems reasonable to me that this condition could occur,
though I am not aware of a specific case where that is so.

Can I confirm that this problem was introduced by
b17fc9963f837ef1 ("IPVS: netns, ip_vs_stats and its procfs")?

> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_est.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 6bee6d0..1425e9a 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -59,12 +59,13 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
>  				 struct ip_vs_cpu_stats __percpu *stats)
>  {
>  	int i;
> +	bool add = false;
>  
>  	for_each_possible_cpu(i) {
>  		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
>  		unsigned int start;
>  		__u64 inbytes, outbytes;
> -		if (i) {
> +		if (add) {
>  			sum->conns += s->ustats.conns;
>  			sum->inpkts += s->ustats.inpkts;
>  			sum->outpkts += s->ustats.outpkts;
> @@ -76,6 +77,7 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
>  			sum->inbytes += inbytes;
>  			sum->outbytes += outbytes;
>  		} else {
> +			add = true;
>  			sum->conns = s->ustats.conns;
>  			sum->inpkts = s->ustats.inpkts;
>  			sum->outpkts = s->ustats.outpkts;
> -- 
> 1.7.3.4
> 
