From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 16:19:54 +0200
Message-ID: <4859198A.9070503@trash.net>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>	 <48528EED.7090307@trash.net>	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>	 <485652EA.2020004@trash.net>	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>	 <485819A8.1090004@trash.net>	 <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>	 <4858CDDF.4050306@trash.net> <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Wed, Jun 18, 2008 at 10:57 AM, Patrick McHardy <kaber@trash.net> wrote:
>>>> As I mentioned above, you usually want a MASK in combination
>>>> with flags to allow to unset them. This is best done using
>>>> a structure.
>>>>
>>> Hm, I'm not sure if I understand exactly what this struct is supposed
>>> to look like. Could you give an example?
>>>
>> struct {
>>   u32 flags;
>>   u32 mask;
>> } flags;
>>
>> and then:
>>
>> obj->flags = (obj->flags & ~flags->mask) |
>>                   (flags->flags | flags->mask);
> 
> Ah, I see. The second line should read "(flags->flags & flags->mask)", right?

Yes.

> Looking at how these "flags" are actually used in ipvsadm, I'm not
> sure this would be needed here:
> 
> 1) destination conn_flags are only set to successive integer values 0,
> 1, 2... (depending on the forwarding method), which are mutually
> exclusive. Only internally in the kernel are other bits of this field
> used in a flag-like fashion. So this Netlink attribute could be
> renamed to something like *_FWD_METHOD and be a normal value field.

Yes. The internal fields shouldn't be exported to userspace
unless necessary.

> 2) for the service flags, only one bit is set from userspace
> (persistent/nonpersistent service). So this might be not too bad to
> have as a single Netlink flag attribute.

And this bit can't be unset (or if it currently can't be,
it also wouldn't make sense to be able to unset it)?
