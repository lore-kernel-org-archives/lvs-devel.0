From: "Julius Volz" <juliusv@google.com>
Subject: IPVS IPv6: code and data structure reuse
Date: Thu, 24 Apr 2008 13:32:30 +0200
Message-ID: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1209036752; bh=HeK7PW3VVbejFrsIpi1DFxJhr94=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Content-Disposition; b=LJEw
	KU3hyPBzTcrSK9BURN/XSO64EvDHXfsrUVQgECforO2B3KQbQEtnEohhNvQpveTTphg
	tOoh3BpGrc6/UBg==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hi,

As promised a while ago, here come some random newbie thoughts and
questions :) Whilst doing some exploratory and dirty hacking on
extending IPVS code to support IPv6, I stumbled over a couple of
issues that should have been obvious, but that I hadn't really thought
of before (being a kernel novice):

If you want to make code depend on something that may be compiled as a
module (in this case, general IPv6 support), your code must be
compilable as a module too (well, duh!). So before thinking about
that, I wanted to have only a Y/N option for the IPVS IPv6 support,
but this will obviously not work out with that in mind.

This means that all IPv6 specific IPVS code would have to be very
cleanly separated from the old code (and not "interwoven" in some
parts) in order to live in separate modules. I first thought about
some functions or modules (say, IPVS schedulers) being able to support
both IPv4 and IPv6 in the same module (and even differentiating within
some of the same functions, data structures, etc.), so as to reduce
code duplication, but that seems harder now...

Would it still be ok to use some of the same data structures for both
IP versions, by optionally including IPv6 address fields and address
family specifiers in them? Like this:

union ip_vs_addr {
        __be32                  v4;
#ifdef CONFIG_IP_VS_IPV6
        struct in6_addr         v6;
#endif
};

struct some_ip_vs_struct {
        __u16 af;        /* address family */
        ...
        union ip_vs_addr caddr;
        union ip_vs_addr vaddr;
        union ip_vs_addr daddr;
        ...
};

The problem with this is that the IPv6 fields would still be in there,
wasting space, if the IPVS IPv6 code is configured as a module, but
not loaded. And in any case, IPv4 entries would be larger than needed
with the support for IPv6 enabled. That would probably be suboptimal
too, so would you have to duplicate all these data structures? You
could make them address-family agnostic and use opaque pointers to the
actual addresses, but that also adds some overhead.

Another option might be to have _all_ of IPVS depend on CONFIG_IPV6
once you enable IPv6 support for IPVS (and have that only as a Y/N
option). That way, you could still have easier and more reuse within
IPVS, but would that be acceptable?

After thinking about all this, it seems IPv6 in IPVS should be a
collection of separate modules anyways, right? Even if that means a
lot of duplication and extra maintenance (and maybe later, refactoring
to reduce the duplication)...

I'd be glad to hear any thoughts on this! Or if I'm basically on the
right track with my last statement...

Thanks,
Julius

-- 
Google Switzerland GmbH
