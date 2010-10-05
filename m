From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v3] ipvs: IPv6 tunnel mode
Date: Tue, 5 Oct 2010 10:11:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010050952310.1481@ja.ssi.bg>
References: <20100927135913.GA21785@verge.net.au> <1286257959.5670.214.camel@seasc0214>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1286257959.5670.214.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>


 	Hello,

On Tue, 5 Oct 2010, Hans Schillstrom wrote:

> Hi Simon
> Finally I got time to test this, and it works now with change of dest.

 	You are using editor that changes tabs into spaces
and wraps long lines. The final patch does not look good.
Also, do not take the risk to use cp->dest->addr. Even if
one day IPv6 sync is supported, there is no rule that
says backup to have all real servers that are present
in master. NULL value for cp->dest is still supported.
Use &cp->daddr.in6 instead, it is perfectly valid for
TUN method.

> @@ -750,8 +763,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
>        be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
>        iph->priority           =       old_iph->priority;
>        memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
> -       iph->daddr              =       rt->rt6i_dst.addr;
> -       iph->saddr              =       cp->vaddr.in6; /*
> rt->rt6i_src.addr; */
> +       ipv6_addr_copy(&iph->daddr, &cp->dest->addr.in6);
> +       ipv6_addr_copy(&iph->saddr, &saddr);
>        iph->hop_limit          =       old_iph->hop_limit;
>
>        /* Another hack: avoid icmp_send in ip_fragment */

Regards

--
Julian Anastasov <ja@ssi.bg>
