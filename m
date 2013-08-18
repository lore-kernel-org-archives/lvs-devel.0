From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] libipvs: Fix memory leak
Date: Sun, 18 Aug 2013 21:18:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308182115551.3222@ja.ssi.bg>
References: <1376844182-4437-1-git-send-email-rohara@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1376844182-4437-1-git-send-email-rohara@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org, Henrique Mecking <henriquemecking@gmail.com>, Simon Horman <horms@verge.net.au>


	Hello,

On Sun, 18 Aug 2013, Ryan O'Hara wrote:

> From: Henrique Mecking <henriquemecking@gmail.com>
> 
> If malloc fails, free allocated memory before returning NULL.
> 
> Signed-off-by: Ryan O'Hara <rohara@redhat.com>

	Looks good to me.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  libipvs/libipvs.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> index 2b066d2..1c9e066 100644
> --- a/libipvs/libipvs.c
> +++ b/libipvs/libipvs.c
> @@ -668,8 +668,10 @@ struct ip_vs_get_services *ipvs_get_services(void)
>  		return NULL;
>  	len = sizeof(*getk) +
>  		sizeof(struct ip_vs_service_entry_kern) * ipvs_info.num_services;
> -	if (!(getk = malloc(len)))
> +	if (!(getk = malloc(len))) {
> +		free(get);
>  		return NULL;
> +	}
>  
>  	ipvs_func = ipvs_get_services;
>  	getk->num_services = ipvs_info.num_services;
> @@ -853,8 +855,10 @@ ipvs_nl_dest_failure:
>  	}
>  
>  	len = sizeof(*dk) + sizeof(struct ip_vs_dest_entry_kern) * svc->num_dests;
> -	if (!(dk = malloc(len)))
> +	if (!(dk = malloc(len))) {
> +		free(d);
>  		return NULL;
> +	}
>  
>  	dk->fwmark = svc->fwmark;
>  	dk->protocol = svc->protocol;
> -- 
> 1.8.1.4

Regards

--
Julian Anastasov <ja@ssi.bg>
