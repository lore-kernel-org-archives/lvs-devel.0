From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension  header handling in
 IPVS
Date: Wed, 29 Aug 2012 14:34:34 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208291429160.26100@stinky-local.trash.net>
References: <nhkcv8u.3c7ad6d61f90aef8e9467df88476311d@obelix.schillstrom.com>
 <1346240770.3069.477.camel@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1346240770.3069.477.camel@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org

On Wed, 29 Aug 2012, Jesper Dangaard Brouer wrote:

> To Patrick,
>
> On Wed, 2012-08-29 at 11:47 +0200, Hans Schillstrom wrote:
>>>
>>> On Mon, 2012-08-27 at 14:02 +0200, Patrick McHardy wrote:
>>>> On Mon, 27 Aug 2012, Hans Schillstrom wrote:
>>>>
>>>>>>>> How about we change netfilter to set up the skb's transport header
>>>>>>>> at an early time so we can avoid all (most of) these header scans
>>>>>>>> in netfilter?
>>>>>>>
>>>>>>> I think that would be great, maybe it should be global i.e. not only a netfilter issue.
>>>>>>
>>>>>> I think in most other cases the headers are supposed to be processed
>>>>>> sequentially. One problem though - to be useful for netfilter/IPVS
>>>>>> we'd also need to store the transport layer protocol somewhere.
>>>>>
>>>>> I guess that's the problem, adding it to the skb will not be popular ....
>>>>> Right now I don't have a good solution, maybe a more generic netfilter ptr in the skb ...
>>>>
>>>> I guess inet6_skb_parm will be at least slightly more popular than
>>>> adding it to the skb itself. The netfilter pointers are all used for
>>>> optional things, so we can't really add it to any of those.
>>>
>>> Okay, but how do we go from here?
>>>
>>> Hans, should this hold back the patch ("ipvs: Fix faulty IPv6 extension
>>> header handling in IPVS").  Or should we pursue our patch, and circle
>>> back later once e.g. Patrick have found a generic solution for IPv6
>>> transport header handling?
>>
>> Should we give it a try to put it in inet6_skb_parm
>> and minimize what we put there ?
>> I think it could be worth it.
>
> Okay, but then I do need some help and guidance, especially from
> Patrick, think.
>
> First of all, where in the netfilter code, should we update the new
> fields in inet6_skb_parm?

Good question. I think we'd need at least three spots since every one
of these subsystems can be used indepedently from each other:

- conntrack/IPVS: PRE_ROUTING/LOCAL_OUT at lowest priority
- ip6tables: first time packet hits ip6t_do_table()?

Actually, looking at ipv6_rcv(), this might not work at all since it
sets skb->transport_header to the first header following the IPv6
header. This is used when processing extension headers by IPv6.


