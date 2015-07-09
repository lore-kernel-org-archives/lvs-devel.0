From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix crash with sync protocol v0 and FTP
Date: Thu, 9 Jul 2015 10:39:00 +0900
Message-ID: <20150709013900.GA14843@verge.net.au>
References: <1436333493-20436-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436333493-20436-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Wed, Jul 08, 2015 at 08:31:33AM +0300, Julian Anastasov wrote:
> Fix crash in 3.5+ if FTP is used after switching
> sync_version to 0.
> 
> Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
>  Compiles also on 3.10.81, 3.12.44, 3.14.45, 3.18.16, 4.0.6, 4.1
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 19b9cce..150047c 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -612,7 +612,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
>  			pkts = atomic_add_return(1, &cp->in_pkts);
>  		else
>  			pkts = sysctl_sync_threshold(ipvs);
> -		ip_vs_sync_conn(net, cp->control, pkts);
> +		ip_vs_sync_conn(net, cp, pkts);
>  	}
>  }
>  
> -- 
> 1.9.3
> 
