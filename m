From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 13:23:04 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>  <20080821011715.GG19235@verge.net.au>  <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>  <20080821212948.GB4407@verge.net.au>  <20080821220444.GA2758@verge.net.au> 
 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>  <1219399551.4246.10.camel@ernie.internal.graemef.net> <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Graeme Fowler <graeme@graemef.net>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, 22 Aug 2008, Julius Volz wrote:

> On Fri, Aug 22, 2008 at 12:05 PM, Graeme Fowler <graeme@graemef.net> wrote:
> > On Fri, 2008-08-22 at 11:56 +0200, Julius Volz wrote:
> >> There's also a '__u8 reserved' field at the beginning of that struct
> >> which could be used. But in general, is it reasonable to expect both
> >> nodes to use the same kernel version, which gets rid of the
> >> extensibility problems? It's not really an ABI that can't be broken,
> >> right?
> >
> > I think from an operational (ie. end user) perspective, ABI breakage is
> > something to try to avoid but _not_ at all costs.
> >
> > If it's possible to extend the sync daemon protocol by reusing the
> > existing code and ABI, all well and good; however if a fundamental
> > change is made which breaks the old sync daemon ABI then as long as it's
> > documented and we make sure that users know to have the same (or higher)
> > kernel versions on their directors then everyone wins.
> 
> Yeah, and it's not an ABI, it's a very specialized protocol between
> two kernels, so the rules are less clear. However, I totally agree
> with you that it's not convenient from the users' point of view.
> 
> >> Yes, without jumping through hoops, we have to probably break the
> >> current protocol anyways for new features? Even if we designated
> >> unused fields for new information, an old kernel will not look at them
> >> / fill them out, which limits the possibilities...
> >
> > I guess that as and when this change is made and gets into mainline
> > releases, Joe and I will have to have a mantra of "ensure your directors
> > are using the same kernel version" in response to queries on
> > lvs-users :)
> 
> He :) Imagine an old kernel on the backup receiving new messages and
> not understanding them. How could we at least handle that situation
> gracefully (without totally confusing the older kernel)? We'd need to
> do it in a way that old features are still communicated in the same
> way. E.g., v4-only connection syncs still use the same message format,
> but once you use v6 entries, an unused flag or the 'reserved' field in
> ip_vs_sync_conn is used. A v6 message would still confuse an older
> kernel then, but a user would already notice that ipvsadm can't
> configure the v6 services on the older kernel, so that's not too bad.

If that's a problem, we can easily change the communication port and even 
completely redesign the protocol this way, without having old kernels 
getting confused about the data they get. We might lose the ability to 
sync between different versions, but in the end this is just the 
connection synchronziation and both systems should be running the same 
version. We could also keep the old communication port for some time, if 
that's really needed.

Sven
