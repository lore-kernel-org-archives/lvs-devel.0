From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Wed, 09 Mar 2011 18:53:44 -0800 (PST)
Message-ID: <20110309.185344.193704334.davem@davemloft.net>
References: <1299402367.2758.87.camel@edumazet-laptop>
	<alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
	<20110310013442.GD3028@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110310013442.GD3028@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: ja@ssi.bg, eric.dumazet@gmail.com, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, hans@schillstrom.com

From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 Mar 2011 10:34:42 +0900

> On Sun, Mar 06, 2011 at 02:18:35PM +0200, Julian Anastasov wrote:
> 
> [ snip ]
> 
>> 	Zero the new percpu stats because we copy from there.
>> Use the stats spin lock to synchronize the percpu zeroing with
>> the percpu reading, both in user context and not in a hot path.
>> 
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Eric, do you have any thoughts on this?
> It seems clean to me.

Eric is away until this weekend, so don't be alarmed by a
late response :-)
