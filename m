From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v2] ipvs: IPv6 tunnel mode
Date: Fri, 1 Oct 2010 10:48:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010011018270.1615@ja.ssi.bg>
References: <20100926133313.GA30560@verge.net.au>  <alpine.LFD.2.00.1009261721070.13702@u.domain.uli>  <1285767027.5670.51.camel@seasc0214>  <alpine.LFD.2.00.1010010056170.2209@ja.ssi.bg> <1285913303.5670.122.camel@seasc0214>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1285913303.5670.122.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Julius Volz <juliusv@google.com>


 	Hello,

On Fri, 1 Oct 2010, Hans Schillstrom wrote:

>>> - Leave it as is ?
>>
>>  	This 3th option is better for the moment. I think,
>> saddr is selected correctly, see ip6_dst_lookup() and
>> ip6_dst_lookup_tail() in net/ipv6/ip6_output.c
>> But if you think using ipv6_addr_copy(&iph->daddr, &cp->daddr.in6);
>> is working then feel free to post a patch on top of
>> the previous patch. Because other code in kernel uses
>> resulting fl.fl6_dst, not rt6i_dst.
>
> I prefer fl.fl6_dst right now since rt6i_dst gives a bad destination in
> many cases.
>
> I will do some more testing before posting the patch.

 	ok, but note that now 'fl' is hidden in function
and not cached. I think fl.fl6_dst is read-only, so it
should contain cp->daddr.in6 in all cases.

Regards

--
Julian Anastasov <ja@ssi.bg>
