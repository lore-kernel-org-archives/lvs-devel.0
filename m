From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Mon, 16 Jun 2008 02:14:00 +0200
Message-ID: <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <20080612014548.GE22358@verge.net.au>
	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <48528EED.7090307@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213575242; bh=3jfvxDQTPtSXGAXDe162Aqs+Md4=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=M2PpYR8gBmwJ2JsVTmNFGdut7maV5oOP
	+jHU3w56D/LA0oU9EQBopM63izUJ4qOlLND+uSp8JZFy92ElwbRkMA==
In-Reply-To: <48528EED.7090307@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Fri, Jun 13, 2008 at 5:14 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>> As for compatibility and extensibility, how is that best achieved with
>> netlink? I've seen some examples copy whole C structs into netlink
>> datagrams, but that is obviously what we don't want anymore. So the
>> way to go seems to be to transfer each struct field as a separate
>> netlink attribute, right?
>
> Yes. You can also group those which belong together logically
> in nested attributes.

Thanks. I've now looked closer at Netlink and read the Genetlink implementation.

For the new IPVS interface, is there a preference for the granularity
of the top-level Genetlink operations?

I see three naive possibilities (one Genetlink op per line), if we
start out with a straight mapping from the old API to the new one:

a)
SET - covers all of previous IP_VS_SO_SET_*
GET - covers all of previous IP_VS_SO_GET_*

b) more split up
ADD - services and destinations
EDIT - services and destinations
DEL - services and destinations
SETTIMEOUT
STARTDAEMON
STOPDAEMON
ZERO
(+ granular GET commands...)

c) totally split up
ADD_SVC
ADD_DEST
EDIT_SVC
EDIT_DEST
DEL_SVC
DEL_DEST
SETTIMEOUT
STARTDAEMON
STOPDAEMON
ZERO
(+ granular GET commands...)

I find http://www.linuxfoundation.org/en/Net:Generic_Netlink_HOWTO saying:
===========================
Operation Granularity

While it may be tempting to register a single operation for a Generic
Netlink family and multiplex multiple sub-commands on the single
operation, this is strongly discouraged for security reasons.
Combining multiple behaviors into one operation makes it difficult to
restrict the operations using the existing Linux kernel security
mechanisms.
===========================

Option c) looks reasonable to me and also seems easy to handle in
general. Is this the way to go? Or do we want the interface to look
completely different this time?

Julius

-- 
Google Switzerland GmbH
