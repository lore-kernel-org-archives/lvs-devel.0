From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Tue, 17 Jun 2008 01:19:14 +0200
Message-ID: <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <48528EED.7090307@trash.net>
	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
	 <485652EA.2020004@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213658356; bh=UEUUYr0lTdHG5N6/d3IaEHIccaE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=ZaUK153hRk5P7gEKMaSfMDAiD/3AEFef
	lwdBN0hAWRjwSzNCxo5eSBHsoZ++pyk7cIKroqC6q/WAnl3UU52CeQ==
In-Reply-To: <485652EA.2020004@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Jun 16, 2008 at 1:47 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Option c) looks reasonable to me and also seems easy to handle in
>> general. Is this the way to go? Or do we want the interface to look
>> completely different this time?
>
> b) or c) both look fine.

A couple of other Netlink questions came up while reading some code:

1) There are many examples of the following two cases in the kernel:

nla_nest_start(skb, SOME_ATTR_TYPE | NLA_F_NESTED);
nla_nest_start(skb, SOME_ATTR_TYPE);

Why don't all cases have NLA_F_NESTED? Then again, this bit is never
ever read out again (at least not in the kernel), so I guess people
are just using their implicit knowledge that a specific attribute type
is always nested and never check the bit?

Btw., couldn't we change nla_nest_start() to always add NLA_F_NESTED
to the type?

2) To send an array of attributes of the same type, you just add them
serially? I was just confused at first that nla_parse() will save only
one attribute of each type (the last one) in the destination array, so
when dealing with arrays, it doesn't help. So I just iterate over the
array with nla_for_each_attr() and parse each element manually, right?

Thanks for your time!

Julius

-- 
Google Switzerland GmbH
