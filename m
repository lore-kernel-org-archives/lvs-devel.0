From: yue longguang <yuelongguang@gmail.com>
Subject: Re: [PATCH] ipvs: Add traffic statistic up even it is VS/DR or VS/TUN mode
Date: Tue, 29 Sep 2020 13:17:20 +0800
Message-ID: <CAPaK2r__afG7epSM6As3SehhCvTk4KvXB_UjQuwjCNZmf-giGA@mail.gmail.com>
References: <20200929050302.28105-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Xif5oC/NRIYYhpW7XETZfA0h68yDq+U57n1x8FOdeWU=;
        b=rawzs6k4NMlg6bsVsbWsPDBl2UaCGARw1RPjil0OKWhWmLKHo+FOAGheM4W/l1jgCh
         ntfnJQD1rlXTUrk+If0qpZD2YxEp3os+qzms7fAR7NI0dZkd+LmOdlaKA7/39J2TQThs
         n7OIgwshgCO5DCcBoNk+gpLg8GsgWOyArueI5twuJ25+eeLBroZfYUD85jJqmBBC1HsZ
         AOsL6pO/eQ3kcK4P8XtgmWLVbRC888sDzCDtBJ//C6VivSP8Rc6IvHdx5+cDx/pL3iCi
         U447icvBcUcFBM0BdPKdDNq8m83UnVT2/ZMBdhmV+wtQSxmPW4Pjf6HHHzhjk24ybuW2
         mbhA==
In-Reply-To: <20200929050302.28105-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

especially in public cloud case, statistic is related to monitorring
and billing , both ingress and egress packets will go throught ipvs,
even dr/tun mode.
in dr/tun mode, ipvs need to do nothing except  statistic, so
skb->ipvs_property = 1

regards

On Tue, Sep 29, 2020 at 1:04 PM longguang.yue <bigclouds@163.com> wrote:
>
> It's ipvs's duty to do traffic statistic if packets get hit,
> no matter what mode it is.
>
> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index e3668a6e54e4..ed523057f07f 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1413,8 +1413,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>                              ipvs, af, skb, &iph);
>
>         if (likely(cp)) {
> -               if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> +               if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ){
> +                       ip_vs_out_stats(cp, skb);
> +                       skb->ipvs_property = 1;
>                         goto ignore_cp;
> +               }
>                 return handle_response(af, skb, pd, cp, &iph, hooknum);
>         }
>
> --
> 2.20.1 (Apple Git-117)
>
