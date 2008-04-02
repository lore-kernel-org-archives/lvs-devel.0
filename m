From: Simon Horman <horms@verge.net.au>
Subject: Re: Least Connection Scheduler
Date: Wed, 2 Apr 2008 17:31:21 +0900
Message-ID: <20080402083119.GA14708@verge.net.au>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <20080401051641.GB21127@verge.net.au> <200804011455.58676.j.stubbs@linkthink.co.jp> <200804021138.15828.j.stubbs@linkthink.co.jp> <20080402080412.GC9691@verge.net.au> <1207124157.16121.4.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1207124157.16121.4.camel@ernie.internal.graemef.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Graeme Fowler <graeme@graemef.net>
Cc: Jason Stubbs <j.stubbs@linkthink.co.jp>, lvs-devel@vger.kernel.org

On Wed, Apr 02, 2008 at 09:15:57AM +0100, Graeme Fowler wrote:
> On Wed, 2008-04-02 at 17:04 +0900, Simon Horman wrote:
> > LVS does already have a number of /proc values that can be twiddled
> > so I personally don't see a problem with adding one more - then again
> > I'm bound to say that as it was my idea.
> 
> Personally speaking, the more stuff that's controllable with /proc the
> better - it makes it easier to code up additional control environments
> without the execution overhead of calling ipvsadm multiple times.
> 
> > If you want to code it up as an additional scheduler that is fine.
> > But looking at your numbers, I am kind of leaning towards just
> > using your existing patch.
> 
> Pardon me for speaking out of turn, but an idea just crossed my mind -
> wouldn't it be better to "merge" (not in code terms) the lc and wlc
> schedulers so they either base on, or use exactly, the same code? After
> all, in concept the lc scheduler is simply wlc with equal weights of 1.
> Isn't it?
> That shrinks the codebase a bit.

Yes, I think that would be an excellent idea.
We could still have the different schedulers (for compatibility), but
have them share common code - which would basically be all of it.

I imagine that the same thing could be done for rr and wrr.

I guess that the original motivation for the separation was
either performance or to demonstrate it was possible to have more
than one scheduler at a time when there was only one.

> > I agree that the only real problem would be the extra number of
> > inactive connections on the faster server. But the overhead of such
> > things is really quite small - ~128 bytes of memory and a bit of
> > extra time to go through the hash table (maybe).
> 
> This would only be a problem in really large throughput situations, and
> if you have one of them you probably already have some $$$ to buy a
> faster processor!

Yes, I was struggling to think of a situation where it would be
a problem in practice.

-- 
Horms

