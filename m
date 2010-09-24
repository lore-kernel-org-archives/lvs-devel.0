From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC][PATCH] ipvs: IPv6 tunnel mode
Date: Fri, 24 Sep 2010 14:06:10 +0200
Message-ID: <1285329970.6178.4.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
References: <Pine.LNX.4.58.1009181704560.8786@u.domain.uli>
	 <1284977589.25529.203.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
	 <alpine.LFD.2.00.1009221424420.3402@u.domain.uli>
	 <1285258581.25529.237.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
	 <alpine.LFD.2.00.1009240114450.3247@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1009240114450.3247@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, Julius Volz <juliusv@google.com>

Hi Julian
I'm ready with my tests no bugs, so you can push it

Regads 
Hans Schillstom <hans.schillstom@ericsson.com>

On Fri, 2010-09-24 at 00:36 +0200, Julian Anastasov wrote:
>  	Hello,
> 
> On Thu, 23 Sep 2010, Hans Schillstrom wrote:
> 
> > IPv6
> > dst caching works.
> > Tunnel mode on same physical link as VIP works
> > Tunnel mode on other interface as VIP also work
> > and it also works in another network namespace !
> > More testing will be needed...
> 
>  	Thanks! Should it work in another namespace ? :)
> I'm sure your namespace work will make it possible.
> 
> > IPv4
> > No tests made yet, I'll do that tomorrow.
> 
>  	The changes for IPv4 are little, I tested TUN for v4.
> Let me know if you need more changes in this patch or
> if I should push it as-is with your Signed-off-by line.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

