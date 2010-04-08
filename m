From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: replace sprintf to snprintf to avoid stack buffer
 overflow
Date: Thu, 08 Apr 2010 13:37:44 +0200
Message-ID: <4BBDC008.2050306@trash.net>
References: <20100406025020.GA2741@localhost.localdomain> <20100406032248.GF30359@verge.net.au> <4BBCAE52.9080501@trash.net> <20100407223445.GA15810@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100407223445.GA15810@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: wzt.wzt@gmail.com, linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Simon Horman wrote:
> On Wed, Apr 07, 2010 at 06:09:54PM +0200, Patrick McHardy wrote:
>> Simon Horman wrote:
>>> On Tue, Apr 06, 2010 at 10:50:20AM +0800, wzt.wzt@gmail.com wrote:
>>>> IPVS not check the length of pp->name, use sprintf will cause stack buffer overflow.
>>>> struct ip_vs_protocol{} declare name as char *, if register a protocol as:
>>>> struct ip_vs_protocol ip_vs_test = {
>>>>         .name =			"aaaaaaaa....128...aaa",
>>>> 	.debug_packet =         ip_vs_tcpudp_debug_packet,
>>>> };
>>>>
>>>> when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED", pp->name); 
>>>> will cause stack buffer overflow.
>>>>
>>>> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
>>> I think that the simple answer is, don't do that.
>> Indeed.
>>
>>> But your patch seems entirely reasonable to me.
>>>
>>> Acked-by: Simon Horman <horms@verge.net.au>
>>>
>>> Patrick, please consider merging this.
>> I think this fix is a bit silly, we can simply print the name in
>> the pr_debug() statement and avoid both the potential overflow
>> and truncation.
>>
>> How does this look?
> 
> Looks good to me:
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Thanks, I've applied the patch.
