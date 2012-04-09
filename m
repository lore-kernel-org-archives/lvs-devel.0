From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Tue, 10 Apr 2012 01:08:03 +0200
Message-ID: <20120409230803.GB27514@1984>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
 <1332320185-27157-6-git-send-email-horms@verge.net.au>
 <20120402111145.GA15181@1984>
 <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg>
 <20120405150553.GA8144@1984>
 <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

Hi Julian,

On Sun, Apr 08, 2012 at 11:12:53PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 5 Apr 2012, Pablo Neira Ayuso wrote:
> 
> > I think you can control when the kernel thread is woken up with a
> > counting semaphore. The counter of that semaphore will be initially
> > set to zero. Then, you can up() the semaphore once per new buffer
> > that you enqueue to the sender.
> > 
> > feeder:
> >         add message to sync buffer
> >         if buffer full:
> >                 enqueue buffer to sender_thread
> >                 up(s)
> > 
> > sender_thread:
> >         while (1) {
> >                 down(s)
> >                 retrieve message from queue
> >                 send message
> >         }
> > 
> > It seems to me like the classical producer/consumer problem that you
> > can resolve with semaphores.
> 
> 	May be it is possible to use up/down but we
> have to handle the kthread_should_stop check and also
> I prefer to reduce the wakeup events. So, I'm trying
> another solution which is appended just for review.

You can still use kthread_should_stop inside a wrapper function
that calls kthread_stop and up() the semaphore.

sync_stop:
        kthread_stop(k)
        up(s)

kthread_routine:
        while(1) {
                down(s)
                if (kthread_should_stop(k))
                        break;

                get sync msg
                send sync msg
        }

BTW, each up() does not necessarily mean one wakeup event. up() will
delivery only one wakeup event for one process that has been already
awaken.

> > Under congestion the situation is complicated. At some point you'll
> > end up dropping messages.
> > 
> > You may want to increase the socket queue to delay the moment at which
> > we start dropping messages. You can expose the socke buffer length via
> > /proc interface I guess (not sure if you're already doing that or
> > suggesting to use the global socket buffer length).
> 
> 	I'm still thinking if sndbuf value should be exported,
> currently users have to modify the global default/max value.

I think it's a good idea.

> But in below version I'm trying to handle the sndbuf overflow
> by blocking for write_space event. By this way we should work
> with any sndbuf configuration.

You seem to be defering the overrun problem by using a longer
intermediate queue than the socket buffer. Then, that queue can be
tuned by the user via sysctl. It may happen under heavy stress that
your intermediate queue gets full again, then you'll have to drop
packets at some point.

> > You also can define some mechanism to reduce the amount of events,
> > some state filtering so you only propagate important states.
> > 
> > Some partially reliable protocol, so the backup can request messages
> > that got lost in a smart way would can also in handy. Basically, the
> > master only retransmits the current state, not the whole sequence of
> > messages (this is good under congestion, since you save messages).
> > I implement that in conntrackd, but that's more complex solution,
> > of course. I'd start with something simple.
> 
> 	The patch "reduce sync rate with time thresholds"
> that follows the discussed one in the changeset has such
> purpose to reduce the events, in tests the sync traffic is
> reduced ~10 times. But it does not modify the current
> protocol, it adds a very limited logic for retransmissions.

Not directly related to this, but I'd prefer if any retransmission
support (or any new feature) gets added in follow-up patches. So we
can things separated in logic pieces. Thanks.
