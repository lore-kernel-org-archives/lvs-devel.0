From: "Julius Volz" <juliusv@google.com>
Subject: Re: IPVS IPv6: code and data structure reuse
Date: Thu, 24 Apr 2008 18:38:32 +0200
Message-ID: <f4845fc0804240938g50762850n5bb0be912a91d78b@mail.gmail.com>
References: <f4845fc0804240432x7afcf927u70aace0b5f097dc0@mail.gmail.com>
	 <Pine.LNX.4.64.0804240516440.12876@wm7d.net>
	 <f4845fc0804240838s342149f2v3113ae44ff773f87@mail.gmail.com>
	 <Pine.LNX.4.64.0804240908370.5724@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1209055114; bh=SdkAy6hY/BaCKWGzgJN0b8eTq+E=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=sxB3hnZMy+2SDRR1VcWjy1wEaSyh4HQS
	NcPcneO//6GmYj2h51hXwaBm78VPb6dADQdZftEYkGQRTlEBXFUIHA==
In-Reply-To: <Pine.LNX.4.64.0804240908370.5724@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Joseph Mack NA3T <jmack@wm7d.net>

On Thu, Apr 24, 2008, Joseph Mack NA3T wrote:
>  well you may have time in the future, but don't count on it. Things happen,
> your car needs repair, you go on vacation, someone calls you up with a neat
> idea and you'll find you have 3 months of ipvs_ipv6 code sitting on the
> shelf which isn't going anywhere. Plan on writing code to your current
> horizon and if that winds up being what time you have, then you won't have
> done all that work for nothing. If you can keep going, then there's no harm
> done.

Very true, I will keep that in mind. The goal is to have a workable
version in my time here anyways, for lots of other reasons. I guess
for kernel inclusion, it has to reach a somewhat decent level of
quality, though.

I'll sadly be working on other things next week, but I will go on after that!

Julius

-- 
Google Switzerland GmbH
