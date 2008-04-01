From: Simon Horman <horms@verge.net.au>
Subject: Re: Least Connection Scheduler
Date: Tue, 1 Apr 2008 14:16:41 +0900
Message-ID: <20080401051641.GB21127@verge.net.au>
References: <200804011336.08118.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200804011336.08118.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: lvs-devel@vger.kernel.org

On Tue, Apr 01, 2008 at 01:36:08PM +0900, Jason Stubbs wrote:
> Hi all,
> 
> This mail half belongs on -user, but there's a patch attached so I'm sending 
> it here instead.
> 
> I'm wanting to use the LC scheduler with servers of different specs but the 
> docs say that it doesn't perform well in this case due to TIME_WAIT 
> connections. According to the HOWTO, everything that is not an ESTABLISHED 
> connection is counted as inactive.  The current LC scheduler calculates each 
> server with the formula of (activeconns<<8) + inactconns.
> 
> Now, the only reason I can see for activeconns to be offset by inactconns at 
> all is so that round-robining happens when activeconns is equal among several 
> servers. If that is in fact the only reason, how does the attached patch 
> look? The resulting request distribution should match server resources fairly 
> closely with sufficient load. The only downside that I can see is that slower 
> servers would get priority when activeconns are equal, but is that really a 
> problem?

Hi Jason,

I think that the reasoning is that there is some expense related to
inactive connections, though its probably only in terms of memory
or possibly scheduler (thus CPU) being taken up, and its probably
a lot less than 1/256th of the cost associated with a live connection.

I like your patch, but I wonder if it might be better to make this
configurable. Perhaps two values, multiplier for active and multiplier
for inactive, which would be 256 and 1 by default. Setting such
a configuration to 1 and 0 would achieve what you are after without
changing the default behaviour.

-- 
宝曼 西門 (ホウマン・サイモン) | Simon Horman (Horms)
