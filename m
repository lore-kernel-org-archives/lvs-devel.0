From: Horatiu Vultur <horatiu.vultur@microchip.com>
Subject: Re: [PATCH nf-next v2 1/4] ipvs: Update width of source for
 ip_vs_sync_conn_options
Date: Tue, 11 Apr 2023 13:39:24 +0200
Message-ID: <20230411113924.6vhibpekifbyjksg@soft-dev3-1>
References: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
 <20230409-ipvs-cleanup-v2-1-204cd17da708@kernel.org>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=microchip.com; i=@microchip.com; q=dns/txt; s=mchp;
  t=1681213168; x=1712749168;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=r0qqKJ4nkKA5foVlIR6UdPxdVJCmJH48u1jn3damEbI=;
  b=uZYuTWCIEWnEC0sOGBQ8RZ+N0eFdgVENhtdxUWxpsmPWXmahzx0MAJWL
   qLXyQTGU0+mvw42N8MzE9/W1Z2qgcAxriiyXGeyoSicDLoTBszKgKHjw/
   JVo6R1ZuHSxVxENp599IhuLKmOTEK7E4slh0JSpA/pZWWcoKG2l7FkMOe
   Qa+gemf4x/f9eZPGk8nYlrymSKFM6ILHKMgdE8p+ozAf71n7QLn9/Dgws
   1Wz8oX9UfLj9XMcyyjRfanPo7m8UAUbQ1c/FStW5jOpUX8WLBPgpybjx8
   BN5myXbvd5OTfmyDHh8jvfuQjwjKcjYr8OzTy0OYzZJLlGpvuzlvJA5UI
   A==;
Content-Disposition: inline
In-Reply-To: <20230409-ipvs-cleanup-v2-1-204cd17da708@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@kernel.org>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

The 04/11/2023 09:10, Simon Horman wrote:
> 
> In ip_vs_sync_conn_v0() copy is made to struct ip_vs_sync_conn_options.
> That structure looks like this:
> 
> struct ip_vs_sync_conn_options {
>         struct ip_vs_seq        in_seq;
>         struct ip_vs_seq        out_seq;
> };
> 
> The source of the copy is the in_seq field of struct ip_vs_conn.  Whose
> type is struct ip_vs_seq. Thus we can see that the source - is not as
> wide as the amount of data copied, which is the width of struct
> ip_vs_sync_conn_option.
> 
> The copy is safe because the next field in is another struct ip_vs_seq.
> Make use of struct_group() to annotate this.
> 
> Flagged by gcc-13 as:
> 
>  In file included from ./include/linux/string.h:254,
>                   from ./include/linux/bitmap.h:11,
>                   from ./include/linux/cpumask.h:12,
>                   from ./arch/x86/include/asm/paravirt.h:17,
>                   from ./arch/x86/include/asm/cpuid.h:62,
>                   from ./arch/x86/include/asm/processor.h:19,
>                   from ./arch/x86/include/asm/timex.h:5,
>                   from ./include/linux/timex.h:67,
>                   from ./include/linux/time32.h:13,
>                   from ./include/linux/time.h:60,
>                   from ./include/linux/stat.h:19,
>                   from ./include/linux/module.h:13,
>                   from net/netfilter/ipvs/ip_vs_sync.c:38:
>  In function 'fortify_memcpy_chk',
>      inlined from 'ip_vs_sync_conn_v0' at net/netfilter/ipvs/ip_vs_sync.c:606:3:
>  ./include/linux/fortify-string.h:529:25: error: call to '__read_overflow2_field' declared with attribute warning: detected read beyond size of field (2nd parameter); maybe use struct_group()? [-Werror=attribute-warning]
>    529 |                         __read_overflow2_field(q_size_field, size);
>        |
> 
> Compile tested only.

Reviewed-by: Horatiu Vultur <horatiu.vultur@microchip.com>

> 
> Signed-off-by: Simon Horman <horms@kernel.org>
> ---
> v2
> * Correct spelling of 'conn' in subject
> ---
>  include/net/ip_vs.h             | 6 ++++--
>  net/netfilter/ipvs/ip_vs_sync.c | 2 +-
>  2 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 6d71a5ff52df..e20f1f92066d 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -630,8 +630,10 @@ struct ip_vs_conn {
>          */
>         struct ip_vs_app        *app;           /* bound ip_vs_app object */
>         void                    *app_data;      /* Application private data */
> -       struct ip_vs_seq        in_seq;         /* incoming seq. struct */
> -       struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
> +       struct_group(sync_conn_opt,
> +               struct ip_vs_seq  in_seq;       /* incoming seq. struct */
> +               struct ip_vs_seq  out_seq;      /* outgoing seq. struct */
> +       );
> 
>         const struct ip_vs_pe   *pe;
>         char                    *pe_data;
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 4963fec815da..d4fe7bb4f853 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -603,7 +603,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>         if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
>                 struct ip_vs_sync_conn_options *opt =
>                         (struct ip_vs_sync_conn_options *)&s[1];
> -               memcpy(opt, &cp->in_seq, sizeof(*opt));
> +               memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
>         }
> 
>         m->nr_conns++;
> 
> --
> 2.30.2
> 

-- 
/Horatiu
