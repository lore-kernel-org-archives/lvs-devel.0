From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Wed, 26 Nov 2008 23:37:58 -0800 (PST)
Message-ID: <20081126.233758.235891402.davem@davemloft.net>
References: <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
	<20081126.152748.244331470.davem@davemloft.net>
	<41063.91.201.80.240.1227769550.squirrel@mail.embedromix.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <41063.91.201.80.240.1227769550.squirrel@mail.embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: catab@embedromix.ro
Cc: jmack@wm7d.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Date: Thu, 27 Nov 2008 00:05:50 -0700 (MST)

> Do you mean that it should be computed based on memory size or you mean
> that it should be changeable on-the-fly, even when we have some
> connections in the tables already?

I mean the latter.  We do this in other subsystems, such as
IPSEC, for various hashes.

> Do you have some hints (where to look for a similar thing)?
> The thing that worries me a little is the locking around the move and
> maybe the latency involved. Yes, of course you will not change it several
> times per minute, but...

You only increase, never decrease.

A lock is held during every access to these hash tables, so
the locking should be very similar.

Have a look at xfrm_hash_resize() in net/xfrm/xfrm_state.c to get
a good idea on how this stuff can be done.  And hey, that code
resizes 3 tables at once, you only need to handle one :)
