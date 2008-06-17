From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 00:47:32 +0200
Message-ID: <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <48528EED.7090307@trash.net>
	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
	 <485652EA.2020004@trash.net>
	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
	 <485819A8.1090004@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213742854; bh=GFMa7pN1/jg7YOlpD5GogPmnBvw=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=dMI7cUJIaSjmXJrSUbPVpHqboVg9JhFZ
	Tf2EEAOXNnCsMi2pXMrtMpWQhdu1yf/BMnNhlqRloTQRhLmR4LOtNg==
In-Reply-To: <485819A8.1090004@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Tue, Jun 17, 2008 at 10:08 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>
>> Ok, so this is my draft version of the IPVS Generic Netlink interface
>> definition. I'm posting this to see if anyone notices general problems
>> with it right away.
>
> I'm not familiar with the ipvs interface itself, so I'll
> stick to netlink related comments.

Thanks, I very much appreciate the great feedback!

> I personally don't find NLA_FLAG very useful since for
> flags use usually want the flag and a mask, otherwise
> you can't unset it without the convention that userspace
> always includes it, even for change requests when it
> doesn't want to change it. And that is unusual for netlink
> and also needlessly complicated and racy in userspace since
> you'd have to query the current value before sending a change
> request.

Makes sense, yes!

> So these are lists I assume. I don't think we have any examples
> of lists of nested attributes in the mainline kernel, but in
> some similar (unsubmitted) code of mine I used (names adjusted):
>
> IPVS_SERVICE_LIST               - NLA_NESTED
> IPCS_DEST_LIST                  - NLA_NESTED
> IPVS_DAEMON_LIST                - NLA_NESTED

Nicer naming! I will adopt that.

> and
>
> IPVS_LIST_ELEM                  - NLA_NESTED
>
> for list elements of every kind. Since you can only put one
> kind of element in the lists anyway (I think), different
> types don't allow any increased flexibility and the LIST
> naming is more clear in my opinion.

However, since these container attributes (for daemons, services and
dests) also appear as single elements outside of lists, it might be
better to reuse the same names inside the list?

>> IPVS_SVC_ATTR_AF                - NLA_U32
>> IPVS_SVC_ATTR_PROTOCOL          - NLA_U32
>> IPVS_SVC_ATTR_ADDR              - union nf_inet_addr
>
> This should probably use NLA_BINARY, which allows addresses
> of any kind.

Yes, the Netlink attribute type should really be NLA_BINARY. I just
used the union as an informal way of saying what I really intended to
store in there, though if some third address family came along, it
could be something completely different.

>> IPVS_SVC_ATTR_PORT              - NLA_U16
>> IPVS_SVC_ATTR_FWMARK            - NLA_U32
>> IPVS_SVC_ATTR_SCHED_NAME        - NLA_STRING
>
> NLA_NUL_STRING (at least for validation purposes)?

Ah, looking closer at the validation code, that makes sense.

>> IPVS_SVC_ATTR_FLAGS             - NLA_U32
>
> As I mentioned above, you usually want a MASK in combination
> with flags to allow to unset them. This is best done using
> a structure.

Hm, I'm not sure if I understand exactly what this struct is supposed
to look like. Could you give an example?

>> IPVS_SVC_ATTR_TIMEOUT           - NLA_U32
>> IPVS_SVC_ATTR_NETMASK           - NLA_U32
>
> Shouldn't this also be able to carry IPv6 masks?

We only need the prefix length for IPv6, for which we reused the
netmask field. This (only slightly) changes the semantics of the field
between address families. Acceptable or better have a separate field
for the prefix length?

>> IPVS_SVC_ATTR_NUM_DESTS         - NLA_U32
>
> Is this number related to the IPVS_ENTRY_ATTR_DESTS list?
> If so, it shouldn't be contained as seperate attribute,
> that just allows for potential inconsistency.

Yes, but this count is only returned from commands that do not at the
same time return the list of destinations, so there is no
inconsistency within a message. However, I'm pretty sure the count was
only used in the old interface to allocate enough memory for the
destination list, so it can probably be deleted anyways.

>> IPVS_SVC_ATTR_STATS             - NLA_NESTED
>>
>> IPVS_DEST_ATTR_AF               - NLA_U32
>
> Doesn't the family have to be equal for service and dest?
> If so, having it specified only once avoids potential
> inconsistencies.

Yes, this field can likely go away too. I was thinking about the fact
that the family of the non-VIP interface of the destination could
theoretically differ, but no support for that is currently planned.

>> ========================== include/net/ip_vs.h ==========================
>
> Please put this under include/linux, this doesn't belong
> here as its a public header.
>

He, that's the thing about IPVS. The current ipvsadm already directly
includes this header from /usr/src/linux/include/net/ip_vs.h to
compile.

So we will have to keep the old header in the wrong location for old
ipvsadm sources and create a new one only for the genetlink interface
under include/linux.

Thank you for spotting all this!

Julius

-- 
Google Switzerland GmbH
