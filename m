From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Mon, 13 Dec 2010 06:48:06 +0900
Message-ID: <20101212214806.GF7914@verge.net.au>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tinggong Wang <wangtinggong@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

[ CCed Hans Schillstrom and Julian Anastasov ]

On Sun, Dec 12, 2010 at 07:42:29PM +0800, Tinggong Wang wrote:
> Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 7632a17..2b6b0cb 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
>  	char *p;
>  	int i;
>  
> -	if (buflen < SYNC_MESG_HEADER_LEN) {
> -		IP_VS_ERR_RL("sync message header too short\n");
> -		return;
> -	}
> -
>  	/* Convert size back to host byte order */
>  	m->size = ntohs(m->size);
>  
> @@ -823,6 +818,14 @@ static int sync_thread_backup(void *data)
>  				break;
>  			}
>  
> +			/* throw invalid data before local_bh_disable,
> +			 * so performance won't be downgraded by it
> +			 */
> +			if (len < SYNC_MESG_HEADER_LEN) {
> +				IP_VS_ERR_RL("sync message header too short\n");
> +				continue;
> +			}
> +
>  			/* disable bottom half, because it accesses the data
>  			   shared by softirq while getting/creating conns */
>  			local_bh_disable();
> -- 
> 1.7.2.3
> 

Could you explain the motivation for this change?

