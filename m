From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Thu, 27 Nov 2008 00:05:50 -0700 (MST)
Message-ID: <41063.91.201.80.240.1227769550.squirrel@mail.embedromix.ro>
References: <1227706578-5449-1-git-send-email-catab@embedromix.ro>
    <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
    <20081126.152748.244331470.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20081126.152748.244331470.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hello!

> From: Joseph Mack NA3T <jmack@wm7d.net>
> Date: Wed, 26 Nov 2008 06:40:02 -0800 (PST)
>
>> On Wed, 26 Nov 2008, Catalin(ux) M. BOIE wrote:
>>
>> > I was very frustrated about the fact that I have to recompile the
>> kernel
>> > to change the hash size. So, I created this patch.
>>
>> thanks for sending us the code.
>>
>> Why do you need to change the hash size? We really don't recommend
>> anyone do this under normal circumstances
>
> In any event, this should be dynamically sized at run time.

David, thank you very much for feedback.

Do you mean that it should be computed based on memory size or you mean
that it should be changeable on-the-fly, even when we have some
connections in the tables already?

Because I really need this now, can we, pretty please, apply it as it is
because is an improvement over what we have now? And, I promise that I
will make it changeable at runtime.
Deal? :)
Or you do not want to have another legacy around?

Do you have some hints (where to look for a similar thing)?
The thing that worries me a little is the locking around the move and
maybe the latency involved. Yes, of course you will not change it several
times per minute, but...

Thank you very much!

-- 
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/

