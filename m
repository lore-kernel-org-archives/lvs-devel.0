From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Wed, 27 Oct 2010 22:58:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010272249030.1643@ja.ssi.bg>
References: <201010261300.09827.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg> <201010271119.21590.hans.schillstrom@ericsson.com> <201010271433.06982.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010271433.06982.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>


 	Hello,

On Wed, 27 Oct 2010, Hans Schillstrom wrote:

>> A New Spec of Type field:
>>
>> Bit    7        6        . . .      2         1           0
>>   +----------+--------------------------+-------------+-------+
>>   | Opt.Data |          Spare           | Packed IPv6 |  IPv6 |
>>   +----------+--------------------------+-------------+-------+
>
> I can see a better usage of it in Option Type so Type will look like this
>    +-------------------------------------+-------------+-------+
>    |                     Spare           | Packed IPv6 |  IPv6 |
>    +-------------------------------------+-------------+-------+
>
> And "Option Type" in option field would look like this
>
> Bit    7        6        . . .    0    7                      0
>   +----------+----------------------+---------------------------+
>   | Optional |      Option type     |    Option length          |
>   +----------+----------------------+---------------------------+
>
> We can have a better fine tuning of options in this way.

 	Yes, that is exactly my idea. I more like the name
"Parameter" instead of "Option", i.e. we have additional
parameters that can be mandatory (usually) but also can be
optional. For now I don't have idea for any optional
parameters but allocating 1 bit for this does not look
fatal.

> I.e. as Julian wrote but transferd to Option Type:
>
> " If backup does not recognize some type it will skip the
>  connection entry if bit 7 is not set."
>
> --
> Regards
> Hans Schillstrom <hans.schillstrom@ericsson.com>

Regards

--
Julian Anastasov <ja@ssi.bg>
