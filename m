From: yue longguang <yuelongguang@gmail.com>
Subject: Re: [PATCH v5] ipvs: adjust the debug info in function set_tcp_state
Date: Tue, 29 Sep 2020 10:15:49 +0800
Message-ID: <CAPaK2r8DnR_dcZ8E9w0mvDbK2KiWCt+JswO=-tqvbWb2RibaYw@mail.gmail.com>
References: <alpine.LFD.2.23.451.2009271625160.35554@ja.home.ssi.bg> <20200928024938.97121-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DjSQ9+lJ+KOY1QhLkpVLHaBOWFdrcLty+nw0yJV/I8Q=;
        b=DZhXDdSMQJIGkkVrGwyQS/lGggQc5c3pvIXYhO/IPdOhvQbCY+2marDi29JbT2EsKu
         yFJZHGwHAVox4UH2X2grKfs/9aOk7V/MQYOMlAVwDCWEpTT8Qha5YjjpVgtFX53/PEGY
         65Om4LcgoWwGsOtjri619XxiMgldZC+WAQbaE4XCJGF4B/aYF5sN/P8/WmgfSf/c7qpk
         ERrZXQr2wol0jNmvtQHOYFSkFNz9E+4/LOeAlnNMiJegctoKTYOPSyrXui3T+YsoclU7
         lt41N1uZG4PGWEuTqnJ+PVaEvxOLrfMMBQWL0FYkCsJ4ifddfSz3PTgiT0JA1uKXZ4To
         Ab+g==
In-Reply-To: <20200928024938.97121-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, "longguang.yue" <bigclouds@163.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

I sincerely apologize for the trouble which takes up much of your
time. If the last patch does not work , would you please fix it?
thanks

On Mon, Sep 28, 2020 at 10:51 AM longguang.yue <bigclouds@163.com> wrote:
>
> Outputting client,virtual,dst addresses info when tcp state changes,
> which makes the connection debug more clear
>
> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index dc2e7da2742a..7da51390cea6 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>         if (new_state != cp->state) {
>                 struct ip_vs_dest *dest = cp->dest;
>
> -               IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
> -                             "%s:%d state: %s->%s conn->refcnt:%d\n",
> +               IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
> +                             "d:%s:%d state: %s->%s conn->refcnt:%d\n",
>                               pd->pp->name,
>                               ((state_off == TCP_DIR_OUTPUT) ?
>                                "output " : "input "),
> @@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>                               th->fin ? 'F' : '.',
>                               th->ack ? 'A' : '.',
>                               th->rst ? 'R' : '.',
> -                             IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> -                             ntohs(cp->dport),
>                               IP_VS_DBG_ADDR(cp->af, &cp->caddr),
>                               ntohs(cp->cport),
> +                             IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> +                             ntohs(cp->vport),
> +                             IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> +                             ntohs(cp->dport),
>                               tcp_state_name(cp->state),
>                               tcp_state_name(new_state),
>                               refcount_read(&cp->refcnt));
> --
> 2.20.1 (Apple Git-117)
>
