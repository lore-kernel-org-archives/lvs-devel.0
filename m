From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 19:33:17 +0200
Message-ID: <f4845fc0806131033o74f0afd0kaace53a88643788@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <Pine.LNX.4.64.0806130719590.17809@wm7d.net>
	 <f4845fc0806130801m4cfc9a90ifc7ab11abb6b509a@mail.gmail.com>
	 <Pine.LNX.4.64.0806130855380.24266@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213378399; bh=y/kQcgmBeMXC2X9ayLr7gmi/SYc=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=mhyJb7/U5SfeGZYMxMRFi9kznUqiBVwV
	ExlSo39/L6RaiAM6bIbgnvcOUpFd36Dx0T3smDuVpPkRgdrvOlg7+w==
In-Reply-To: <Pine.LNX.4.64.0806130855380.24266@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Simon Horman <horms@verge.net.au>, Graeme Fowler <graeme@graemef.net>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Vince Busam <vbusam@google.com>

On Fri, Jun 13, 2008 at 6:00 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> at some point (eg now) decide that from here on, only one ipvsadm source
> file will exist (rather than one for each kernel). As new kernels come
> along, ipvsadm will detect the kernel on compile and produce the correct
> binary. The ipvsadm will accumulate code for different kernel versions

Yes, the main goal is to have old ipvsadm binaries (starting from the
first netlink version) also work with newer kernels. So you wouldn't
even need to recompile for this case.

We'll have to see if we can make it work the other way around, too
(older kernel, newer ipvsadm), although that isn't as important as
keeping old kernel interfaces.

Julius

-- 
Google Switzerland GmbH
