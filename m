From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Thu, 12 Jun 2008 17:41:51 +0200
Message-ID: <f4845fc0806120841i14d0e10ap364a24841091e4f8@mail.gmail.com>
References: <48501C81.6010800@trash.net>
	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>
	 <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com>
	 <485050FE.6030209@google.com> <20080612014548.GE22358@verge.net.au>
	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213285314; bh=SuO1/m3itjh9/7MeaGqAkgbJCQA=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=on9xSt7WNxDYMUvwKfoEb/Y5PPHhN/5M
	NugcYBAqQK7ys6c3x/pU3Hya1WXUgbBxiDQuHjdvi2ufYE2gLRhzdQ==
In-Reply-To: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Thu, Jun 12, 2008 at 5:34 PM, Julius Volz <juliusv@google.com> wrote:
> Genetlink seems especially nice, although I couldn't find a general
> explanation of it other than in git history.

Ah, searching for "genetlink" didn't work, but "Generic Netlink" finds
the HOWTO.

Julius

-- 
Google Switzerland GmbH
