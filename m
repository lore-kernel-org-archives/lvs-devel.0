From: Graeme Fowler <graeme@graemef.net>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 11:05:51 +0100
Message-ID: <1219399551.4246.10.camel@ernie.internal.graemef.net>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
	 <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
	 <20080821212948.GB4407@verge.net.au> <20080821220444.GA2758@verge.net.au>
	 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On Fri, 2008-08-22 at 11:56 +0200, Julius Volz wrote:
> There's also a '__u8 reserved' field at the beginning of that struct
> which could be used. But in general, is it reasonable to expect both
> nodes to use the same kernel version, which gets rid of the
> extensibility problems? It's not really an ABI that can't be broken,
> right?

I think from an operational (ie. end user) perspective, ABI breakage is
something to try to avoid but _not_ at all costs.

If it's possible to extend the sync daemon protocol by reusing the
existing code and ABI, all well and good; however if a fundamental
change is made which breaks the old sync daemon ABI then as long as it's
documented and we make sure that users know to have the same (or higher)
kernel versions on their directors then everyone wins.

> Yes, without jumping through hoops, we have to probably break the
> current protocol anyways for new features? Even if we designated
> unused fields for new information, an old kernel will not look at them
> / fill them out, which limits the possibilities...

I guess that as and when this change is made and gets into mainline
releases, Joe and I will have to have a mantra of "ensure your directors
are using the same kernel version" in response to queries on
lvs-users :)

Graeme

