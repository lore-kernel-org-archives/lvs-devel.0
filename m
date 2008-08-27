From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Wed, 27 Aug 2008 16:09:44 +1000
Message-ID: <20080827060943.GB3816@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <20080821011715.GG19235@verge.net.au> <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com> <20080821212948.GB4407@verge.net.au> <20080821220444.GA2758@verge.net.au> <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com> <1219399551.4246.10.camel@ernie.internal.graemef.net> <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com> <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net> <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Sven Wegener <sven.wegener@stealer.net>, Graeme Fowler <graeme@graemef.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, Aug 22, 2008 at 02:14:11PM +0200, Julius Volz wrote:
> On Fri, Aug 22, 2008 at 1:23 PM, Sven Wegener <sven.wegener@stealer.net> wrote:
> >> He :) Imagine an old kernel on the backup receiving new messages and
> >> not understanding them. How could we at least handle that situation
> >> gracefully (without totally confusing the older kernel)? We'd need to
> >> do it in a way that old features are still communicated in the same
> >> way. E.g., v4-only connection syncs still use the same message format,
> >> but once you use v6 entries, an unused flag or the 'reserved' field in
> >> ip_vs_sync_conn is used. A v6 message would still confuse an older
> >> kernel then, but a user would already notice that ipvsadm can't
> >> configure the v6 services on the older kernel, so that's not too bad.
> >
> > If that's a problem, we can easily change the communication port and even
> > completely redesign the protocol this way, without having old kernels
> > getting confused about the data they get. We might lose the ability to
> > sync between different versions, but in the end this is just the
> > connection synchronziation and both systems should be running the same
> > version. We could also keep the old communication port for some time, if
> > that's really needed.
> 
> Yes, starting from scratch on another port sounds like a good idea.
> Losing sync ability totally isn't as bad as confusing an older kernel
> with new messages, so I hope it's not necessary to keep the old
> baggage around?

That does sound like a nice idea. I think that is important that we don't
confuse older kernels. I guess the only time that ineroperability would be
important is when upgrading kernels, where you might want to take the
master ldirector down to upgrade it, then the standby.

> 
> Is there enough motivation for doing this though before having a
> cleaned-up minimal v6 version without the sync daemon? This is where
> I'm currently a bit stuck with... any help is appreciated :)

IPv6 without sync is fine by me. Its certainly much better than no IPv6.
Lets tackle sync a bit later.

