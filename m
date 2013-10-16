From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Wed, 16 Oct 2013 10:27:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310161015550.1560@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1381881751-6719-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>


	Hello,

On Wed, 16 Oct 2013, Simon Horman wrote:

> In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
> ip6_finish_output2()") changed the behaviour of ip6_finish_output2()
> such that it creates and uses a neigh entry if none is found.
> Subsequently the 'n' field was removed from struct rt6_info.

	Similar change in IPv4 opened the Pandora box:
IPVS, xt_TEE, raw.c (IP_HDRINCL). May be the corrsponding
places in IPv6 have the same problem.

	I don't know the IPv6 routing but if we find a way
to keep the desired nexthop in rt6i_gateway and to add
RTF_GATEWAY checks here and there such solution would be more
general. FLOWI_FLAG_KNOWN_NH flag can help, if needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
