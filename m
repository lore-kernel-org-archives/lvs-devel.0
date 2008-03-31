From: "Julius Volz" <juliusv@google.com>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 13:22:21 +0200
Message-ID: <f4845fc0803310422l357d3f01x64700a7efb50a64e@mail.gmail.com>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
	 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
	 <20080331030715.GH31306@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206962572; bh=n/s+8ZivGcmM057XBevKolRm864=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=puxlJhl6i0q65f8Eidj9LrnPstiN1N6S
	TyLcmTL8xBeh7SfIkVuRYwuyWO0NBjqGz7qywfOcUJH+Q3v8258r4A==
In-Reply-To: <20080331030715.GH31306@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Hi Horms,

On Mon, Mar 31, 2008, Simon Horman <horms@verge.net.au> wrote:
>  There was a very old effort that you can find if you search a bit -
>  I can dig up a link if you can't find it. But as far as I am aware
>  there are no efforts at this time.

Yes, you are probably talking about this:

http://www.yggr-drasill.com/LVS6/documents.html

The link has been dead for me throughout the last weeks (and seemed to
be dead in 2003 already, so it's very, very old anyways).

>  [ Joe, I'm not sure that the LOCAL_IN stuff is really related
>   specifically to IPv6. But you do remind me that those patches
>   need to be revisited. ]

So these patches might already be in the kernel when I'm starting any
real coding work...

>  Yes, I expect so to. It would be good to open up a discussion
>  with Dave Miller and the other netdev people about any refactoring
>  that you think is needed. They should be able to advise on what
>  should go where.

Thanks for the pointer! I will explain the issue to them!

>  IPv6 is something that has been needed for a long time. I'm quite
>  interested in it myself. But to date haven't had any luck finding
>  time to work on it. I'm happy to help out with your effort. Though
>  I imagine that for the most part it will be in the form of reviewing
>  patches.

Thanks, any help is greatly appreciated! At the moment, I'm still
looking at the different projects, how they work together and how to
go about this sort of thing in general.

>  To be honest, sometimes when I look at the code I get surprises too.

:-)

>  But if you have any questions please just send them my way, CC usually
>  gets my attention.

Sure, I will!

Thanks,
Julius

-- 
Google Switzerland GmbH
