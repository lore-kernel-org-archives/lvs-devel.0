From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Least Connection Scheduler
Date: Thu, 3 Apr 2008 20:14:39 +0900
Message-ID: <200804032014.39964.j.stubbs@linkthink.co.jp>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <20080402080412.GC9691@verge.net.au> <1207124157.16121.4.camel@ernie.internal.graemef.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1207124157.16121.4.camel@ernie.internal.graemef.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
To: Graeme Fowler <graeme@graemef.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

(not sure whether I should have been CC'ing in the past, but leaving them all 
in this time)

On Wednesday 02 April 2008 17:15:57 Graeme Fowler wrote:
> On Wed, 2008-04-02 at 17:04 +0900, Simon Horman wrote:
> > LVS does already have a number of /proc values that can be twiddled
> > so I personally don't see a problem with adding one more - then again
> > I'm bound to say that as it was my idea.
>
> Personally speaking, the more stuff that's controllable with /proc the
> better - it makes it easier to code up additional control environments
> without the execution overhead of calling ipvsadm multiple times.

I'm not sure what you mean here exactly. Are you saying that you'd like 
active/inactive weights be settable per virtual IP? If you have any pointers 
to existing code, I'd be grateful as I don't really know my way around the 
kernel at all.

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

I was thinking the same thing. The only reason I can see not to do this is the 
performance "hit" of doing extra multiplies. I guess if the code was merged 
with that in mind, the compiler should optimize them out anyway though.

> > I agree that the only real problem would be the extra number of
> > inactive connections on the faster server. But the overhead of such
> > things is really quite small - ~128 bytes of memory and a bit of
> > extra time to go through the hash table (maybe).
>
> This would only be a problem in really large throughput situations, and
> if you have one of them you probably already have some $$$ to buy a
> faster processor!

Hmm.. I was going to say again that it could be a problem with WLC, but after 
simulating it I found that it isn't:


Server 1 with weight=2 and twice as fast as Server 2

WLC
1:  A 17(23)  I 41159(41260)  T 206277
2:  A 16(17)  I 18808(19139)  T 93723

patched WLC
1:  A 20(23)  I 47980(47982)  T 239997
2:  A 10(11)  I 11990(11993)  T 60003


Server 1 with weight=2 and five times as fast as Server 2

WLC
1:  A 6(11)  I 41990(42120)  T 210497
2:  A 16(17)  I 17988(18629)  T 89503

patched WLC
1:  A 10(10)  I 53990(53995)  T 270000
2:  A 5(5)  I 5995(5996)  T 30000


Server 1 with weight=5 and five times as fast as Server 2

WLC
1:  A 8(11)  I 51097(51310)  T 255921
2:  A 8(9)  I 8887(9133)  T 44079

patched WLC
1:  A 10(10)  I 57590(57593)  T 288000
2:  A 2(2)  I 2398(2399)  T 12000


The number of connections thrown to the faster server is greater in each case 
but the number of simulatenous connections to the faster server is either the 
same or less. Even in this case, the only negative is the extra number of 
inactive connections.

So, is a configurable still needed? What about the round-robining? The 
round-robining has the benefit that the slower servers don't get an 
artificial priority boost, but adds a fair amount of processing overhead.

Let me know what to do and I'll at least look into doing it. :)

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773
