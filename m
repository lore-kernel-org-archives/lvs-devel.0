From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Fri, 13 Jun 2008 17:01:29 +0200
Message-ID: <f4845fc0806130801m4cfc9a90ifc7ab11abb6b509a@mail.gmail.com>
References: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
	 <20080612014548.GE22358@verge.net.au>
	 <f4845fc0806120631g511c7dbag365a8483134943fd@mail.gmail.com>
	 <485126BD.7030109@trash.net>
	 <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <485144DF.3030102@trash.net>
	 <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com>
	 <20080613062621.GA10474@verge.net.au>
	 <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com>
	 <Pine.LNX.4.64.0806130719590.17809@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213369292; bh=h50HvXaymHlap7s0zta2215+ifk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=qjsIAN3+LBQ43eMLtfFHKX1vlopPAHHf
	p9Vw9DDHpXNa9qtwaYBAYMXSR+VNmKf1ldUoodkkmoRHoz5Ln0cZOA==
In-Reply-To: <Pine.LNX.4.64.0806130719590.17809@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Simon Horman <horms@verge.net.au>, Graeme Fowler <graeme@graemef.net>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Vince Busam <vbusam@google.com>

On Fri, Jun 13, 2008 at 4:24 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> As a user, I'd prefer only one version of ipvsadm, which handles all the
> versions of the kernel (at least backwards compatible). Sure the code will
> have new stuff tacked on down the bottom for updates, but it will run the
> old kernels too. I'm not asking that backward compatibility be maintained -
> if it breaks, then people can go back and dig up an older version. I've
> asked Horms about this years ago and he preferred to have separate versions
> of ipvsadm for each kernel. However since the matter of ipvsadm has come up,
> I'm putting in my $0.02

Not sure if I understood completely what you wanted to have compatible
with what. My opinion is that we should only worry about not breaking
the kernel interface:

- have the old ipvsadm still work with the new kernel (by keeping the
old sockopt interface in parallel)

- have the new ipvsadm _only_ work with the new kernel (so we only
have to support netlink in the new ipvsadm)

That way the worst that can happen is people upgrading ipvsadm without
upgrading their kernel, but that shouldn't be our (or a big) problem.

Julius

-- 
Google Switzerland GmbH
