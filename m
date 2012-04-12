From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Thu, 12 Apr 2012 02:13:09 +0200
Message-ID: <20120412001309.GA7294@1984>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
 <1332320185-27157-6-git-send-email-horms@verge.net.au>
 <20120402111145.GA15181@1984>
 <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg>
 <20120405150553.GA8144@1984>
 <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
 <20120409230803.GB27514@1984>
 <alpine.LFD.2.00.1204112221250.2000@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204112221250.2000@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

Hi Julian,

On Wed, Apr 11, 2012 at 11:02:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 10 Apr 2012, Pablo Neira Ayuso wrote:
> 
> > You can still use kthread_should_stop inside a wrapper function
> > that calls kthread_stop and up() the semaphore.
> > 
> > sync_stop:
> >         kthread_stop(k)
> >         up(s)
> > 
> > kthread_routine:
> >         while(1) {
> >                 down(s)
> >                 if (kthread_should_stop(k))
> >                         break;
> > 
> >                 get sync msg
> >                 send sync msg
> >         }
> > 
> > BTW, each up() does not necessarily mean one wakeup event. up() will
> > delivery only one wakeup event for one process that has been already
> > awaken.
> 
> 	OK, now I added up(). It will be called when
> 32 messages are queued after last sent by thread.

Why 32?

If you do up() once per message, you will still get an arbitrary
number of messages in the queue until the scheduler selects your
thread to enter the running state.

In other works, if you do up() once per 32 messages, your thread will
get N+32 messages in its queue by the time the scheduler makes it
enter the running state. Being N that amount of arbitrary messages.
This seems to me like more chances to overrun the socket buffer under
high stress.

> > > 	I'm still thinking if sndbuf value should be exported,
> > > currently users have to modify the global default/max value.
> > 
> > I think it's a good idea.
> 
> 	Done, used same value both for rcvbuf and sndbuf.
> 
> > > But in below version I'm trying to handle the sndbuf overflow
> > > by blocking for write_space event. By this way we should work
> > > with any sndbuf configuration.
> > 
> > You seem to be defering the overrun problem by using a longer
> > intermediate queue than the socket buffer. Then, that queue can be
> > tuned by the user via sysctl. It may happen under heavy stress that
> > your intermediate queue gets full again, then you'll have to drop
> > packets at some point.
> 
> 	Yes, both values are for same thing, the problem is
> that queue size is in messages while socket buffer is in bytes.
> And as sndbuf config is optional, I'm not trying to derive
> sync_qlen_max from sndbuf. May be we can do it after
> socket is created but it will cause problem for systems
> that do not configure sync_sock_size, they before now used
> unlimited queue and may be default socket size, so using
> some small default sndbuf as sync_qlen_max can cause message
> drops. They will use reduced limits. So, now we provide
> some large sync_qlen_max as default configuration
> which probably exceeds the default socket buffer.
>
> 	Still, I think the down/up idea is not better.
> We are adding two new vars: master_stopped and
> master_sem.

Well, this is not exactly the idea I had in mind.

> 	The problem is that kthread_stop() is a blocking
> function. It waits thread to terminate. It can not wakeup
> thread blocked in down(), so we add master_stopped flag
> that will unblock the down() loop while kthread_stop() will also
> unblock thread if waiting for write_space. I.e. up()+kthread_stop()
> is racy without additional flag while kthread_stop()+up()
> is not possible to work.

I don't see the up+kthread_stop() race you mention.

> 	I'm appending untested version with up+down but I think
> we should use wake_up_process and schedule_timeout instead,
> as in previous version.

OK.

I still think that using an intermediate queue is *not* the way
to achieve reliability and congestion control, sorry.

But, you seem to persist on the idea and I don't want to block your
developments, I just wanted to show my point and provide some ideas.
After all, you maintain that part of the code.

Please, tell me what patch you want me to apply and I'll take it.
