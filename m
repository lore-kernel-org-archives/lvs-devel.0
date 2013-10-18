From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Fri, 18 Oct 2013 09:33:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310180921200.1581@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131018021008.GH18135@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Simon Horman <horms@verge.net.au>, =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>


	Hello,

On Fri, 18 Oct 2013, Hannes Frederic Sowa wrote:

> I played around with your patch and tested xt_TEE. I added a TEE rule to
> mangle/OUTPUT and pinged. This happend, I have not yet analyzed it:

	May be a side effect of using some multicast address?
Can you test it with such address check?:

	if (rt->rt6i_flags & RTF_GATEWAY ||
	    ipv6_addr_type(&rt->rt6i_gateway) & IPV6_ADDR_UNICAST)

> [  101.129421]  [<ffffffff816d4e47>] icmp6_dst_alloc+0xf7/0x430
> [  101.129421]  [<ffffffff816d4d55>] ? icmp6_dst_alloc+0x5/0x430
> [  101.129421]  [<ffffffff816dde26>] ndisc_send_skb+0x3e6/0x540
> [  101.129421]  [<ffffffff816df81c>] ndisc_send_ns+0xdc/0x140
> [  101.129421]  [<ffffffff816d394b>] rt6_probe+0x31b/0x380
> [  101.129421]  [<ffffffff816d3690>] ? rt6_probe+0x60/0x380
> [  101.129421]  [<ffffffff816d1b93>] ? rt6_score_route+0xa3/0x380
> [  101.129421]  [<ffffffff816d471c>] ip6_pol_route.isra.47+0x2fc/0x4f0

Regards

--
Julian Anastasov <ja@ssi.bg>
