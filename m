From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Fri, 22 Aug 2008 14:14:11 +0200
Message-ID: <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
	 <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
	 <20080821212948.GB4407@verge.net.au>
	 <20080821220444.GA2758@verge.net.au>
	 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
	 <1219399551.4246.10.camel@ernie.internal.graemef.net>
	 <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
	 <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219407254; bh=Qta/v6AlNlWOg/LjC8eytvkdR80=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Q4LmT+s2EXeTAHGL2Mg8mxDBfa66QiWR
	RdRy/nZCwtJsNNy98GZRypwVc2a2/VwlXEqZtm91q26W2SjZSgTi1g==
In-Reply-To: <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Sven Wegener <sven.wegener@stealer.net>
Cc: Graeme Fowler <graeme@graemef.net>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Fri, Aug 22, 2008 at 1:23 PM, Sven Wegener <sven.wegener@stealer.net> wrote:
>> He :) Imagine an old kernel on the backup receiving new messages and
>> not understanding them. How could we at least handle that situation
>> gracefully (without totally confusing the older kernel)? We'd need to
>> do it in a way that old features are still communicated in the same
>> way. E.g., v4-only connection syncs still use the same message format,
>> but once you use v6 entries, an unused flag or the 'reserved' field in
>> ip_vs_sync_conn is used. A v6 message would still confuse an older
>> kernel then, but a user would already notice that ipvsadm can't
>> configure the v6 services on the older kernel, so that's not too bad.
>
> If that's a problem, we can easily change the communication port and even
> completely redesign the protocol this way, without having old kernels
> getting confused about the data they get. We might lose the ability to
> sync between different versions, but in the end this is just the
> connection synchronziation and both systems should be running the same
> version. We could also keep the old communication port for some time, if
> that's really needed.

Yes, starting from scratch on another port sounds like a good idea.
Losing sync ability totally isn't as bad as confusing an older kernel
with new messages, so I hope it's not necessary to keep the old
baggage around?

Is there enough motivation for doing this though before having a
cleaned-up minimal v6 version without the sync daemon? This is where
I'm currently a bit stuck with... any help is appreciated :)

Julius

-- 
Google Switzerland GmbH
