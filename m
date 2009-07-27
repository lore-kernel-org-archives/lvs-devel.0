From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG
 messages
Date: Sun, 26 Jul 2009 19:19:05 -0700 (PDT)
Message-ID: <20090726.191905.158195470.davem@davemloft.net>
References: <20090624132232.GA9633@egardia>
	<20090724024711.GA13280@verge.net.au>
	<4A6937B5.3040707@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4A6937B5.3040707@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: eric.dumazet@gmail.com
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, julius.volz@gmail.com, robert.gallagher@heanet.ie

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Jul 2009 06:25:25 +0200

> I see no reference to ICMPV6_PKT_TOOBIG in this patch, so ChangeLog might be
> misleading or uncomplete, since other ICMPV6 message types 
> (ICMPV6_DEST_UNREACH/ICMPV6_TIME_EXCEED) will also be forwarded/handled ?

Agreed, this commit message could use a tidy.  What the patch
actually is doing is adding the handling of ipv6 icmp messages
at all.

Simon could you clarify the commit message a bit and resubmit?

Thanks!
