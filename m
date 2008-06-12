From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Thu, 12 Jun 2008 15:38:05 +0200
Message-ID: <485126BD.7030109@trash.net>
References: <48501C81.6010800@trash.net> <4850233E.7090501@trash.net>	 <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>	 <48502826.9060502@trash.net>	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>	 <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>	 <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com>	 <485050FE.6030209@google.com> <20080612014548.GE22358@verge.net.au> <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> On Thu, Jun 12, 2008, Simon Horman <horms@verge.net.au> wrote:
>> Eventially the changes settled down, and for the past few years they
>> have been very infrequent.  But the problem that the interface isn't
>> really extendable and that when changes are made kernel and ipvsadm
>> versions need to be incremented together remains. For instance, the
>> Debian package of ipvsadm actually shipps three different ipvsadm
>> binaries, and a wrapper works out which one to use based on the kernel
>> version.
> 
> Ugh.
> 
>> I wonder if now would be a good time to bite the bullet and design
>> a new interface that is extendable.
> 
> If we really have to break it once for IPv6 anyways, it seems like a
> good opportunity. Depends on how invasive the changes would need to
> be, of course...

You don't need to break the old interface, just add an additional
one.

> You probably already have some ideas on what a better interface would
> look like? Especially, how to design it for future backwards
> compatibility? And would it still use sockopts or rather one of the
> other communication mechanisms?

I'd suggest genetlink or nfnetlink.

