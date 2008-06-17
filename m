From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Tue, 17 Jun 2008 22:08:08 +0200
Message-ID: <485819A8.1090004@trash.net>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com> <485144DF.3030102@trash.net> <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com> <20080613062621.GA10474@verge.net.au> <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com> <48528EED.7090307@trash.net> <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com> <485652EA.2020004@trash.net> <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com> <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080617171840.GB4064@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> Ok, so this is my draft version of the IPVS Generic Netlink interface
> definition. I'm posting this to see if anyone notices general problems
> with it right away.

I'm not familiar with the ipvs interface itself, so I'll
stick to netlink related comments.

> Arrays of the same attribute type are always put into a nested container
> so that it is easy to add new attributes which are parallel to the array
> later on.

That makes sense.

> Perhaps integer flag fields should also be split up into
> NLA_FLAG attributes, haven't done that yet.

I personally don't find NLA_FLAG very useful since for
flags use usually want the flag and a mask, otherwise
you can't unset it without the convention that userspace
always includes it, even for change requests when it
doesn't want to change it. And that is unusual for netlink
and also needlessly complicated and racy in userspace since
you'd have to query the current value before sending a change
request.

> First is a text listing attribute types and how they occur and nest in
> all of the commands and their replies. After that are the corresponding
> source excerpts (no patch material yet).
> 
> Julius
> 
> 
> ======================================
> |    IPVS NETLINK ATTRIBUTE TYPES    |
> |          (grouped as enums)        |
> ======================================
> 
> IPVS_ENTRY_ATTR_SERVICE		- NLA_NESTED
> IPVS_ENTRY_ATTR_SERVICES	- NLA_NESTED
> IPVS_ENTRY_ATTR_DEST		- NLA_NESTED
> IPVS_ENTRY_ATTR_DESTS		- NLA_NESTED
> IPVS_ENTRY_ATTR_DAEMON		- NLA_NESTED
> IPVS_ENTRY_ATTR_DAEMONS		- NLA_NESTED

So these are lists I assume. I don't think we have any examples
of lists of nested attributes in the mainline kernel, but in
some similar (unsubmitted) code of mine I used (names adjusted):

IPVS_SERVICE_LIST		- NLA_NESTED
IPCS_DEST_LIST			- NLA_NESTED
IPVS_DAEMON_LIST		- NLA_NESTED

and

IPVS_LIST_ELEM			- NLA_NESTED

for list elements of every kind. Since you can only put one
kind of element in the lists anyway (I think), different
types don't allow any increased flexibility and the LIST
naming is more clear in my opinion.

> IPVS_SVC_ATTR_AF		- NLA_U32
> IPVS_SVC_ATTR_PROTOCOL		- NLA_U32
> IPVS_SVC_ATTR_ADDR		- union nf_inet_addr

This should probably use NLA_BINARY, which allows addresses
of any kind.

> IPVS_SVC_ATTR_PORT		- NLA_U16
> IPVS_SVC_ATTR_FWMARK		- NLA_U32
> IPVS_SVC_ATTR_SCHED_NAME	- NLA_STRING

NLA_NUL_STRING (at least for validation purposes)?

> IPVS_SVC_ATTR_FLAGS		- NLA_U32

As I mentioned above, you usually want a MASK in combination
with flags to allow to unset them. This is best done using
a structure.

> IPVS_SVC_ATTR_TIMEOUT		- NLA_U32
> IPVS_SVC_ATTR_NETMASK		- NLA_U32

Shouldn't this also be able to carry IPv6 masks?

> IPVS_SVC_ATTR_NUM_DESTS		- NLA_U32

Is this number related to the IPVS_ENTRY_ATTR_DESTS list?
If so, it shouldn't be contained as seperate attribute,
that just allows for potential inconsistency.

> IPVS_SVC_ATTR_STATS		- NLA_NESTED
> 
> IPVS_DEST_ATTR_AF		- NLA_U32

Doesn't the family have to be equal for service and dest?
If so, having it specified only once avoids potential
inconsistencies.

> ========================== include/net/ip_vs.h ==========================

Please put this under include/linux, this doesn't belong
here as its a public header.
