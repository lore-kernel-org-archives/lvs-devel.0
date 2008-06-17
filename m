From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Tue, 17 Jun 2008 13:52:46 +0200
Message-ID: <4857A58E.6080304@trash.net>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>	 <485126BD.7030109@trash.net>	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>	 <485144DF.3030102@trash.net>	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>	 <20080613062621.GA10474@verge.net.au>	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>	 <48528EED.7090307@trash.net>	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>	 <485652EA.2020004@trash.net> <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Mon, Jun 16, 2008 at 1:47 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> Option c) looks reasonable to me and also seems easy to handle in
>>> general. Is this the way to go? Or do we want the interface to look
>>> completely different this time?
>> b) or c) both look fine.
> 
> A couple of other Netlink questions came up while reading some code:
> 
> 1) There are many examples of the following two cases in the kernel:
> 
> nla_nest_start(skb, SOME_ATTR_TYPE | NLA_F_NESTED);
> nla_nest_start(skb, SOME_ATTR_TYPE);
> 
> Why don't all cases have NLA_F_NESTED? Then again, this bit is never
> ever read out again (at least not in the kernel), so I guess people
> are just using their implicit knowledge that a specific attribute type
> is always nested and never check the bit?
>
> Btw., couldn't we change nla_nest_start() to always add NLA_F_NESTED
> to the type?

The NLA_F_NESTED bit originated in nfnetlink, but was moved
to netlink so the new netlink parsing helpers could also be
used for nfnetlink. It can't be added to existing attributes
since userspace needs to mask it out again to get the real
attribute value and the non-nfnetlink userspace code doesn't
expect it.

> 2) To send an array of attributes of the same type, you just add them
> serially? I was just confused at first that nla_parse() will save only
> one attribute of each type (the last one) in the destination array, so
> when dealing with arrays, it doesn't help. So I just iterate over the
> array with nla_for_each_attr() and parse each element manually, right?

Exactly, net/8021q/vlan_netlink.c has two examples of this (the
QoS mapping attributes).
