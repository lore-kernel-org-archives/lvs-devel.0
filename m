From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v6 PATCH 0/8] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Sun, 21 Nov 2010 00:52:47 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011210048330.5144@ja.ssi.bg>
References: <201011191424.56351.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011192220060.1670@ja.ssi.bg> <20101120220709.GN3914@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101120220709.GN3914@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>, Hans Schillstrom <hans@schillstrom.com>


 	Hello,

On Sun, 21 Nov 2010, Simon Horman wrote:

> On Fri, Nov 19, 2010 at 10:22:40PM +0200, Julian Anastasov wrote:
>>
>> 	Hello,
>>
>> On Fri, 19 Nov 2010, Hans Schillstrom wrote:
>>
>>> This patch series adds/(updates) the following functionality
>>> in the synchronization between master and backup daemons.
>>>
>>> - IPv6
>>> - Persistence Engine
>>> - Firewall marks transferred
>>> - Time-outs transferred.
>>> - Flag field increased to 32 bits.
>>
>>> *v6
>>> Patch 4 Handling scheduling errors, was forgotten it has also been rewritten.
>>> see comments in that patch
>>
>> 	v6 looks ok to me, thanks!
>
> These look good to me too.
> Julian, can I add acked-by you?

 	Yes

Acked-by: Julian Anastasov <ja@ssi.bg>

Regards

--
Julian Anastasov <ja@ssi.bg>
