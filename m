From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Wed, 4 Apr 2012 00:16:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au> <1332320185-27157-6-git-send-email-horms@verge.net.au> <20120402111145.GA15181@1984>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120402111145.GA15181@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Mon, 2 Apr 2012, Pablo Neira Ayuso wrote:

> > From: Julian Anastasov <ja@ssi.bg>
> > 
> > 	High rate of sync messages in master can lead to
> > overflowing the socket buffer and dropping the messages.
> > Instead of using fixed pause try to adapt to the sync
> > rate, so that we do not wakeup too often while at the same
> > time staying below the socket buffer limit.
> 
> I see. You are avoiding the congestion in the socket queue by putting
> the pressure in your sync_buff queue  (I don't find any limit in
> the code for the amount of memory that it may consume btw).
> 
> Please, correct me if I'm wrong, but from this I can se you're
> assuming that there's always room in the syn_buff queue to store
> messages. This is valid if the high peak of traffic lasts for short
> time. However, if it lasts long, the worker thread may not be able to
> consume all the messages in time under high stress situation that
> lasts long and the sync_buffer may keep growing more and more.

	Agreed, packet processing does not check for any
limits for the sync_queues lists. This can be addressed
additionally, may be there can be some wakeup if threshold
is reached, so that we wake up the master thread early.
But there is always the problem that we do not know how
deep/free is the socket buffer, after how much time the
master thread will wakeup... We have to select some arbitrary
number again.

> Moreover, the backup may receive sync messages talking about old
> states that are not useful anymore to recover the load-balancing in
> case of failover.

	Can you explain more? Are you referring to the
2-second buffer delay?

> One more concern, please see below.

> > -		schedule_timeout_interruptible(HZ);
> > +		/* Max packets to send at once */
> > +		if (count > 200)
> > +			pause = max(1, (pause - HZ / 20));
> > +		else if (count < 20)
> > +			pause = min(HZ / 4, (pause + HZ / 20));
> > +		schedule_timeout_interruptible(sb ? 1 : pause);
> 
> This rate-limits the amount of times the worker is woken up.
> 
> Still, this seems to me like an ad-hoc congestion solution. There's no
> justification why those numbers has been chosed, eg. why do we assume
> that we're congested if we've reached 200 packets in one single loop?

	200 is arbitrary, 20% of txqueuelen, a way to avoid
large bursts. It is the 'pause = max(1, (pause >> 1));' part
that also matters because we try to increase the wakeup rate, so
that socket buffer is below 50%. We assume sync traffic rate
does not change much but we are still prepared to avoid
drops while pause > 1 jiffie. If sync rate is too high may be
we should wakeup the master thread in sb_queue_tail.

	The above logic should be read like this:

- limit bursts to min(200, half of guessed socket buffer size)
- limit pause to HZ/4 jiffies in idle periods
- if socket buffer is full try again after 1 jiffie and
increase the wakeups twice, so that we do not hit the
socket limit again

> To me, congestion control is a complicated thing (there is plenty of
> literature for TCP avoid it). I'm not sure how many patches will
> follow after this one to try to improve your congestion control
> solution.
> 
> So, my question is, are you sure you want to enter this domain?

	We should start with something. Better ideas are
always welcome.

> IMO, better to stick to some simple solution, ie. just drop messages
> if the worker thread receives a high peak of work, than trying to
> define some sort of rate-limit solution based on assumptions that are
> not generic enough for every setup.

	Before now we dropped messages due to large fixed sleep time.
They were dropped when socket buffer was full. Dropping messages is
not nice just because we decided to sleep longer than needed.
With the change we still drop messages but not before pause
reaches 1 jiffie. As we can not use lower sleep time only
additional wakeup in sb_queue_tail can keep up with higher
sync rates. May be we should decide to drop messages only
when some max limit for packets in sync_queues is reached.

Regards

--
Julian Anastasov <ja@ssi.bg>
