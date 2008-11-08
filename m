From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: [RFC-PATCH] netfilter: payload_len is be16, add size of struct rather than size of pointer
Date: Sat, 8 Nov 2008 01:51:13 +0100
Message-ID: <43ca39800811071651s68da93b4if9cf2c84eec0e3f5@mail.gmail.com>
References: <1226078023.11596.17.camel@brick>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from:to
         :subject:cc:in-reply-to:mime-version:content-type
         :content-transfer-encoding:content-disposition:references;
        bh=Ata7RZKQq1BiI6tliMZ2O+vbksKhoaYAwrBeaPkF3DI=;
        b=skiJVuCnag/FKE+QoWgKX5MY9W3J0+8Vgd2oaN64kA+5J5mLwNnt2hCdh94cyCA3JI
         dj7PrJDRrbRmE2HWFa4FaicacfdR3D4CR/JaGyUmqTZ9A8YYkt6M75SZ72W3jk1tFlNM
         Q5311WCqWQavXR/CEquTwZPZXTTcesCLj4yIA=
In-Reply-To: <1226078023.11596.17.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Wensong Zhang <wensong@linuxvirtualserver.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>, linux-netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

On Fri, Nov 7, 2008 at 6:13 PM, Harvey Harrison
<harvey.harrison@gmail.com> wrote:
> payload_len is a be16 value, not cpu_endian, also the size of a ponter
> to a struct ipv6hdr was being added, not the size of the struct itself.
>
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> I'm quite supicious of the following code in net/netfilter/ipvs/ip_vs_xmit.c
>
> Line 714:
>        iph->payload_len        =       old_iph->payload_len + sizeof(old_iph);
>
> I believe that the payload_len is a big-endian value and this is treating it as
> cpu-ordered.  In addition, it is adding the size of a pointer to a struct ipv6hdr
> and not the size of the struct itself.
>
> If I'm correct, I'd suggest the following is what _may_ have been intended.
>
>  net/netfilter/ipvs/ip_vs_xmit.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 2f36721..425ab14 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -711,7 +711,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>        iph                     =       ipv6_hdr(skb);
>        iph->version            =       6;
>        iph->nexthdr            =       IPPROTO_IPV6;
> -       iph->payload_len        =       old_iph->payload_len + sizeof(old_iph);
> +       iph->payload_len        =       old_iph->payload_len;
> +       be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
>        iph->priority           =       old_iph->priority;
>        memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
>        iph->daddr              =       rt->rt6i_dst.addr;
> --
> 1.6.0.3.756.gb776d

Yes, both of that makes sense, thank you!

This function was never tested because IIRC there was/is no
decapsulation support for IPv6 in IPv6 tunneling on the receiving side
(please correct me if I'm wrong). I sent some packets through it which
somehow arrived at the real server, but that was about it. So the
whole code in that function is pretty only an idea of how the v6
tunneling should work ;)

Julius
