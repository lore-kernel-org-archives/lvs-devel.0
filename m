From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Thu, 5 Apr 2012 17:05:53 +0200
Message-ID: <20120405150553.GA8144@1984>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
 <1332320185-27157-6-git-send-email-horms@verge.net.au>
 <20120402111145.GA15181@1984>
 <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

Hi Julian,

On Wed, Apr 04, 2012 at 12:16:15AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 2 Apr 2012, Pablo Neira Ayuso wrote:
> 
> > > From: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	High rate of sync messages in master can lead to
> > > overflowing the socket buffer and dropping the messages.
> > > Instead of using fixed pause try to adapt to the sync
> > > rate, so that we do not wakeup too often while at the same
> > > time staying below the socket buffer limit.
> > 
> > I see. You are avoiding the congestion in the socket queue by putting
> > the pressure in your sync_buff queue  (I don't find any limit in
> > the code for the amount of memory that it may consume btw).
> > 
> > Please, correct me if I'm wrong, but from this I can se you're
> > assuming that there's always room in the syn_buff queue to store
> > messages. This is valid if the high peak of traffic lasts for short
> > time. However, if it lasts long, the worker thread may not be able to
> > consume all the messages in time under high stress situation that
> > lasts long and the sync_buffer may keep growing more and more.
> 
> 	Agreed, packet processing does not check for any
> limits for the sync_queues lists. This can be addressed
> additionally, may be there can be some wakeup if threshold
> is reached, so that we wake up the master thread early.
> But there is always the problem that we do not know how
> deep/free is the socket buffer, after how much time the
> master thread will wakeup... We have to select some arbitrary
> number again.

I see, see below.

> > Moreover, the backup may receive sync messages talking about old
> > states that are not useful anymore to recover the load-balancing in
> > case of failover.
> 
> 	Can you explain more? Are you referring to the
> 2-second buffer delay?

I was refering to the situation in which you decide to delay sync
messages due to congestion. State sync needs to be soft real-time to
ensure that the backup is one copy-equivalence of the master (at
least, close to it, even if that's not possible). Otherwise, the
backup may contain useless out-of-date states.

> > One more concern, please see below.
> 
> > > -		schedule_timeout_interruptible(HZ);
> > > +		/* Max packets to send at once */
> > > +		if (count > 200)
> > > +			pause = max(1, (pause - HZ / 20));
> > > +		else if (count < 20)
> > > +			pause = min(HZ / 4, (pause + HZ / 20));
> > > +		schedule_timeout_interruptible(sb ? 1 : pause);
> > 
> > This rate-limits the amount of times the worker is woken up.
> > 
> > Still, this seems to me like an ad-hoc congestion solution. There's no
> > justification why those numbers has been chosed, eg. why do we assume
> > that we're congested if we've reached 200 packets in one single loop?
> 
> 	200 is arbitrary, 20% of txqueuelen, a way to avoid
> large bursts. It is the 'pause = max(1, (pause >> 1));' part
> that also matters because we try to increase the wakeup rate, so
> that socket buffer is below 50%. We assume sync traffic rate
> does not change much but we are still prepared to avoid
> drops while pause > 1 jiffie. If sync rate is too high may be
> we should wakeup the master thread in sb_queue_tail.
> 
> 	The above logic should be read like this:
> 
> - limit bursts to min(200, half of guessed socket buffer size)
> - limit pause to HZ/4 jiffies in idle periods
> - if socket buffer is full try again after 1 jiffie and
> increase the wakeups twice, so that we do not hit the
> socket limit again

I think you can control when the kernel thread is woken up with a
counting semaphore. The counter of that semaphore will be initially
set to zero. Then, you can up() the semaphore once per new buffer
that you enqueue to the sender.

feeder:
        add message to sync buffer
        if buffer full:
                enqueue buffer to sender_thread
                up(s)

sender_thread:
        while (1) {
                down(s)
                retrieve message from queue
                send message
        }

It seems to me like the classical producer/consumer problem that you
can resolve with semaphores.

Thus, you don't need to poll periodically to check if there's
messages. You won't need to adapt "pause" time.

> > To me, congestion control is a complicated thing (there is plenty of
> > literature for TCP avoid it). I'm not sure how many patches will
> > follow after this one to try to improve your congestion control
> > solution.
> > 
> > So, my question is, are you sure you want to enter this domain?
> 
> 	We should start with something. Better ideas are
> always welcome.
> 
> > IMO, better to stick to some simple solution, ie. just drop messages
> > if the worker thread receives a high peak of work, than trying to
> > define some sort of rate-limit solution based on assumptions that are
> > not generic enough for every setup.
> 
> 	Before now we dropped messages due to large fixed sleep time.
> They were dropped when socket buffer was full. Dropping messages is
> not nice just because we decided to sleep longer than needed.
> With the change we still drop messages but not before pause
> reaches 1 jiffie. As we can not use lower sleep time only
> additional wakeup in sb_queue_tail can keep up with higher
> sync rates. May be we should decide to drop messages only
> when some max limit for packets in sync_queues is reached.

Under congestion the situation is complicated. At some point you'll
end up dropping messages.

You may want to increase the socket queue to delay the moment at which
we start dropping messages. You can expose the socke buffer length via
/proc interface I guess (not sure if you're already doing that or
suggesting to use the global socket buffer length).

You also can define some mechanism to reduce the amount of events,
some state filtering so you only propagate important states.

Some partially reliable protocol, so the backup can request messages
that got lost in a smart way would can also in handy. Basically, the
master only retransmits the current state, not the whole sequence of
messages (this is good under congestion, since you save messages).
I implement that in conntrackd, but that's more complex solution,
of course. I'd start with something simple.
