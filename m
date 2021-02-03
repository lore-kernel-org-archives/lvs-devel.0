From: Leon Romanovsky <leonro@nvidia.com>
Subject: Re: [PATCH net-next v1 3/4] net/core: move gro function declarations
 to separate header
Date: Wed, 3 Feb 2021 15:22:43 +0200
Message-ID: <20210203132243.GM3264866@unreal>
References: <20210203101612.4004322-1-leon@kernel.org>
 <20210203101612.4004322-4-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20210203101612.4004322-4-leon@kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
        t=1612358567; bh=W9V+E7YJOYX62ra3dha0U221aVuh7TmZXSzu1IxejSE=;
        h=Date:From:To:CC:Subject:Message-ID:References:MIME-Version:
         Content-Type:Content-Disposition:Content-Transfer-Encoding:
         In-Reply-To:X-Originating-IP:X-ClientProxiedBy;
        b=ZAsNQ2TPIO7zk65P7mhskDy04d8hISs21+u3TdG/8sFxXefPoTbO8AhWVXAyYlVJY
         kjGfHzCojzRJwtUSs02zbZgEAOFHvbPjUr1VMnA5/0YAFljLTT+URxloJW5c6m1xfC
         +jltOxmb20pg10rnIIODIp35dF6NbfRW1z03Yq1/tvkpA6BS8XLQPjkTR2wQuF36NA
         KLFOOxosng9e7mcrI6EaPAXf8KybSnKzzmL5AVnOBvX3Hkmuz0xMoDjp02Ggm4Er8i
         dc4GXCLORnqN3ncuvYkgd8IRzZEYsXeT+tqVZdv2VfT28sQjUvfA2GwDVskaGUFhEb
         2dbD5/BS1arvA==
List-ID: <lvs-devel.vger.kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Eric Dumazet <edumazet@google.com>
Cc: coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Wed, Feb 03, 2021 at 12:16:11PM +0200, Leon Romanovsky wrote:
> From: Leon Romanovsky <leonro@nvidia.com>
>
> Fir the following compilation warnings:
>  1031 | INDIRECT_CALLABLE_SCOPE void udp_v6_early_demux(struct sk_buff *s=
kb)
>
> net/ipv6/ip6_offload.c:182:41: warning: no previous prototype for =E2=80=
=98ipv6_gro_receive=E2=80=99 [-Wmissing-prototypes]
>   182 | INDIRECT_CALLABLE_SCOPE struct sk_buff *ipv6_gro_receive(struct l=
ist_head *head,
>       |                                         ^~~~~~~~~~~~~~~~
> net/ipv6/ip6_offload.c:320:29: warning: no previous prototype for =E2=80=
=98ipv6_gro_complete=E2=80=99 [-Wmissing-prototypes]
>   320 | INDIRECT_CALLABLE_SCOPE int ipv6_gro_complete(struct sk_buff *skb=
, int nhoff)
>       |                             ^~~~~~~~~~~~~~~~~
> net/ipv6/ip6_offload.c:182:41: warning: no previous prototype for =E2=80=
=98ipv6_gro_receive=E2=80=99 [-Wmissing-prototypes]
>   182 | INDIRECT_CALLABLE_SCOPE struct sk_buff *ipv6_gro_receive(struct l=
ist_head *head,
>       |                                         ^~~~~~~~~~~~~~~~
> net/ipv6/ip6_offload.c:320:29: warning: no previous prototype for =E2=80=
=98ipv6_gro_complete=E2=80=99 [-Wmissing-prototypes]
>   320 | INDIRECT_CALLABLE_SCOPE int ipv6_gro_complete(struct sk_buff *skb=
, int nhoff)
>
> Signed-off-by: Leon Romanovsky <leonro@nvidia.com>
> ---
>  include/net/gro.h | 12 ++++++++++++
>  net/core/dev.c    |  7 +------
>  2 files changed, 13 insertions(+), 6 deletions(-)
>  create mode 100644 include/net/gro.h

I sent it too fast, sorry for that.
There is a need to add #include <net/gro.h> to the ip6_offload.c.

I will resend.

Thanks
