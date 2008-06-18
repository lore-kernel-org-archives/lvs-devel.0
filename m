From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 10:57:03 +0200
Message-ID: <4858CDDF.4050306@trash.net>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>	 <20080613062621.GA10474@verge.net.au>	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>	 <48528EED.7090307@trash.net>	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>	 <485652EA.2020004@trash.net>	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>	 <485819A8.1090004@trash.net> <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Tue, Jun 17, 2008 at 10:08 PM, Patrick McHardy <kaber@trash.net> wrote:
>   
>> IPVS_LIST_ELEM                  - NLA_NESTED
>>
>> for list elements of every kind. Since you can only put one
>> kind of element in the lists anyway (I think), different
>> types don't allow any increased flexibility and the LIST
>> naming is more clear in my opinion.
>>     
>
> However, since these container attributes (for daemons, services and
> dests) also appear as single elements outside of lists, it might be
> better to reuse the same names inside the list?
>   

I didn't realize that. Yes, agreed.

>>> IPVS_SVC_ATTR_FLAGS             - NLA_U32
>>>       
>> As I mentioned above, you usually want a MASK in combination
>> with flags to allow to unset them. This is best done using
>> a structure.
>>     
>
> Hm, I'm not sure if I understand exactly what this struct is supposed
> to look like. Could you give an example?
>   
struct {
    u32 flags;
    u32 mask;
} flags;

and then:

obj->flags = (obj->flags & ~flags->mask) |
                    (flags->flags | flags->mask);

>>> IPVS_SVC_ATTR_TIMEOUT           - NLA_U32
>>> IPVS_SVC_ATTR_NETMASK           - NLA_U32
>>>       
>> Shouldn't this also be able to carry IPv6 masks?
>>     
>
> We only need the prefix length for IPv6, for which we reused the
> netmask field. This (only slightly) changes the semantics of the field
> between address families. Acceptable or better have a separate field
> for the prefix length?
>   
I guess thats fine.

>>> IPVS_SVC_ATTR_NUM_DESTS         - NLA_U32
>>>       
>> Is this number related to the IPVS_ENTRY_ATTR_DESTS list?
>> If so, it shouldn't be contained as seperate attribute,
>> that just allows for potential inconsistency.
>>     
>
> Yes, but this count is only returned from commands that do not at the
> same time return the list of destinations, so there is no
> inconsistency within a message. However, I'm pretty sure the count was
> only used in the old interface to allocate enough memory for the
> destination list, so it can probably be deleted anyways.
>   

You're probably right, this looks similar to iptables.

