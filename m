From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] ipvs: load balance ipv6 connections from a local
 process
Date: Fri, 05 Sep 2008 11:55:44 -0400
Message-ID: <48C15680.7010004@hp.com>
References: <20080905013609.GD14128@verge.net.au>	 <20080905013755.GE14128@verge.net.au> <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

Julius Volz wrote:
>> -out:
>> -       __ip_vs_conn_put(cp);
>> -
>> -       return verdict;
>> +       snet.in6 = iph->saddr;
> 
> I've always been told to use ipv6_addr_copy() for this. I'm not sure
> what the problem with the direct struct assignment is though... would
> be nice if someone could explain.

Because an in6_addr is a union of 4 u32's, which won't all be copied in 
a struct assignment.  That's the way I've always understood it.

-Brian
