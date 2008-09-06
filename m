From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: Use pointer to address from sync message
Date: Sat, 6 Sep 2008 11:04:54 +0200
Message-ID: <f4845fc0809060204j37b1201eh82b1c8fa8c6a91c7@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <1220363755-9854-13-git-send-email-juliusv@google.com>
	 <alpine.LNX.2.00.0809051342360.18192@titan.stealer.net>
	 <f4845fc0809050528q253789fbi60ca6c229a08d8ab@mail.gmail.com>
	 <20080906042610.GC21521@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220691898; bh=8fOcbQW3yRezgkABgd5rfClWzmI=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=OyOP43JOrwUD73A9gkhKepRFgWqef19+
	Vqvwkd2ydI53GISgAl05V/9g9HVTEq7HArQEUBjQylQF1HlijTafZQ==
In-Reply-To: <20080906042610.GC21521@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Sven Wegener <sven.wegener@stealer.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Sat, Sep 6, 2008 at 6:26 AM, Simon Horman <horms@verge.net.au> wrote:
> Julius, can I take that as an Acked-by for the follwing changes?
>
> [PATCH] ipvs: Use pointer to address from sync message
> [PATCH] ipvs: Return negative error values from
> [PATCH] ipvs: Mark tcp/udp v4 and v6 debug functions static
> [PATCH] ipvs: Reject ipv6 link-local addresses for destinations

Yes, they all look good to me! Thanks, Sven.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
