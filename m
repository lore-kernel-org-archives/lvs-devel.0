From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 11 Apr 2008 11:54:44 +0200
Message-ID: <f4845fc0804110254s79eb6889sa654fc5d019db030@mail.gmail.com>
References: <f4845fc0804040340x5e93754crcd680d26fd8982f7@mail.gmail.com>
	 <20080405010707.GB27827@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1207907686; bh=kNwLs2L7r6PnuoFeSppdSpvzTzc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Mpy2Ct5A3/B9NT6Pa+aburhL6MGmf/qG
	w+lALcvK9Z2IJev8J7muDxlhz8Jyj1nMCJXjFNmQknlMDgHrsWgG2g==
In-Reply-To: <20080405010707.GB27827@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>

Hi Horms,

On Sat, Apr 5, 2008, Simon Horman wrote:
> On Fri, Apr 04, 2008 at 12:40:36PM +0200, Julius Volz wrote:
>  > Hi,
>  >
>  > This patch moves IPVS from net/ipv4/ipvs to net/netfilter/ipvs, as
>  > discussed earlier with Horms and Patrick McHardy. This is done as a
>  > preparation for later adding IPv6 functionality to IPVS. The patch is
>  > 600kb, so I uploaded it here:
>  >
>  > http://www-user.tu-chemnitz.de/~volz/move_ipvs_to_netfilter.patch
>  >
>  > [...]
>
>  Thanks, I've grabbed the patch and will review it ASAP.
>  I am going to be mostly offline for about 5 days as I am moving.
>  So I apologise in advance for being a bit undresponsive during that time.

Hope your move went ok!

Any news on this? Should I redo the patch on top of Jason's
POST/PREROUTING patch or should that go in later? Would be cool to get
this directory move out of the way...

Julius

-- 
Google Switzerland GmbH
