From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 6/8] net/netfilter/ipvs/ip_vs_ftp.c: Use standardized
 format in sprintf
Date: Wed, 6 Jan 2010 13:34:16 +1100
Message-ID: <20100106023416.GB18557@verge.net.au>
References: <cover.1262726222.git.joe@perches.com>
 <da25f48ee7959e83a18e3705c223c8619e508bf4.1262726222.git.joe@perches.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <da25f48ee7959e83a18e3705c223c8619e508bf4.1262726222.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

On Tue, Jan 05, 2010 at 05:20:18PM -0800, Joe Perches wrote:
> Use the same format string as net/ipv4/netfilter/nf_nat_ftp.c
> to encode an ipv4 address and port.
> 
> Both uses should be a single common function.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_ftp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 33e2c79..73f38ea 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -208,7 +208,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  		 */
>  		from.ip = n_cp->vaddr.ip;
>  		port = n_cp->vport;
> -		sprintf(buf, "%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
> +		sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
>  			(ntohs(port)>>8)&255, ntohs(port)&255);
>  		buf_len = strlen(buf);
>  
> -- 
> 1.6.6.rc0.57.gad7a
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
