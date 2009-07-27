From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG
	messages
Date: Mon, 27 Jul 2009 12:37:55 +1000
Message-ID: <20090727023754.GC723@verge.net.au>
References: <20090624132232.GA9633@egardia> <20090724024711.GA13280@verge.net.au> <4A6937B5.3040707@gmail.com> <20090726.191905.158195470.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090726.191905.158195470.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: eric.dumazet@gmail.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, julius.volz@gmail.com, robert.gallagher@heanet.ie

On Sun, Jul 26, 2009 at 07:19:05PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 24 Jul 2009 06:25:25 +0200
> 
> > I see no reference to ICMPV6_PKT_TOOBIG in this patch, so ChangeLog
> > might be misleading or uncomplete, since other ICMPV6 message types
> > (ICMPV6_DEST_UNREACH/ICMPV6_TIME_EXCEED) will also be forwarded/handled
> > ?
> 
> Agreed, this commit message could use a tidy.  What the patch actually is
> doing is adding the handling of ipv6 icmp messages at all.
> 
> Simon could you clarify the commit message a bit and resubmit?

Will do.
