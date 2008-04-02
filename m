From: Simon Horman <horms@verge.net.au>
Subject: Re: Least Connection Scheduler
Date: Wed, 2 Apr 2008 17:04:14 +0900
Message-ID: <20080402080412.GC9691@verge.net.au>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <20080401051641.GB21127@verge.net.au> <200804011455.58676.j.stubbs@linkthink.co.jp> <200804021138.15828.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200804021138.15828.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: lvs-devel@vger.kernel.org

On Wed, Apr 02, 2008 at 11:38:15AM +0900, Jason Stubbs wrote:
> On Tuesday 01 April 2008 14:55:58 Jason Stubbs wrote:
> > On Tuesday 01 April 2008 14:16:41 Simon Horman wrote:
> > > I think that the reasoning is that there is some expense related to
> > > inactive connections, though its probably only in terms of memory
> > > or possibly scheduler (thus CPU) being taken up, and its probably
> > > a lot less than 1/256th of the cost associated with a live connection.
> >
> > This is the main reason why I kept the inactconns check as a secondary
> > decision. The number of inactive connections should still stay fairly well
> > balanced. If the number of inactive connections on a more powerful server
> > is high enough that it starts affecting performance, lesser servers should
> > start getting more requests causing things to even out again.
> >
> > > I like your patch, but I wonder if it might be better to make this
> > > configurable. Perhaps two values, multiplier for active and multiplier
> > > for inactive, which would be 256 and 1 by default. Setting such
> > > a configuration to 1 and 0 would achieve what you are after without
> > > changing the default behaviour.
> >
> > The request distribution should be nearly identical in the case of real
> > servers of equal specs. I guess I should brush off my mathematics and
> > calculate what the difference is in the various other cases. ;)
> 
> My mathematics was never really that good that I can just brush it off. ;)
> Instead, I wrote a little simulation (attached) that compares behaviours.
> The unbracketed figures below are values at the end of the run, the bracketed 
> figures below are peak values during the run and T is the total number of 
> connections sent to that server.
> 
> With 1000reqs/sec and two servers where #1 can handle 20% more requests:
> 
> Current LC
> 1:  A 21(23)  I 30567(30618)  T 153040
> 2:  A 24(26)  I 29388(29595)  T 146960
> 
> Patched LC
> 1:  A 22(22)  I 32978(32979)  T 164998
> 2:  A 23(23)  I 26977(26980)  T 135002
> 
> With 1000reqs/sec and two servers where #1 can handle 400% more requests:
> 
> Current LC
> 1:  A  5(11)  I 32352(32546)  T 162414
> 2:  A 24(26)  I 27619(28344)  T 137586
> 
> Patched LC
> 1:  A  9(10)  I 49191(49195)  T 245998
> 2:  A  9(10)  I 10791(10793)  T  54002
> 
> Looking at these figures, the only real problem would be the extra number of 
> inactive connections on the faster server. However, after thinking about 
> adding server weights to the equation, I'm wondering if this would not be 
> better as yet-another-scheduler? I don't really like the idea of adding extra 
> configuration as it steps away from LVS's current simplicity, but the 
> difference in behaviour compared to the WLC scheduler is too great to be able 
> to merge as is... Would yet-another-scheduler be accepted?

Nice numbers :-)

LVS does already have a number of /proc values that can be twiddled
so I personally don't see a problem with adding one more - then again
I'm bound to say that as it was my idea.

If you want to code it up as an additional scheduler that is fine.
But looking at your numbers, I am kind of leaning towards just
using your existing patch.

I agree that the only real problem would be the extra number of
inactive connections on the faster server. But the overhead of such
things is really quite small - ~128 bytes of memory and a bit of
extra time to go through the hash table (maybe).

-- 
宝曼 西門 (ホウマン・サイモン) | Simon Horman (Horms)
