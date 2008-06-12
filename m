From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Thu, 12 Jun 2008 17:34:04 +0200
Message-ID: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
References: <48501C81.6010800@trash.net> <48502826.9060502@trash.net>
	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>
	 <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com>
	 <485050FE.6030209@google.com> <20080612014548.GE22358@verge.net.au>
	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
	 <485126BD.7030109@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213284846; bh=4kRv0TS5ieWpO67P57OUChcJrDA=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=dSTWZ0pxrDOepmfrTi09ivgwRbcqWv6n
	pu/jtm/bS6Mvm7HSOtTispfnbwr3Hq3aZBdcaMGySvo9YznJDYr9ew==
In-Reply-To: <485126BD.7030109@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Jun 12, 2008 at 3:38 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>> I wonder if now would be a good time to bite the bullet and design
>>> a new interface that is extendable.
>>
>> If we really have to break it once for IPv6 anyways, it seems like a
>> good opportunity. Depends on how invasive the changes would need to
>> be, of course...
>
> You don't need to break the old interface, just add an additional
> one.

Ok, then we will just keep the old one in parallel for some time.

>> You probably already have some ideas on what a better interface would
>> look like? Especially, how to design it for future backwards
>> compatibility? And would it still use sockopts or rather one of the
>> other communication mechanisms?
>
> I'd suggest genetlink or nfnetlink.

Ah, that's what I thought... Are there any simple kernel examples with
userspace counterparts to look at? I know iproute2 uses netlink, but
it seems like a rather complicated example.

Genetlink seems especially nice, although I couldn't find a general
explanation of it other than in git history.

Julius

-- 
Google Switzerland GmbH
