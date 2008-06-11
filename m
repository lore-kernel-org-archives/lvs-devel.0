From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 22:14:30 +0200
Message-ID: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <48500A0D.5020304@trash.net>
	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>
	 <48501C81.6010800@trash.net>
	 <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>
	 <4850233E.7090501@trash.net>
	 <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>
	 <48502826.9060502@trash.net>
	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213215272; bh=Bg1GD9zbz3HYDavuz4t1bJ1Pyqw=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=ZqxbN45pA3lZaNNU3m5IHW7+5I/EhbBb
	+sNmnOgfVj48GH+hn53HLz1++qHXVd8iIZKhOtBCTRZlAvdNFWTumA==
In-Reply-To: <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Vince Busam <vbusam@google.com>

On Wed, Jun 11, 2008 at 9:53 PM, Julius Volz <juliusv@google.com> wrote:
> Adding members at the end sounds interesting! The current structs have
> the v4 address members in the middle of the struct, so you couldn't
> use a union of v4 and v6 anymore, but since it's only in the userspace
> interface, that shouldn't matter much. If this allows us to keep the
> interface backwards compatible in an easy way, that would be great.

Ah, but the set/get-sockopt calls also pass a size argument, which is
the size of the passed structs. If the kernel and userspace struct
sizes don't match, it is treated as an error. Is this in case
different compilers pad the structs differently, even if the IPVS
version stays the same?

Julius

-- 
Google Switzerland GmbH
