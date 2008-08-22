From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 12:49:34 +0200
Message-ID: <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
	 <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
	 <20080821212948.GB4407@verge.net.au>
	 <20080821220444.GA2758@verge.net.au>
	 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
	 <1219399551.4246.10.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219402175; bh=o8sGjrDJsuEBasBY2dXuxHj1Fg4=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Eat8bh0LADh52ScSxykbFDj1yL+MJMpH
	fkH7q7kLKt+i4fSPu8OLhmb8guvFILKnVIY74IMY228/UXYHCdlWCw==
In-Reply-To: <1219399551.4246.10.camel@ernie.internal.graemef.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Graeme Fowler <graeme@graemef.net>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On Fri, Aug 22, 2008 at 12:05 PM, Graeme Fowler <graeme@graemef.net> wrote:
> On Fri, 2008-08-22 at 11:56 +0200, Julius Volz wrote:
>> There's also a '__u8 reserved' field at the beginning of that struct
>> which could be used. But in general, is it reasonable to expect both
>> nodes to use the same kernel version, which gets rid of the
>> extensibility problems? It's not really an ABI that can't be broken,
>> right?
>
> I think from an operational (ie. end user) perspective, ABI breakage is
> something to try to avoid but _not_ at all costs.
>
> If it's possible to extend the sync daemon protocol by reusing the
> existing code and ABI, all well and good; however if a fundamental
> change is made which breaks the old sync daemon ABI then as long as it's
> documented and we make sure that users know to have the same (or higher)
> kernel versions on their directors then everyone wins.

Yeah, and it's not an ABI, it's a very specialized protocol between
two kernels, so the rules are less clear. However, I totally agree
with you that it's not convenient from the users' point of view.

>> Yes, without jumping through hoops, we have to probably break the
>> current protocol anyways for new features? Even if we designated
>> unused fields for new information, an old kernel will not look at them
>> / fill them out, which limits the possibilities...
>
> I guess that as and when this change is made and gets into mainline
> releases, Joe and I will have to have a mantra of "ensure your directors
> are using the same kernel version" in response to queries on
> lvs-users :)

He :) Imagine an old kernel on the backup receiving new messages and
not understanding them. How could we at least handle that situation
gracefully (without totally confusing the older kernel)? We'd need to
do it in a way that old features are still communicated in the same
way. E.g., v4-only connection syncs still use the same message format,
but once you use v6 entries, an unused flag or the 'reserved' field in
ip_vs_sync_conn is used. A v6 message would still confuse an older
kernel then, but a user would already notice that ipvsadm can't
configure the v6 services on the older kernel, so that's not too bad.

Anyways, these are just some thoughts. I'm unsure if we really need to
worry about this extension right now or if we could postpone it? At
least for me, it makes more sense to clean up the minimal set of IPv6
features first and then think about the more advanced/optional ones,
like the sync daemon.

Julius

-- 
Google Switzerland GmbH
