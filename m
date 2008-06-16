From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Mon, 16 Jun 2008 13:47:54 +0200
Message-ID: <485652EA.2020004@trash.net>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>	 <20080612014548.GE22358@verge.net.au>	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>	 <485126BD.7030109@trash.net>	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>	 <485144DF.3030102@trash.net>	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>	 <20080613062621.GA10474@verge.net.au>	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>	 <48528EED.7090307@trash.net> <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> Thanks. I've now looked closer at Netlink and read the Genetlink implementation.
> 
> For the new IPVS interface, is there a preference for the granularity
> of the top-level Genetlink operations?
> 
> I see three naive possibilities (one Genetlink op per line), if we
> start out with a straight mapping from the old API to the new one:
> 
> a)
> SET - covers all of previous IP_VS_SO_SET_*
> GET - covers all of previous IP_VS_SO_GET_*
> 
> b) more split up
> ADD - services and destinations
> EDIT - services and destinations
> DEL - services and destinations
> SETTIMEOUT
> STARTDAEMON
> STOPDAEMON
> ZERO
> (+ granular GET commands...)
> 
> c) totally split up
> ADD_SVC
> ADD_DEST
> EDIT_SVC
> EDIT_DEST
> DEL_SVC
> DEL_DEST
> SETTIMEOUT
> STARTDAEMON
> STOPDAEMON
> ZERO
> (+ granular GET commands...)
> 
> I find http://www.linuxfoundation.org/en/Net:Generic_Netlink_HOWTO saying:
> ===========================
> Operation Granularity
> 
> While it may be tempting to register a single operation for a Generic
> Netlink family and multiplex multiple sub-commands on the single
> operation, this is strongly discouraged for security reasons.
> Combining multiple behaviors into one operation makes it difficult to
> restrict the operations using the existing Linux kernel security
> mechanisms.
> ===========================
> 
> Option c) looks reasonable to me and also seems easy to handle in
> general. Is this the way to go? Or do we want the interface to look
> completely different this time?

b) or c) both look fine. You could save a few operations (ADD/EDIT
can be combined) by making use of nlmsg_flags though:

The semantics of the flags is:

- NLM_F_CREATE|NLM_F_EXCL: create if non-existant
- NLM_F_REPLACE: change existing
- NLM_F_CREATE|NLM_F_REPLACE: create if non-existing, replace otherwise
- NLM_F_EXCL: test existance

NLM_F_APPEND can be used as modifier for NLM_F_CREATE to
specify that the new entry should be added to the end instead
of the beginning.
