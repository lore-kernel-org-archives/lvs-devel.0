From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Thu, 12 Jun 2008 17:46:39 +0200
Message-ID: <485144DF.3030102@trash.net>
References: <48501C81.6010800@trash.net> <48502826.9060502@trash.net>	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>	 <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>	 <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com>	 <485050FE.6030209@google.com> <20080612014548.GE22358@verge.net.au>	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>	 <485126BD.7030109@trash.net> <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Thu, Jun 12, 2008 at 3:38 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Julius Volz wrote:
>>>> I wonder if now would be a good time to bite the bullet and design
>>>> a new interface that is extendable.
>>> If we really have to break it once for IPv6 anyways, it seems like a
>>> good opportunity. Depends on how invasive the changes would need to
>>> be, of course...
>> You don't need to break the old interface, just add an additional
>> one.
> 
> Ok, then we will just keep the old one in parallel for some time.
> 
>>> You probably already have some ideas on what a better interface would
>>> look like? Especially, how to design it for future backwards
>>> compatibility? And would it still use sockopts or rather one of the
>>> other communication mechanisms?
>> I'd suggest genetlink or nfnetlink.
> 
> Ah, that's what I thought... Are there any simple kernel examples with
> userspace counterparts to look at? I know iproute2 uses netlink, but
> it seems like a rather complicated example.

For nfnetlink: net/netfilter/nf_conntrack_netlink.c and
libnfnetlink_conntrack from git.netfilter.org.

> Genetlink seems especially nice, although I couldn't find a general
> explanation of it other than in git history.

I don't have an example for genetlink, but I guess you should
find some in libnl. In this case I guess both would be fine
since ipvs is only loosely tied to the rest of netfilter.
