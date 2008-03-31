From: "Julius Volz" <juliusv@google.com>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 15:47:47 +0200
Message-ID: <f4845fc0803310647h4655c2c4v481fd4c76dea8934@mail.gmail.com>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
	 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
	 <20080331030715.GH31306@verge.net.au>
	 <Pine.LNX.4.64.0803310441440.9996@wm7d.net>
	 <f4845fc0803310549m73294fb7u68e2a1655960b135@mail.gmail.com>
	 <20080331132810.GA3690@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206971269; bh=t1a4vwXNcvlJ4P/wwuyXLGMswgw=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Ecw2/fx2dzppCA/4mJmMtLH0fCg4R1Zd
	KlOMaiexG/mvTQCZtTQXhCQqqz8oYYCqNRBjWhJWS9wMOOhGCxhXOg==
In-Reply-To: <20080331132810.GA3690@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Hi,

On Mon, Mar 31, 2008, Simon Horman wrote:
>  IPVS patches almost always go through netdev and Dave Miller.
>  Dave has a two tree system that works as follows (as far as I
>  understand):
>
>  Suppose that the current version that Linus's tree is working towards
>  is 2.6.24. Then Dave's net-2.6.24 tree would be for bug fixes and
>  his net-2.6.25 tree would be for new features.
>
>  Once Linus releases 2.6.24 then his merge window for will 2.6.25 open
>  and likely stay open for a couple of weeks. I think that at that
>  time Dave's net-2.6.24 will be removed and net-2.6.25 will be merged
>  into Linus's tree. Once the merge window is closed and Linus's tree
>  is working towards 2.6.25 then net-2.6.25 will become the bugfixes
>  tree for netdev and net-2.6.26 will be creted to accept new work.

Thanks for the explanation! So I will try to always keep up to date
with his latest tree.

>  So with a bit of luck the LOCAL_IN stuff might go into net-2.6.26
>  (I think it would be pushing it to get it into net-2.6.25). In any
>  case, if you subscribe to this list (which is rather low volume),
>  then you will probably see any discussions that are going on.

Good. If you mean this list (lvs-devel), I am already subscribed (so
no need to CC me usually, as I will look through all mails). I will
also subscribe to linux-netdev, but since the traffic there is higher,
I won't read through all of it ;)

Regards,
Julius

-- 
Google Switzerland GmbH
