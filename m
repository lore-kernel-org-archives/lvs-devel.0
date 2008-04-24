From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: IPVS IPv6: code and data structure reuse
Date: Thu, 24 Apr 2008 05:57:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804240516440.12876@wm7d.net>
References: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org

On Thu, 24 Apr 2008, Julius Volz wrote:


Hi Julius,

I'm replying in case no one else does, not because I have 
any good answers.

How is the coding done in netfilter/ipv6? How about *BSD?

> This means that all IPv6 specific IPVS code would have to 
> be very cleanly separated from the old code

I would think it better to have code that works, that has 
asthetic problems, than to have a whole pile of perfectly 
written code that never got released because you ran out of 
time. Someone else can clean it up later if the asthetics 
are that big a problem.

> Would it still be ok to use some of the same data structures for both
> IP versions, by optionally including IPv6 address fields and address
> family specifiers in them? Like this:
>
> union ip_vs_addr {
>        __be32                  v4;
> #ifdef CONFIG_IP_VS_IPV6
>        struct in6_addr         v6;
> #endif
> };

kernel people moan about #ifdefs but I don't know what they 
do to get around them.

What if IPV6 in not turned on in NETWORKING and you don't 
have an #ifdef here, will in6_addr wind up being some NULL 
struct which will/can be ignored?

> The problem with this is that the IPv6 fields would still 
> be in there, wasting space,

the kernel is so large now, I don't think there can be any 
realistic claims on not wasting space.

> Another option might be to have _all_ of IPVS depend on 
> CONFIG_IPV6 once you enable IPv6 support for IPVS (and 
> have that only as a Y/N option). That way, you could still 
> have easier and more reuse within IPVS, but would that be 
> acceptable?

sounds good to me. I wouldn't worry about this a whole lot 
just yet. I would be quite happy if in the first version 
ipv6 for ipvs came out with no user options - it's turned on 
whether the user wants it or not. The next iteration would 
be if IPV6 is turned on in NETWORKING, then ipv6 is turned 
on in ipvs. I wouldn't go beyond that - you want the kernel 
config to be as simple as possible. Anyone who wants ipv6 
off in ipvs(), while turning on IPV6 in NETWORKING can go 
figure it out for themselves.

> After thinking about all this, it seems IPv6 in IPVS 
> should be a collection of separate modules anyways, right? 
> Even if that means a lot of duplication and extra 
> maintenance (and maybe later, refactoring to reduce the 
> duplication)...

you can't count on maintenance (the big cost in code is not 
writing it, but maintaining it). There's not a lot of people 
paying attention to ipvs() and you should plan on any code 
you submit to be in there unchanged for quite some time. You 
can see how few other people have wanted to tackle ipv6 for 
ipvs(). I would have/use as much code from the IPV6 layer as 
possible, where other people will maintain it, and have as 
little new code in ipvs() as possible, presumably just 
duplicated lines (with #ifdefs) making the ipv6 rather than 
ipv4 call.

ipvs() is basically one module now. I wouldn't code up a 
collection of modules. The user will have to go figure out 
all the modules to load to get ipvs_ipv6 to work. This is a 
lot to ask. I think keeping ipvs() as one module would be 
best. Next option would be having an ipvs() and an 
ipvs_ipv6().

Thanks for plugging away at this.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
