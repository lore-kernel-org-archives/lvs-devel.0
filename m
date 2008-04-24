From: "Julius Volz" <juliusv@google.com>
Subject: Re: IPVS IPv6: code and data structure reuse
Date: Thu, 24 Apr 2008 17:38:18 +0200
Message-ID: <f4845fc0804240838s342149f2v3113ae44ff773f87@mail.gmail.com>
References: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com>
	 <Pine.LNX.4.64.0804240516440.12876@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1209051500; bh=uQXMjJGtrw4VyDBtgNr7TF4BR/8=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=iW8CRbF9lRXw62LcBRSLvl3AUxJO5ygk
	ZDkOLtaIECAyQJTdsBUrdjKg9CZuUBuR8t8nQ+DFDtxvtzGnyAtgLw==
In-Reply-To: <Pine.LNX.4.64.0804240516440.12876@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Joseph Mack NA3T <jmack@wm7d.net>

Hi Joe,

On Thu, Apr 24, 2008, Joseph Mack NA3T wrote:
> On Thu, 24 Apr 2008, Julius Volz wrote:
>  I'm replying in case no one else does, not because I have any good answers.

Thanks! Any conversation helps clarify things!

>  How is the coding done in netfilter/ipv6? How about *BSD?

Don't know about *BSD, but from my quick look at Netfilter, they seem
to basically duplicate everything for IPv6...

> > This means that all IPv6 specific IPVS code would have to be very cleanly
> separated from the old code
> >
>
>  I would think it better to have code that works, that has asthetic
> problems, than to have a whole pile of perfectly written code that never got
> released because you ran out of time. Someone else can clean it up later if
> the asthetics are that big a problem.

Yeah, with "cleanly separated" I actually really meant just separating
it in a way that actually compiles, links and works somehow when it
depends on a modular CONFIG_IPV6, not really worrying about aesthetics
yet.

About running out of time: The good thing is that I can still continue
on this regardless of my current employer, since the project is
interesting by itself ;)

> > Would it still be ok to use some of the same data structures for both
> > IP versions, by optionally including IPv6 address fields and address
> > family specifiers in them? Like this:
> >
> > union ip_vs_addr {
> >       __be32                  v4;
> > #ifdef CONFIG_IP_VS_IPV6
> >       struct in6_addr         v6;
> > #endif
> > };
> >
>
>  kernel people moan about #ifdefs but I don't know what they do to get
> around them.

The #ifdef in this case isn't so bad in itself, no. It's just that the
optional block will still be included if the code for the
corresponding CONFIG variable has been compiled as a module, but not
been loaded. Nothing would break, there just would be some wasted
space.

>  What if IPV6 in not turned on in NETWORKING and you don't have an #ifdef
> here, will in6_addr wind up being some NULL struct which will/can be
> ignored?

In that case, the union would just always be bigger than necessary as
it contains enough space for an IPv6 address. Since IPv6 code wouldn't
be loaded, the IPv6 union member would just never be accessed, so
nothing bad would happen.

> > The problem with this is that the IPv6 fields would still be in there,
> wasting space,
> >
>
>  the kernel is so large now, I don't think there can be any realistic claims
> on not wasting space.

Yeah, I guess the only place where this could add a relevant (but
still small) size increase is in the connection table, since that can
hold a lot of entries. But then again, connection entries are pretty
big already anyways.

>  sounds good to me. I wouldn't worry about this a whole lot just yet. I
> would be quite happy if in the first version ipv6 for ipvs came out with no
> user options - it's turned on whether the user wants it or not. The next
> iteration would be if IPV6 is turned on in NETWORKING, then ipv6 is turned
> on in ipvs. I wouldn't go beyond that - you want the kernel config to be as
> simple as possible. Anyone who wants ipv6 off in ipvs(), while turning on
> IPV6 in NETWORKING can go figure it out for themselves.

Well, to turn on IPv6 in IPVS, you really _have_ to turn on IPv6 in
the kernel in general, since you'll be using and linking against that
code. So your first suggestion wouldn't be possible, but the other
ones sound fine and I might take that path!

> > After thinking about all this, it seems IPv6 in IPVS should be a
> collection of separate modules anyways, right? Even if that means a lot of
> duplication and extra maintenance (and maybe later, refactoring to reduce
> the duplication)...
> >
>
>  you can't count on maintenance (the big cost in code is not writing it, but
> maintaining it). There's not a lot of people paying attention to ipvs() and
> you should plan on any code you submit to be in there unchanged for quite
> some time. You can see how few other people have wanted to tackle ipv6 for

That's fine. Usually people only change things if they really find
something that doesn't work for them and they need it desperately.
Having less fluctuation in that part of the kernel makes it easier to
start hacking on though.

> ipvs(). I would have/use as much code from the IPV6 layer as possible, where
> other people will maintain it, and have as little new code in ipvs() as
> possible, presumably just duplicated lines (with #ifdefs) making the ipv6
> rather than ipv4 call.

Sure, the plan was to keep the IPv6 code similar to the old version,
but with the IPv4 calls replaced by ones to the IPv6 layer. As IPv6
isn't only about bigger addresses, some of the mechanisms (different
ICMPv6 messages, different fragmentation issues, various types of
extension headers) will also have to be adjusted, but that can also
evolve over time as it is noticed. I don't know all of the correct
replacements yet, but I guess we'll figure them out as we go along.

>  ipvs() is basically one module now. I wouldn't code up a collection of
> modules. The user will have to go figure out all the modules to load to get
> ipvs_ipv6 to work. This is a lot to ask. I think keeping ipvs() as one
> module would be best. Next option would be having an ipvs() and an
> ipvs_ipv6().

Well, we have a collection of modules already, one for the IPVS core,
one for each scheduler and one for the FTP protocol helper. So having
a couple more is not too bad and they should be loaded automatically
when needed anyways ;)

>  Thanks for plugging away at this.

I'm doing what I can :) Thanks for the support!

Julius

-- 
Google Switzerland GmbH
