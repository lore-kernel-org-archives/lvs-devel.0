From: Mark Bergsma <mark@wikimedia.org>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Tue, 05 Jan 2010 12:02:20 +0100
Message-ID: <4B431C3C.5080203@wikimedia.org>
References: <20091229013401.GE10172@verge.net.au> <4B41F3C2.6050006@trash.net> <20100104232445.GC2554@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100104232445.GC2554@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Catalin(ux) M. BOIE" <catab@embedromix.ro>, Joseph Mack NA3T <jmack@wm7d.net>, Graeme Fowler <graeme@graemef.net>, David Miller <davem@davemloft.net>

On 05-01-10 00:24, Simon Horman wrote:
> On Mon, Jan 04, 2010 at 02:57:22PM +0100, Patrick McHardy wrote:
>> Simon Horman wrote:
>>> On Mon, Dec 28, 2009 at 07:49:38PM +0100, Mark Bergsma wrote:
>>>> On 03-12-08 01:37, David Miller wrote:
>>>>> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
>>>>> Date: Tue, 2 Dec 2008 16:16:04 -0700 (MST)
>>>>>> I was looking for anything that could get me past of 88.000 request per
>>>>>> seconds.
>>>>>> The help text told me to raise that value if I have big number of
>>>>>> connections. I just needed an easy way to test.
>>>>> You're just repeating what I said, you "think" it should be
>>>>> changed and as a result you are wasting everyones time.
>>>>>
>>>>> You don't actually "know", you're just guessing using random
>>>>> snippets from documentation rather than good hard evidence of
>>>>> a need.
>>>> Hello,
>>>>
>>>> I just found this year-old thread about a patch allowing the IPVS
>>>> connection hash table size to be set at load time by a module parameter.
>>>> Apparently the conclusion reached was that allowing this configuration
>>>> setting to be changed would be useless, and that the poster's
>>>> performance problems would likely lie elsewhere, since he had no
>>>> evidence it was caused by the hash table size.
>>>
>>> Hi Mark,
>>>
>>> thanks for your test results. I have added them to the patch.
>>> Feel free to edit the text.
>>
>> Just wondering because of this comment - do you want me to apply this
>> patch?
> 
> I was fishing for an response from Mark.
> I'll resubmit it properly as that doesn't seem to be forthcoming.

Hi Simon/Patrick,

Sorry for the late reply, and yes, this is fine. Thanks for applying the
patch!

-- 
Mark Bergsma <mark@wikimedia.org>
Operations Engineer, Wikimedia Foundation
