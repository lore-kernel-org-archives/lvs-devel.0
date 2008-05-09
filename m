From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 9 May 2008 15:47:30 +0200
Message-ID: <f4845fc0805090647j64ec5555i46e4af3269db773d@mail.gmail.com>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
	 <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
	 <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
	 <200805092221.57251.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1210340852; bh=Hq8XszKG20k1WNXEGQzUAfOK4Io=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=wkGM7AeW0+0eRZkWa5zxFag8OK+iPL/l
	GARcVabWxTupwMSZTPQ2e/Z5919dieWQ2Mmsm7SnHblmOkM5D9skww==
In-Reply-To: <200805092221.57251.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Fri, May 9, 2008, Jason Stubbs wrote:
> I haven't applied the patch and done a diff to individual files to be certain, but I'm pretty sure that the patch is mainly just a directory change.

Yes, this is only a directory move of the current code in the kernel
(with the needed small Kconfig and Makefile adjustments for that, of
course).

Basically, you can arrive at this patch by doing:

$ git mv net/ipv4/ipvs net/netfilter
change net/ipv4/Kconfig:
        - source "net/ipv4/ipvs/Kconfig" => move (with adjusted dir)
to net/netfilter/Kconfig
change net/ipv4/Makefile:
        - obj-$(CONFIG_IP_VS) += ipvs/   => move to net/netfilter/Makefile

Julius

-- 
Google Switzerland GmbH
