From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 11 Apr 2008 13:12:39 +0200
Message-ID: <f4845fc0804110412h2ee5a6b5i1c1f26f09a9ddd75@mail.gmail.com>
References: <f4845fc0804040340x5e93754crcd680d26fd8982f7@mail.gmail.com>
	 <20080405010707.GB27827@verge.net.au>
	 <f4845fc0804110254s79eb6889sa654fc5d019db030@mail.gmail.com>
	 <200804111924.16263.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1207912362; bh=SjffCR3tcVpp2qi2qf397DfDKFs=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=IgD0A2NyjMiIopndDI0bYDl90hoXf19h
	EmPSm567UrAIfT3VTD0vUZ/tAT6H3lA3wSgPYY+T46DBx9vbMXWEKg==
In-Reply-To: <200804111924.16263.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: lvs-devel@vger.kernel.org

On Fri, Apr 11, 2008 at 12:24 PM, Jason Stubbs <j.stubbs@linkthink.co.jp> wrote:
>  I'd suggest not waiting on my patch as there's still a few things that need to

Ok!

>  be sorted out, tested and cleaned up. Not even certain that POST/PRE are the
>  best places yet... But thanks for the thought! :)

Sure, I'm trying to follow along, even if I don't understand everything ;)

Julius

-- 
Google Switzerland GmbH
