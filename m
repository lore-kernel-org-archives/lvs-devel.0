From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Least Connection Scheduler
Date: Tue, 1 Apr 2008 14:55:58 +0900
Message-ID: <200804011455.58676.j.stubbs@linkthink.co.jp>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <20080401051641.GB21127@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080401051641.GB21127@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
To: lvs-devel@vger.kernel.org

On Tuesday 01 April 2008 14:16:41 Simon Horman wrote:
> On Tue, Apr 01, 2008 at 01:36:08PM +0900, Jason Stubbs wrote:
> > Hi all,
> >
> > This mail half belongs on -user, but there's a patch attached so I'm
> > sending it here instead.
> >
> > I'm wanting to use the LC scheduler with servers of different specs but
> > the docs say that it doesn't perform well in this case due to TIME_WAIT
> > connections. According to the HOWTO, everything that is not an
> > ESTABLISHED connection is counted as inactive.  The current LC scheduler
> > calculates each server with the formula of (activeconns<<8) + inactconns.
> >
> > Now, the only reason I can see for activeconns to be offset by inactconns
> > at all is so that round-robining happens when activeconns is equal among
> > several servers. If that is in fact the only reason, how does the
> > attached patch look? The resulting request distribution should match
> > server resources fairly closely with sufficient load. The only downside
> > that I can see is that slower servers would get priority when activeconns
> > are equal, but is that really a problem?
>
> I think that the reasoning is that there is some expense related to
> inactive connections, though its probably only in terms of memory
> or possibly scheduler (thus CPU) being taken up, and its probably
> a lot less than 1/256th of the cost associated with a live connection.

This is the main reason why I kept the inactconns check as a secondary 
decision. The number of inactive connections should still stay fairly well 
balanced. If the number of inactive connections on a more powerful server is 
high enough that it starts affecting performance, lesser servers should start 
getting more requests causing things to even out again.

> I like your patch, but I wonder if it might be better to make this
> configurable. Perhaps two values, multiplier for active and multiplier
> for inactive, which would be 256 and 1 by default. Setting such
> a configuration to 1 and 0 would achieve what you are after without
> changing the default behaviour.

Hmm.. How would configuration be done? sysctls? None of the schedulers 
currently have any configuration other than server weight as far as I know. 
Also, the round-robin effect of utilizing inactive connection counts is still 
needed. In the case where several real servers share the load of servicing 
several VIPs, the servers listed earlier would be hit more often possibly 
overloading them without any round-robining.

The request distribution should be nearly identical in the case of real 
servers of equal specs. I guess I should brush off my mathematics and 
calculate what the difference is in the various other cases. ;)

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773
