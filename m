From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 17:14:53 +0200
Message-ID: <48528EED.7090307@trash.net>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>	 <485043E6.5030105@candelatech.com> <485050FE.6030209@google.com>	 <20080612014548.GE22358@verge.net.au>	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>	 <485126BD.7030109@trash.net>	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>	 <485144DF.3030102@trash.net>	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>	 <20080613062621.GA10474@verge.net.au> <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Fri, Jun 13, 2008 at 8:26 AM, Simon Horman <horms@verge.net.au> wrote:
>> I don't really have any concrete ideas about what a better
>> interface would look like. But I am more than happy to hash our ideas.
> 
> Good! At the moment I'm looking at various netlink docs and figuring
> out how things generally work. I think netlink probably adds a lot of
> complexity over the previous sockopt interface, but I hope it's worth
> it.
> 
> As for compatibility and extensibility, how is that best achieved with
> netlink? I've seen some examples copy whole C structs into netlink
> datagrams, but that is obviously what we don't want anymore. So the
> way to go seems to be to transfer each struct field as a separate
> netlink attribute, right?

Yes. You can also group those which belong together logically
in nested attributes.
