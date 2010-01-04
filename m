From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Mon, 04 Jan 2010 07:34:33 -0800
Message-ID: <4B420A89.2010907@linux.intel.com>
References: <20091229015822.GF10172@verge.net.au> <4B41F453.1090802@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4B41F453.1090802@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>

On 1/4/2010 5:59, Patrick McHardy wrote:

[sorry for the late response, just got back from a good holiday, which means no work email access ;-) ]

> Simon Horman wrote:

>> I agree with Julian's assessment that your patch shouldn't be
>> necessary, but on the other hand I think that the checks are
>> reasonable. Your original patch made checks of the form of
>> "cmd>  IP_VS_SO_GET_MAX + 1". I have updated this to
>> "cmd>  IP_VS_SO_GET_MAX", as suggested by Julian, as the optmax
>> elements of struct nf_sockopt_ops set a non-inclusive range.
>>
>> http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/00852.html
>>
>> Index: net-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
>
> As a bugfix, this seems more appropriate for net-2.6.git. Please let
> me know which tree you want me to apply this to.

this really ought to go into 2.6.33.....
