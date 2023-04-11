From: Horatiu Vultur <horatiu.vultur@microchip.com>
Subject: Re: [PATCH nf-next v2 4/4] ipvs: Correct spelling in comments
Date: Tue, 11 Apr 2023 13:33:06 +0200
Message-ID: <20230411113306.ydzhynl243o6mncz@soft-dev3-1>
References: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
 <20230409-ipvs-cleanup-v2-4-204cd17da708@kernel.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=microchip.com; i=@microchip.com; q=dns/txt; s=mchp;
  t=1681212789; x=1712748789;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=Z8s5H2R2JPvyJImDdoa6/+E68sq74qjYjSO+8uO7l7Y=;
  b=YHUe8TwtEhgAOqJn0U62TEfHWQVnjNmbtybwc5i6CWmfOzdPqfLaropK
   ZRD1TpZkGACOQXv3H3P+pcEYxZr4k04Y2ZAPFjqc9VrnvQ/znZYrJ6ZDs
   EBSbmKCi2fXu+EDrJFFw07FfuYRT6Q/TwjFCZhd6TmZ6FTPnG0R5uGezW
   WmYunKE3XxckWArF6XZvsFKJXdq4JTy/NWhsBHYBunQJ1wcayzj4bcHOw
   GBiW79M1bMRXzbHxbYNxkv/WW0TlDZt393DqU8NN2oqub3oV5blFm2w3T
   37OHZBfEYZ//WtoY428ounOmlCS2Q8gGus0lMBO8hG0mQpzLrggwGsXwQ
   Q==;
Content-Disposition: inline
In-Reply-To: <20230409-ipvs-cleanup-v2-4-204cd17da708@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@kernel.org>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

The 04/11/2023 09:10, Simon Horman wrote:
> 
> Correct some spelling errors flagged by codespell and found by inspection.

Reviewed-by: Horatiu Vultur <horatiu.vultur@microchip.com>

> 
> Signed-off-by: Simon Horman <horms@kernel.org>
> ---
>  include/net/ip_vs.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index a3adc246ee31..ff406ef4fd4a 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -584,7 +584,7 @@ struct ip_vs_conn {
>         spinlock_t              lock;           /* lock for state transition */
>         volatile __u16          state;          /* state info */
>         volatile __u16          old_state;      /* old state, to be used for
> -                                                * state transition triggerd
> +                                                * state transition triggered
>                                                  * synchronization
>                                                  */
>         __u32                   fwmark;         /* Fire wall mark from skb */
> @@ -635,7 +635,7 @@ struct ip_vs_service_user_kern {
>         u16                     protocol;
>         union nf_inet_addr      addr;           /* virtual ip address */
>         __be16                  port;
> -       u32                     fwmark;         /* firwall mark of service */
> +       u32                     fwmark;         /* firewall mark of service */
> 
>         /* virtual service options */
>         char                    *sched_name;
> @@ -1036,7 +1036,7 @@ struct netns_ipvs {
>         struct ipvs_sync_daemon_cfg     bcfg;   /* Backup Configuration */
>         /* net name space ptr */
>         struct net              *net;            /* Needed by timer routines */
> -       /* Number of heterogeneous destinations, needed becaus heterogeneous
> +       /* Number of heterogeneous destinations, needed because heterogeneous
>          * are not supported when synchronization is enabled.
>          */
>         unsigned int            mixed_address_family_dests;
> 
> --
> 2.30.2
> 

-- 
/Horatiu
