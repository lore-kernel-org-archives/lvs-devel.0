From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 16:17:41 +0200
Message-ID: <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <485043E6.5030105@candelatech.com> <485050FE.6030209@google.com>
	 <20080612014548.GE22358@verge.net.au>
	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213366663; bh=YX2ImlL7CjkZDHYMlAVDr7BvUmQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=m9MexiUagRrOtkrHauKXF3F+8ZqHOhry
	ocmpfzMnsPjrzp+Zqf09tYC9+ocBkHwMaQjygMC19yefhdqwN439Dg==
In-Reply-To: <20080613062621.GA10474@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Fri, Jun 13, 2008 at 8:26 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Jun 12, 2008 at 09:33:27PM +0200, Julius Volz wrote:
>> Ok, my first impression is that genetlink is aimed at being simple to
>> use (and has a nice howto).
>>
>> So we'll work on a genetlink interface and some of the other v6 patch
>> issues and then post again in a while. Thanks for the feedback!
>>
>> Horms: ping if you're interested or have some good ideas for this.
>
> Julius: pong
>
> The main two problems that I see in the existing interface are
> a) lack of extendibility (which is why we are here) and;
> b) non-idempotent actions, especially adding and deleting
>   real servers, which mean that user-space programs that
>   manipulate ipvsadm have have extra (racy) logic.
>   (ok, perhaps that is more a pet peeve than a problem).

Ok, so we probably won't focus on b) as a priority right now, unless
it happens as a side-effect.

> I don't really have any concrete ideas about what a better
> interface would look like. But I am more than happy to hash our ideas.

Good! At the moment I'm looking at various netlink docs and figuring
out how things generally work. I think netlink probably adds a lot of
complexity over the previous sockopt interface, but I hope it's worth
it.

As for compatibility and extensibility, how is that best achieved with
netlink? I've seen some examples copy whole C structs into netlink
datagrams, but that is obviously what we don't want anymore. So the
way to go seems to be to transfer each struct field as a separate
netlink attribute, right?

Julius

-- 
Google Switzerland GmbH
