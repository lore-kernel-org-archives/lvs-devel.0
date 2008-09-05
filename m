From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] ipvs: load balance ipv6 connections from a local process
Date: Fri, 5 Sep 2008 13:40:31 +0200
Message-ID: <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com>
References: <20080905013609.GD14128@verge.net.au>
	 <20080905013755.GE14128@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220614833; bh=SZty+i5E3b3e7McABS4FtKih3Z0=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Wcmq8tq0+zQXWP90qq96Sn75hy/Aegas
	ZCd65tJsalzJXxuRKIBn8XQsMpa7XGIchHTBYkTYkdxvcvyUpOVl8w==
In-Reply-To: <20080905013755.GE14128@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

Hi,

Just some minor things:

On Fri, Sep 5, 2008 at 3:37 AM, Simon Horman <horms@verge.net.au> wrote=
:
> This allows IPVS to load balance IPv6 connections made by a local pro=
cess.
> For example a proxy server running locally.
>
> External client --> pound:443 -> Local:443 --> IPVS:80 --> RealServer
>
> This is an extenstion to the IPv4 work done in this area
> by Siim P=F5der and Malcolm Turnbull.
>
> Cc: Siim P=F5der <siim@p6drad-teel.net>
> Cc: Malcolm Turnbull <malcolm@loadbalancer.org>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
>
>  net/ipv4/ipvs/ip_vs_core.c |   91 +++++++++++++++++++---------------=
----------
>  1 file changed, 41 insertions(+), 50 deletions(-)
>
> * Fri, 05 Sep 2008 11:32:38 +1000
>
>  I have applied this patch to the net-next-2.6 branck of lvs-2.6
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git
>
> Index: lvs-2.6/net/ipv4/ipvs/ip_vs_core.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_core.c     2008-09-03 13:39:34.0=
00000000 +1000
> +++ lvs-2.6/net/ipv4/ipvs/ip_vs_core.c  2008-09-03 14:39:17.000000000=
 +1000
> @@ -654,8 +654,9 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
>  /* Handle relevant response ICMP messages - forward to the right
>  * destination host. Used for NAT and local client.
>  */
> -static int handle_response_icmp(struct sk_buff *skb, struct iphdr *i=
ph,
> -                               struct iphdr *cih, struct ip_vs_conn =
*cp,
> +static int handle_response_icmp(int af, struct sk_buff *skb,
> +                               union nf_inet_addr *snet,
> +                               __u8 protocol, struct ip_vs_conn *cp,
>                                struct ip_vs_protocol *pp,
>                                unsigned int offset, unsigned int ihl)
>  {
> @@ -669,18 +670,22 @@ static int handle_response_icmp(struct s
>        /* Ensure the checksum is correct */
>        if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb,=
 ihl)) {
>                /* Failed checksum! */
> -               IP_VS_DBG(1,
> -                         "Forward ICMP: failed checksum from %d.%d.%=
d.%d!\n",
> -                         NIPQUAD(iph->saddr));
> +               IP_VS_DBG_BUF(1, "Forward ICMP: failed checksum from =
%s!\n",
> +                             IP_VS_DBG_ADDR(af, snet));
>                goto out;
>        }
>
> -       if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D ci=
h->protocol)
> +       if (IPPROTO_TCP =3D=3D protocol || IPPROTO_UDP =3D=3D protoco=
l)
>                offset +=3D 2 * sizeof(__u16);
>        if (!skb_make_writable(skb, offset))
>                goto out;
>
> -       ip_vs_nat_icmp(skb, pp, cp, 1);
> +#ifdef CONFIG_IP_VS_IPV6
> +       if (af =3D=3D AF_INET6)
> +               ip_vs_nat_icmp_v6(skb, pp, cp, 1);
> +       else
> +#endif
> +               ip_vs_nat_icmp(skb, pp, cp, 1);
>
>        /* do the statistics and put it back */
>        ip_vs_out_stats(cp, skb);
> @@ -708,6 +713,7 @@ static int ip_vs_out_icmp(struct sk_buff
>        struct ip_vs_conn *cp;
>        struct ip_vs_protocol *pp;
>        unsigned int offset, ihl;
> +       union nf_inet_addr snet;
>
>        *related =3D 1;
>
> @@ -766,7 +772,9 @@ static int ip_vs_out_icmp(struct sk_buff
>        if (!cp)
>                return NF_ACCEPT;
>
> -       return handle_response_icmp(skb, iph, cih, cp, pp, offset, ih=
l);
> +       snet.ip =3D iph->saddr;
> +       return handle_response_icmp(AF_INET, skb, &snet, cih->protoco=
l, cp,
> +                                   pp, offset, ihl);
>  }
>
>  #ifdef CONFIG_IP_VS_IPV6
> @@ -779,7 +787,8 @@ static int ip_vs_out_icmp_v6(struct sk_b
>        struct ip_vs_iphdr ciph;
>        struct ip_vs_conn *cp;
>        struct ip_vs_protocol *pp;
> -       unsigned int offset, verdict;
> +       unsigned int offset;
> +       union nf_inet_addr snet;
>
>        *related =3D 1;
>
> @@ -838,40 +847,9 @@ static int ip_vs_out_icmp_v6(struct sk_b
>        if (!cp)
>                return NF_ACCEPT;
>
> -       verdict =3D NF_DROP;
> -
> -       if (IP_VS_FWD_METHOD(cp) !=3D 0) {
> -               IP_VS_ERR("shouldn't reach here, because the box is o=
n the "
> -                         "half connection in the tun/dr module.\n");
> -       }
> -
> -       /* Ensure the checksum is correct */
> -       if (!skb_csum_unnecessary(skb)
> -           && ip_vs_checksum_complete(skb, sizeof(struct ipv6hdr))) =
{
> -               /* Failed checksum! */
> -               IP_VS_DBG(1, "Forward ICMPv6: failed checksum from "
> -                         NIP6_FMT "!\n",
> -                         NIP6(iph->saddr));
> -               goto out;
> -       }
> -
> -       if (IPPROTO_TCP =3D=3D cih->nexthdr || IPPROTO_UDP =3D=3D cih=
->nexthdr)
> -               offset +=3D 2 * sizeof(__u16);
> -       if (!skb_make_writable(skb, offset))
> -               goto out;
> -
> -       ip_vs_nat_icmp_v6(skb, pp, cp, 1);
> -
> -       /* do the statistics and put it back */
> -       ip_vs_out_stats(cp, skb);
> -
> -       skb->ipvs_property =3D 1;
> -       verdict =3D NF_ACCEPT;
> -
> -out:
> -       __ip_vs_conn_put(cp);
> -
> -       return verdict;
> +       snet.in6 =3D iph->saddr;

I've always been told to use ipv6_addr_copy() for this. I'm not sure
what the problem with the direct struct assignment is though... would
be nice if someone could explain.

> +       return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthd=
r, cp,
> +                                   pp, offset, sizeof(struct ipv6hdr=
));
>  }
>  #endif
>
> @@ -1055,7 +1033,7 @@ ip_vs_out(unsigned int hooknum, struct s
>                                                          ICMP_DEST_UN=
REACH,
>                                                          ICMP_PORT_UN=
REACH, 0);
>                                        return NF_DROP;
> -                               }
> +                       }

This indents the curly brace incorrectly, probably just deleted a tab
by accident...

>                        }
>                }
>                IP_VS_DBG_PKT(12, pp, skb, 0,
> @@ -1083,6 +1061,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
>        struct ip_vs_conn *cp;
>        struct ip_vs_protocol *pp;
>        unsigned int offset, ihl, verdict;
> +       union nf_inet_addr snet;
>
>        *related =3D 1;
>
> @@ -1142,9 +1121,12 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
>        if (!cp) {
>                /* The packet could also belong to a local client */
>                cp =3D pp->conn_out_get(AF_INET, skb, pp, &ciph, offse=
t, 1);
> -               if (cp)
> -                       return handle_response_icmp(skb, iph, cih, cp=
, pp,
> +               if (cp) {
> +                       snet.ip =3D iph->saddr;
> +                       return handle_response_icmp(AF_INET, skb, &sn=
et,
> +                                                   cih->protocol, cp=
, pp,
>                                                    offset, ihl);
> +               }
>                return NF_ACCEPT;
>        }
>
> @@ -1183,6 +1165,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
>        struct ip_vs_conn *cp;
>        struct ip_vs_protocol *pp;
>        unsigned int offset, verdict;
> +       union nf_inet_addr snet;
>
>        *related =3D 1;
>
> @@ -1240,8 +1223,18 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
>        ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
>        /* The embedded headers contain source and dest in reverse ord=
er */
>        cp =3D pp->conn_in_get(AF_INET6, skb, pp, &ciph, offset, 1);
> -       if (!cp)
> +       if (!cp) {
> +               /* The packet could also belong to a local client */
> +               cp =3D pp->conn_out_get(AF_INET6, skb, pp, &ciph, off=
set, 1);
> +               if (cp) {
> +                       snet.in6 =3D iph->saddr;

ipv6_addr_copy() again.

> +                       return handle_response_icmp(AF_INET6, skb, &s=
net,
> +                                                   cih->nexthdr,
> +                                                   cp, pp, offset,
> +                                                   sizeof(struct ipv=
6hdr));
> +               }
>                return NF_ACCEPT;
> +       }
>
>        verdict =3D NF_DROP;
>
> @@ -1281,9 +1274,7 @@ ip_vs_in(unsigned int hooknum, struct sk
>         *      Big tappo: only PACKET_HOST, including loopback for lo=
cal client
>         *      Don't handle local packets on IPv6 for now
>         */
> -       if (unlikely(skb->pkt_type !=3D PACKET_HOST ||
> -                    (af =3D=3D AF_INET6 || (skb->dev->flags & IFF_LO=
OPBACK ||
> -                                        skb->sk)))) {
> +       if (unlikely(skb->pkt_type !=3D PACKET_HOST)) {
>                IP_VS_DBG_BUF(12, "packet type=3D%d proto=3D%d daddr=3D=
%s ignored\n",
>                              skb->pkt_type,
>                              iph.protocol,
>


--=20
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
