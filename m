From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Thu, 4 Dec 2008 00:47:51 -0700 (MST)
Message-ID: <48003.91.201.80.240.1228376871.squirrel@mail.embedromix.ro>
References: <55785.91.201.80.240.1227862171.squirrel@mail.embedromix.ro>
    <Pine.LNX.4.64.0811280653570.21298@wm7d.net>
    <54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>
    <20081202.145129.06176881.davem@davemloft.net>
    <49597.86.34.32.157.1228259764.squirrel@mail.embedromix.ro>
    <1228338713.24149.10.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1228338713.24149.10.camel@ernie.internal.graemef.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Graeme Fowler <graeme@graemef.net>
Cc: David Miller <davem@davemloft.net>, jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


> On Tue, 2008-12-02 at 16:16 -0700, Catalin(ux) M. BOIE wrote:
>> I have a need, I didn't wake up some day and I dreamed to change this.
>> I have a gateway with LVS and I have 4 web servers behind.
>> I saw the help text at that option and I saw that I could raise the
>> limit.
>
> OK, let's ask the same question a different way, after going a little
> further into your posting:
>
>> I was looking for anything that could get me past of 88.000 request per
>> seconds.
>> The help text told me to raise that value if I have big number of
>> connections. I just needed an easy way to test.
>
> OK, so from here:
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.operation.html#hash_table
>
> and onward... have you read all of that? It explains how the hash table
> size has been developed over the years, and everything that has changed
> with and relating to it.
>
> To pull out an example, a hash table size of 21 bits does not give a
> connection limit of 2^21 entries, since each part of the hash is a
> linked list which contains multiple entries, up to the RAM limit in the
> server.
>
> In the HOWTO, the example given shows that for a traffic pattern with 4
> seconds session coherence and 1/8th of the traffic hitting the director
> being a SYN for the available config *appears* to require 2^21 bits.
> However, because each bit of the hash is a linked list, using 17 bits
> gets 16 entries in each list - this is not a problem, as it takes the
> CPU no time at all to search 16 entries.
>
> What you need to do for us, please, is to demonstrate that your problem
> (not exceeding 88k RPS) is categorically something to do with lookups in
> the hash table. I suspect (although I've been wrong before) that your
> problem is probably to do with the number of interrupts your hardware
> can process. There have been many posts of this type on lvs-users
> recently - search the archives to see what the solutions were.
>
> We're trying to help, but the collective wisdom here is that the hash
> table size is not the cause of your problem *which you haven't yet
> described fully*.
>
> Graeme
>

Hello!

After some replys I understood that I explained very bad what was my
intention.

I was not complaining that hash size is too low or too high.
I just provided a patch that I found useful: allow easy changing of a
variable at boot time and not to recompile the kernel to change it.

So, I didn't hit the stage when I do some tests to prove that the hash
size is too low/high.

After all you guys explained to me, it is pretty obvious that I will have
bigger problems than the walking of a linked list too deep.

So, I agree, my patch is useless.

Again, sorry for eating your precious time with this!

Thank you very much!

-- 
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/

