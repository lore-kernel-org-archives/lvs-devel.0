From: Graeme Fowler <graeme@graemef.net>
Subject: Re: Least Connection Scheduler
Date: Wed, 02 Apr 2008 09:15:57 +0100
Message-ID: <1207124157.16121.4.camel@ernie.internal.graemef.net>
References: <200804011336.08118.j.stubbs@linkthink.co.jp>
	 <20080401051641.GB21127@verge.net.au>
	 <200804011455.58676.j.stubbs@linkthink.co.jp>
	 <200804021138.15828.j.stubbs@linkthink.co.jp>
	 <20080402080412.GC9691@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080402080412.GC9691@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Jason Stubbs <j.stubbs@linkthink.co.jp>, lvs-devel@vger.kernel.org

On Wed, 2008-04-02 at 17:04 +0900, Simon Horman wrote:
> LVS does already have a number of /proc values that can be twiddled
> so I personally don't see a problem with adding one more - then again
> I'm bound to say that as it was my idea.

Personally speaking, the more stuff that's controllable with /proc the
better - it makes it easier to code up additional control environments
without the execution overhead of calling ipvsadm multiple times.

> If you want to code it up as an additional scheduler that is fine.
> But looking at your numbers, I am kind of leaning towards just
> using your existing patch.

Pardon me for speaking out of turn, but an idea just crossed my mind -
wouldn't it be better to "merge" (not in code terms) the lc and wlc
schedulers so they either base on, or use exactly, the same code? After
all, in concept the lc scheduler is simply wlc with equal weights of 1.
Isn't it?
That shrinks the codebase a bit.

> I agree that the only real problem would be the extra number of
> inactive connections on the faster server. But the overhead of such
> things is really quite small - ~128 bytes of memory and a bit of
> extra time to go through the hash table (maybe).

This would only be a problem in really large throughput situations, and
if you have one of them you probably already have some $$$ to buy a
faster processor!

Regards

Graeme

