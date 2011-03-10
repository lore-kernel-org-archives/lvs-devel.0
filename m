From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Thu, 10 Mar 2011 13:27:36 +0900
Message-ID: <20110310042736.GD21584@verge.net.au>
References: <1299402367.2758.87.camel@edumazet-laptop>
 <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
 <20110310013442.GD3028@verge.net.au>
 <20110309.185344.193704334.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110309.185344.193704334.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: ja@ssi.bg, eric.dumazet@gmail.com, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, hans@schillstrom.com

On Wed, Mar 09, 2011 at 06:53:44PM -0800, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Thu, 10 Mar 2011 10:34:42 +0900
> 
> > On Sun, Mar 06, 2011 at 02:18:35PM +0200, Julian Anastasov wrote:
> > 
> > [ snip ]
> > 
> >> 	Zero the new percpu stats because we copy from there.
> >> Use the stats spin lock to synchronize the percpu zeroing with
> >> the percpu reading, both in user context and not in a hot path.
> >> 
> >> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > 
> > Eric, do you have any thoughts on this?
> > It seems clean to me.
> 
> Eric is away until this weekend, so don't be alarmed by a
> late response :-)

Thanks, I'll wait longer :-)
