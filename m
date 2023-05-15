From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: increase ip_vs_conn_tab_bits range for 64BIT
Date: Mon, 15 May 2023 18:18:13 +0300 (EEST)
Message-ID: <56b88a99-db88-36e4-9ff1-a5d940578108@ssi.bg>
References: <20230412-increase_ipvs_conn_tab_bits-v2-1-994c0df018e6@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20230412-increase_ipvs_conn_tab_bits-v2-1-994c0df018e6@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>


	Hello,

On Sun, 14 May 2023, Abhijeet Rastogi wrote:

> Current range [8, 20] is set purely due to historical reasons
> because at the time, ~1M (2^20) was considered sufficient.
> With this change, 27 is the upper limit for 64-bit, 20 otherwise.
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
> Distros like RHEL already allow setting limits higher than 20.
> ---
> Changes in v2:
> - Lower the ranges, 27 for 64bit, 20 otherwise
> - Link to v1: https://lore.kernel.org/r/20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com
> ---
>  net/netfilter/ipvs/Kconfig      | 26 +++++++++++++-------------
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  2 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 271da8447b29..aac5d6bd82e6 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -44,7 +44,8 @@ config	IP_VS_DEBUG
>  
>  config	IP_VS_TAB_BITS
>  	int "IPVS connection table size (the Nth power of 2)"
> -	range 8 20
> +	range 8 20 if !64BIT
> +	range 8 27 if 64BIT
>  	default 12
>  	help
>  	  The IPVS connection hash table uses the chaining scheme to handle
> @@ -52,18 +53,17 @@ config	IP_VS_TAB_BITS
>  	  reduce conflicts when there are hundreds of thousands of connections
>  	  in the hash table.
>  
> -	  Note the table size must be power of 2. The table size will be the
> -	  value of 2 to the your input number power. The number to choose is
> -	  from 8 to 20, the default number is 12, which means the table size
> -	  is 4096. Don't input the number too small, otherwise you will lose
> -	  performance on it. You can adapt the table size yourself, according
> -	  to your virtual server application. It is good to set the table size
> -	  not far less than the number of connections per second multiplying
> -	  average lasting time of connection in the table.  For example, your
> -	  virtual server gets 200 connections per second, the connection lasts
> -	  for 200 seconds in average in the connection table, the table size
> -	  should be not far less than 200x200, it is good to set the table
> -	  size 32768 (2**15).
> +	  Note the table size must be power of 2. The table size will be the value
> +	  of 2 to the your input number power. The number to choose is from 8 to 27
> +	  for 64BIT(20 otherwise), the default number is 12, which means the table
> +	  size is 4096. Don't input the number too small, otherwise you will lose
> +	  performance on it. You can adapt the table size yourself, according to
> +	  your virtual server application. It is good to set the table size not far
> +	  less than the number of connections per second multiplying average lasting
> +	  time of connection in the table.  For example, your virtual server gets
> +	  200 connections per second, the connection lasts for 200 seconds in
> +	  average in the connection table, the table size should be not far less
> +	  than 200x200, it is good to set the table size 32768 (2**15).

	Can you keep the previous line width of the above help
because on standard 80-width window the help now gets truncated in
make menuconfig.

	After that I'll send a patch on top of yours to limit the
rows depending on the memory.

>  	  Another note that each connection occupies 128 bytes effectively and
>  	  each hash entry uses 8 bytes, so you can estimate how much memory is
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 13534e02346c..e1b9b52909a5 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1484,8 +1484,8 @@ int __init ip_vs_conn_init(void)
>  	int idx;
>  
>  	/* Compute size and mask */
> -	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 20) {
> -		pr_info("conn_tab_bits not in [8, 20]. Using default value\n");
> +	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 27) {
> +		pr_info("conn_tab_bits not in [8, 27]. Using default value\n");
>  		ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
>  	}
>  	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
> 
> ---

Regards

--
Julian Anastasov <ja@ssi.bg>

