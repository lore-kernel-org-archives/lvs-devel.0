From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: add missing struct name in ip_vs_enqueue_expire_nodest_conns
 when CONFIG_SYSCTL is disabled
Date: Fri, 17 Jul 2020 20:36:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2007172032370.4536@ja.home.ssi.bg>
References: <20200717162450.1049-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20200717162450.1049-1-kim.andrewsy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Randy Dunlap <rdunlap@infradead.org>, netdev@vger.kernel.org


	Hello,

On Fri, 17 Jul 2020, Andrew Sy Kim wrote:

> Adds missing "*ipvs" to ip_vs_enqueue_expire_nodest_conns when
> CONFIG_SYSCTL is disabled
> 
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

	Pablo, please apply this too.

> ---
>  include/net/ip_vs.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 91a9e1d590a6..9a59a33787cb 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1533,7 +1533,7 @@ static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs)
>  
>  void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs);
>  #else
> -static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
> +static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs) {}
>  #endif
>  
>  #define IP_VS_DFWD_METHOD(dest) (atomic_read(&(dest)->conn_flags) & \
> -- 
> 2.20.1

Regards
