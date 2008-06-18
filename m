From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 16:17:36 +0200
Message-ID: <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <48528EED.7090307@trash.net>
	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
	 <485652EA.2020004@trash.net>
	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
	 <485819A8.1090004@trash.net>
	 <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
	 <4858CDDF.4050306@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213798659; bh=5IyArF7PAy5447D5jiy2bRfnbrk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=BtEO8cWX43Z/e9lRFgFfgEKxxyRVUnBu
	yLRGcgO3Tlm/qomXuHHnzAnk513NyLmzJBN+aHfrGMcTWAbHjlZ1+g==
In-Reply-To: <4858CDDF.4050306@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 18, 2008 at 10:57 AM, Patrick McHardy <kaber@trash.net> wrote:
>>> As I mentioned above, you usually want a MASK in combination
>>> with flags to allow to unset them. This is best done using
>>> a structure.
>>>
>>
>> Hm, I'm not sure if I understand exactly what this struct is supposed
>> to look like. Could you give an example?
>>
>
> struct {
>   u32 flags;
>   u32 mask;
> } flags;
>
> and then:
>
> obj->flags = (obj->flags & ~flags->mask) |
>                   (flags->flags | flags->mask);

Ah, I see. The second line should read "(flags->flags & flags->mask)", right?

Looking at how these "flags" are actually used in ipvsadm, I'm not
sure this would be needed here:

1) destination conn_flags are only set to successive integer values 0,
1, 2... (depending on the forwarding method), which are mutually
exclusive. Only internally in the kernel are other bits of this field
used in a flag-like fashion. So this Netlink attribute could be
renamed to something like *_FWD_METHOD and be a normal value field.

2) for the service flags, only one bit is set from userspace
(persistent/nonpersistent service). So this might be not too bad to
have as a single Netlink flag attribute.

Otherwise, I changed the interface according to your feedback and
we'll work on the implementation for a while now!

Thanks,
Julius

-- 
Google Switzerland GmbH
