From: Graeme Fowler <graeme@graemef.net>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Sat, 23 Aug 2008 10:20:06 +0100
Message-ID: <1219483206.10379.5.camel@ernie.internal.graemef.net>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
	 <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
	 <20080821212948.GB4407@verge.net.au> <20080821220444.GA2758@verge.net.au>
	 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
	 <1219399551.4246.10.camel@ernie.internal.graemef.net>
	 <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
	 <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net>
	 <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julius Volz <juliusv@google.com>
Cc: Sven Wegener <sven.wegener@stealer.net>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, 2008-08-22 at 14:14 +0200, Julius Volz wrote:
> Yes, starting from scratch on another port sounds like a good idea.
> Losing sync ability totally isn't as bad as confusing an older kernel
> with new messages, so I hope it's not necessary to keep the old
> baggage around?

I agree - having a new sync daemon which can deal with v6 entries aswell
as v4 entries would be a good way to work; the legacy code can then be
retired at a later date with minimal end-user impact.

> Is there enough motivation for doing this though before having a
> cleaned-up minimal v6 version without the sync daemon? This is where
> I'm currently a bit stuck with... any help is appreciated :)

Well, as someone else mentioned on lvs-users recently "I couldn't code
my way out of a wet paper bag in C" so I'm not much help on that front,
however I feel that getting the minimal working feature set going first
and then adding the sync code later is probably a good way to proceed.

This also gives us a development timeline that we can offer to
interested parties, along the lines of:

2008-10 Minimal IPv6 functionality
2008-?? Full IPv6 functionality matching IPv4 features, no IPv6 sync
2009-?? Restructured sync daemon with full IPv4 and IPv6 support

Horms, Joe - do you agree that this is a good idea?

Graeme

