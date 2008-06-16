From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Mon, 16 Jun 2008 14:13:05 +0200
Message-ID: <f4845fc0806160513q4196eac3q78dd044082bea138@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <48528EED.7090307@trash.net>
	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
	 <485652EA.2020004@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213618387; bh=sIVhSaVz+WQWGob1UiB2d73Wx8A=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=b8aC8zQI4eYpJSTV39WdcGHK4SWOL0Q/
	ExWkGwXjBkFVMdUt0mWAGB4sYeUkXjqU1zMrYBqGQEuif77dWexyoQ==
In-Reply-To: <485652EA.2020004@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Jun 16, 2008 at 1:47 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Option c) looks reasonable to me and also seems easy to handle in
>> general. Is this the way to go? Or do we want the interface to look
>> completely different this time?
>
> b) or c) both look fine.

Good, thanks.

> You could save a few operations (ADD/EDIT
> can be combined) by making use of nlmsg_flags though:
>
> The semantics of the flags is:
>
> - NLM_F_CREATE|NLM_F_EXCL: create if non-existant
> - NLM_F_REPLACE: change existing
> - NLM_F_CREATE|NLM_F_REPLACE: create if non-existing, replace otherwise
> - NLM_F_EXCL: test existance

Thanks for explaining this! Sounds good!

> NLM_F_APPEND can be used as modifier for NLM_F_CREATE to
> specify that the new entry should be added to the end instead
> of the beginning.

Interesting. This should not be needed in IPVS though, as entry order
doesn't matter much there.

Julius

-- 
Google Switzerland GmbH
