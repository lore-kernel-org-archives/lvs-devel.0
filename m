From: Andrea Claudi <aclaudi@redhat.com>
Subject: Re: [PATCH] ipvs: change ip_vs_conn_tab_bits range to [8,31]
Date: Thu, 13 Apr 2023 12:35:43 +0200
Message-ID: <ZDfa/wuJTp8vk+wI@renaissance-vector>
References: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1681382151;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=itT3WRdataR3mc3HSH4d4WnSN/G47tLHOz7nmNIZqZs=;
        b=Ka14W+C7mXhQBpZ4hCWx2JwS5mrKYtzniN3UryqRg/NzO/7mrkhuw61RnClyJov4cVaqdX
        XMdLrFogGUeXyM5ry35mzkYvoHbqG45aNN2JG0CLo7H/AExzO8s0TAI0E7NoJiT+pzNOpS
        pP3NM7O0iEM0AbPyvdoo3cLH3SYGjmk=
Content-Disposition: inline
In-Reply-To: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: abhijeet.1989@gmail.com
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2023 at 01:49:08PM -0700, Abhijeet Rastogi via B4 Relay wrote:
> From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
> 
> Current range [8, 20] is set purely due to historical reasons
> because at the time, ~1M (2^20) was considered sufficient.
> 
> Previous change regarding this limit is here.
> 
> Link: https://lore.kernel.org/all/86eabeb9dd62aebf1e2533926fdd13fed48bab1f.1631289960.git.aclaudi@redhat.com/T/#u
> 
> Signed-off-by: Abhijeet Rastogi <abhijeet.1989@gmail.com>
> ---
> The conversation for this started at: 
> 
> https://www.spinics.net/lists/netfilter/msg60995.html
> 
> The upper limit for algo is any bit size less than 32, so this
> change will allow us to set bit size > 20. Today, it is common to have
> RAM available to handle greater than 2^20 connections per-host.
> 
> Distros like RHEL already have higher limits set.

Hi Abhijeet,
for the record, RHEL ships with CONFIG_IP_VS_TAB_BITS set to 12 as
default.

> ---
>  net/netfilter/ipvs/Kconfig      | 4 ++--
>  net/netfilter/ipvs/ip_vs_conn.c | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 271da8447b29..3e3371f8c0f9 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -44,7 +44,7 @@ config	IP_VS_DEBUG
>  
>  config	IP_VS_TAB_BITS
>  	int "IPVS connection table size (the Nth power of 2)"
> -	range 8 20
> +	range 8 31
>  	default 12
>  	help
>  	  The IPVS connection hash table uses the chaining scheme to handle
> @@ -54,7 +54,7 @@ config	IP_VS_TAB_BITS
>  
>  	  Note the table size must be power of 2. The table size will be the
>  	  value of 2 to the your input number power. The number to choose is
> -	  from 8 to 20, the default number is 12, which means the table size
> +	  from 8 to 31, the default number is 12, which means the table size
>  	  is 4096. Don't input the number too small, otherwise you will lose
>  	  performance on it. You can adapt the table size yourself, according
>  	  to your virtual server application. It is good to set the table size
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 13534e02346c..bc0fe1a698d4 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1484,8 +1484,8 @@ int __init ip_vs_conn_init(void)
>  	int idx;
>  
>  	/* Compute size and mask */
> -	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 20) {
> -		pr_info("conn_tab_bits not in [8, 20]. Using default value\n");
> +	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 31) {
> +		pr_info("conn_tab_bits not in [8, 31]. Using default value\n");
>  		ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
>  	}
>  	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
> 
> ---
> base-commit: 09a9639e56c01c7a00d6c0ca63f4c7c41abe075d
> change-id: 20230412-increase_ipvs_conn_tab_bits-4322c90da216
> 
> Best regards,
> -- 
> Abhijeet Rastogi <abhijeet.1989@gmail.com>
>

Looks good to me.

Reviewed-by: Andrea Claudi <aclaudi@redhat.com>

