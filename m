From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Mon, 30 Jun 2008 14:01:02 +0200
Message-ID: <f4845fc0806300501x70aec2a4sb3bdc9a9bd911d0e@mail.gmail.com>
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
	t=1214827265; bh=eT4w3uzFezotTb1HFnkWvb8RLh8=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=vfzweRPlUM+cXeoHYV2zfq+EDRxLySFf
	59isyOQSs3UwRAE3tZaOmsvSB57kVQmc9yh2EBP3YtUk0M60JotKNA==
In-Reply-To: <485652EA.2020004@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Jun 16, 2008, Patrick McHardy wrote:
> b) or c) both look fine. You could save a few operations (ADD/EDIT
> can be combined) by making use of nlmsg_flags though:
>
> The semantics of the flags is:
>
> - NLM_F_CREATE|NLM_F_EXCL: create if non-existant
> - NLM_F_REPLACE: change existing
> - NLM_F_CREATE|NLM_F_REPLACE: create if non-existing, replace otherwise
> - NLM_F_EXCL: test existance

I just noticed that this doesn't work with genetlink. genl_rcv_msg()
treats all commands as GET requests instead of NEW requests, in which
the same flag bits mean different things (NLM_F_ROOT, NLM_F_MATCH and
so on). Specifically, it checks for NLM_F_DUMP, which overlaps with
the other interpretations of the bits.

So I think I'll just have separate commands for ADD and EDIT, similar
to what net/wireless/nl80211.c has.

Julius

-- 
Google Switzerland GmbH
