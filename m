From: "Julius Volz" <juliusv@google.com>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 14:49:33 +0200
Message-ID: <f4845fc0803310549m73294fb7u68e2a1655960b135@mail.gmail.com>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
	 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
	 <20080331030715.GH31306@verge.net.au>
	 <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206967775; bh=OV4VWJAB95KS+h9agmRkEy5BHRU=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=GA3PfURzxQuZ7qv/cHCyGN26c1oITlSH
	TDfLd84FeaDFf0vHKwLlykzBTbqdObsBlah50grFo7LkOoP5cYyG5g==
In-Reply-To: <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Mon, Mar 31, 2008, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Mon, 31 Mar 2008, Simon Horman wrote:
>
>  > [ Joe, I'm not sure that the LOCAL_IN stuff is really related
>  >  specifically to IPv6. But you do remind me that those patches
>  >  need to be revisited. ]
>
>  Agree, but we don't want Julius writing code for LOCAL_IN at
>  the same time we're moving the hook elsewhere.

Horms, when you take the mentioned patch, in which repository will it
go to first? In other words, which tree should I be using as my base
to always be up to date? Some netdev git repo or just Linus' main one
(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git)?

Thanks,
Julius

-- 
Google Switzerland GmbH
