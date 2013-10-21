From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] ipv6: fill rt6i_gateway with nexthop address
Date: Mon, 21 Oct 2013 18:42:05 -0400 (EDT)
Message-ID: <20131021.184205.2063781996744790668.davem@davemloft.net>
References: <1382272985-1528-3-git-send-email-ja@ssi.bg>
	<20131021050159.GE28333@order.stressinduktion.org>
	<alpine.LFD.2.03.1310211009270.1522@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.03.1310211009270.1522@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, yoshfuji@linux-ipv6.org

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 21 Oct 2013 10:31:06 +0300 (EEST)

> 	Thanks for the review! I don't mind too about
> removing rt6_nexthop. For me it is 51% against 49% to keep it
> as it denotes the places that use nexthop and not gateway.
> May be more opinions will help to decide because I don't know
> if there are any plans to use similar techniques as done for IPv4.

I have no strong opinion about removing rt6_nexthop.

If it is of low cost today and makes the code easier to
undersand and grep, just leave it alone.
