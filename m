From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Tue, 2 Dec 2008 16:16:04 -0700 (MST)
Message-ID: <49597.86.34.32.157.1228259764.squirrel@mail.embedromix.ro>
References: <55785.91.201.80.240.1227862171.squirrel@mail.embedromix.ro>
    <Pine.LNX.4.64.0811280653570.21298@wm7d.net>
    <54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>
    <20081202.145129.06176881.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20081202.145129.06176881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> Date: Tue, 2 Dec 2008 08:34:22 -0700 (MST)
>
>> Hello, Joe!
>>
>> > On Fri, 28 Nov 2008, Catalin(ux) M. BOIE wrote:
>> >
>> >> Hello, Joe!
>> >>
>> >> No, I did not measure it, but, I read the help text:
>> > .
>> > .
>> >> The help is wrong or I am missing something?
>> >
>> > there's a bit somewhere else in the same section saying not
>> > to change the hash size unless you know more than we do :-)
>>
>> Where, exactly?
>>
>> So, should I not change it at all even if I have a great number of
>> simultaneously connections?

Hello, David!

> You should only ever change something like this if you actually
> observe a specific performance problem.

I have a need, I didn't wake up some day and I dreamed to change this.
I have a gateway with LVS and I have 4 web servers behind.
I saw the help text at that option and I saw that I could raise the limit.

> This is the part that is driving everybody crazy about your
> report.  You seem to be changing this without having observed
> a measurable performance problem first, and then tracked it down
> specifically to this hash table's size.

I was looking for anything that could get me past of 88.000 request per
seconds.
The help text told me to raise that value if I have big number of
connections. I just needed an easy way to test.

> You seem to want to change it because it seems to you like that is
> what should be done.  You don't really know if it even matters or not
> for your workload.

Without easy testing (boot time change not compile time change) is hard to
tell if it helps me or not.

Anyway, if the help text is wrong, let's correct it.
If it is correct, let's allow changing that value at runtime, so people
can easy juggle with it.

Do you agree, David?

Thank you.

-- 
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/

