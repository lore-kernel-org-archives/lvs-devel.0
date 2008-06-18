From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 16:36:30 +0200
Message-ID: <f4845fc0806180736n17967573re22f0b8860c5580d@mail.gmail.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
	 <485819A8.1090004@trash.net>
	 <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
	 <4858CDDF.4050306@trash.net>
	 <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
	 <4859198A.9070503@trash.net>
	 <f4845fc0806180727m1baffef7s2530f921f954584f@mail.gmail.com>
	 <48591BFF.2060903@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213799792; bh=LJ7pPiOvfN3g/XRETTYPzp31sX8=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=QRRsWF8CfqC7VrFio2ImUC0Ux5iEcb84
	vS4rkE78msttGnx7IV7HbRLWA/wo9MK3o7P/OYHo+3KH+q32xI53xQ==
In-Reply-To: <48591BFF.2060903@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 18, 2008 at 4:30 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>
>> On Wed, Jun 18, 2008 at 4:19 PM, Patrick McHardy <kaber@trash.net> wrote:
>>>>
>>>> 2) for the service flags, only one bit is set from userspace
>>>> (persistent/nonpersistent service). So this might be not too bad to
>>>> have as a single Netlink flag attribute.
>>>
>>> And this bit can't be unset (or if it currently can't be,
>>> it also wouldn't make sense to be able to unset it)?
>>
>> It can get unset when editing a persistent service to be
>> non-persistent, so you would still have to include it in a change
>> request that doesn't want to unset it. Since it's only one flag
>> though, it didn't seem too bad to me.
>
> The problem is that its racy. You have to query the current
> state before deciding whether to send it or not. And another
> process might change it in between. An additional downside
> is the overhead for the query itself.

Right, forgot about this issue. Although ipvsadm does no getting and
setting based on the prior value (it only takes the value of the flag
from the command line), there might be other userspace tools who'd
want to use the interface differently.

>> An alternative (also, in case of more flags in the future) would be to
>> put flags into a nested attribute and if this is not supplied from
>> userspace during an edit operation, the flags will be left untouched.
>
> Then you can't unset them. I'd simply use the flags/mask
> scheme.

Ok!

Julius

-- 
Google Switzerland GmbH
