From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: Move IPVS to net/netfilter/ipvs
Date: Thu, 02 Oct 2008 11:37:18 +0200
Message-ID: <48E4964E.5090806@trash.net>
References: <f4845fc0809190345k1d9f8ba6i53d891548ddb0565@mail.gmail.com> <20080921235355.GA1342@verge.net.au> <20080922000748.GE1342@verge.net.au> <20081001060725.GA28433@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20081001060725.GA28433@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>

Simon Horman wrote:
>> http://www.vergenet.net/~horms/tmp/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.2.patch
>>     
>
> Hi Patrick,
>
> could you take a moment to look at this?
> Unfortunately the patch is too long to post to the list
> but it really is as simple as the description (below) claims.
>
> I can handle the patch longness problem by pushing it into
> lvs-2.6 and getting Dave to do a pull from there. But I'd
> like to make sure that the move is ok with you first.
>   

I'm fine with this move. Probably easier if Dave takes it directly from
you since I usually send my patches as patches and this one is really
huge :)
