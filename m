From: yue longguang <yuelongguang@gmail.com>
Subject: Re: [PATCH v3] ipvs: adjust the debug info in function set_tcp_state
Date: Sun, 27 Sep 2020 09:56:29 +0800
Message-ID: <CAPaK2r9th06OeNvs-1jrOq8a_ayaNL+kNWPddUUJ2GAEEJnZ8A@mail.gmail.com>
References: <CAPaK2r8cTOq5rEKZezse+wF0f9NierUabqcr31b46wJx43werQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=RtgKOaz92FMArlu9ktFCct50Xb7g19eVCcstF2JFt2E=;
        b=GjyfJvpfymL/OOsYFWNfw6LJCkoDb2IxyKL6/sNJa6s+FetrP0/KiW/0NyM/gjeL+d
         72/YsrGgaFQaQVzQzbD6C7+Tn3hP2MCo/brvzhA+LbVnaezdJujPUGbWTCnD7xrJdjjZ
         Zwm2lCsbtkaJYTmKzOGF8vEvAbq8BxhsnYU0LRRjLWLs3WzXdAhy2STdrZa5NXFiMBxD
         QHdUyhJjTsxTMwooxzrri+X97Q1ZzMK5cEwiPWxN+5VVKXoU+isjeYLcMksDkSRGtv8K
         4cy2B+kD1VAWzVezJzqlKs33zdYQ+8twj1qHZt9oIYl9e0v6SISwArBGGYp7XjEblZVm
         U2Ug==
In-Reply-To: <CAPaK2r8cTOq5rEKZezse+wF0f9NierUabqcr31b46wJx43werQ@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, Julian Anastasov <ja@ssi.bg>, wensong@linux-vs.org, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, David Miller <davem@davemloft.net>, kuba@kernel.org, lvs-devel@vger.kernel.org

Hi, could you all give me some feedback?
thanks

On Fri, Sep 25, 2020 at 8:09 PM yue longguang <yuelongguang@gmail.com> wrote:
>
> From: "longguang.yue" <yuelongguang@gmail.com>
>
>    outputting client,virtual,dst addresses info when tcp state changes,
>    which makes the connection debug more clear
>
> Signed-off-by: longguang.yue <yuelongguang@gmail.com>
> ---
> net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index dc2e7da2742a..7da51390cea6 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct
> ip_vs_conn *cp,
> if (new_state != cp->state) {
> struct ip_vs_dest *dest = cp->dest;
>
> - IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
> -       "%s:%d state: %s->%s conn->refcnt:%d\n",
> + IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
> +       "d:%s:%d state: %s->%s conn->refcnt:%d\n",
>       pd->pp->name,
>       ((state_off == TCP_DIR_OUTPUT) ?
>        "output " : "input "),
> @@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd,
> struct ip_vs_conn *cp,
>       th->fin ? 'F' : '.',
>       th->ack ? 'A' : '.',
>       th->rst ? 'R' : '.',
> -       IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> -       ntohs(cp->dport),
>       IP_VS_DBG_ADDR(cp->af, &cp->caddr),
>       ntohs(cp->cport),
> +       IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> +       ntohs(cp->vport),
> +       IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> +       ntohs(cp->dport),
>       tcp_state_name(cp->state),
>       tcp_state_name(new_state),
>       refcount_read(&cp->refcnt));
> --
> 2.20.1 (Apple Git-117)
