From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 16:27:28 +0200
Message-ID: <f4845fc0806180727m1baffef7s2530f921f954584f@mail.gmail.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485652EA.2020004@trash.net>
	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
	 <485819A8.1090004@trash.net>
	 <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
	 <4858CDDF.4050306@trash.net>
	 <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
	 <4859198A.9070503@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213799250; bh=uz6VbSL/HRIhGaATqRtUiG67EfM=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=MBvynsKFxjUuJV4d3SxTGGP7xgzZ2kzm
	IipHBo7sFX1vMhV0aVcrvJMQBA9/LJApHKojB58Z+5HqykIh3fi6qQ==
In-Reply-To: <4859198A.9070503@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 18, 2008 at 4:19 PM, Patrick McHardy <kaber@trash.net> wrote:
>> 2) for the service flags, only one bit is set from userspace
>> (persistent/nonpersistent service). So this might be not too bad to
>> have as a single Netlink flag attribute.
>
> And this bit can't be unset (or if it currently can't be,
> it also wouldn't make sense to be able to unset it)?

It can get unset when editing a persistent service to be
non-persistent, so you would still have to include it in a change
request that doesn't want to unset it. Since it's only one flag
though, it didn't seem too bad to me.

An alternative (also, in case of more flags in the future) would be to
put flags into a nested attribute and if this is not supplied from
userspace during an edit operation, the flags will be left untouched.

Julius

-- 
Google Switzerland GmbH
