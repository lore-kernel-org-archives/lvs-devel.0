From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Fri, 20 Apr 2012 01:51:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204200052180.8786@ja.ssi.bg>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au> <1332320185-27157-6-git-send-email-horms@verge.net.au> <20120402111145.GA15181@1984> <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg> <20120405150553.GA8144@1984> <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
 <20120409230803.GB27514@1984> <alpine.LFD.2.00.1204112221250.2000@ja.ssi.bg> <20120412001309.GA7294@1984>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120412001309.GA7294@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello Pablo,

On Thu, 12 Apr 2012, Pablo Neira Ayuso wrote:

> > 	OK, now I added up(). It will be called when
> > 32 messages are queued after last sent by thread.
> 
> Why 32?
> 
> If you do up() once per message, you will still get an arbitrary
> number of messages in the queue until the scheduler selects your
> thread to enter the running state.

	I understand this. It will save wakeups while
master thread is busy with messages but not if the
messages come with such gap that causes master thread
to send them one by one for every wakeup.

> In other works, if you do up() once per 32 messages, your thread will
> get N+32 messages in its queue by the time the scheduler makes it
> enter the running state. Being N that amount of arbitrary messages.
> This seems to me like more chances to overrun the socket buffer under
> high stress.

	I now modified the constant (to 8 which should be
8*8KB data, below default sndbuf) and the algorithm. The idea of
IPVS_SYNC_WAKEUP_RATE is to avoid situation where
we send wakeup for every message. It should be better
for the caching to send messages in short bursts.

> > 	Still, I think the down/up idea is not better.
> > We are adding two new vars: master_stopped and
> > master_sem.
> 
> Well, this is not exactly the idea I had in mind.

	Currently, we need a _timeout version because
sync_buff can be ready after 2 seconds and we do not
get wakeup for such incomplete buffer, we have to check it
from time to time. IIRC, using uninterruptible version
causes the thread to bump the CPU load usage, so it
is not appropriate - this state contributes to load.
It is really for busy state, not for idle state
waiting for messages to send.

> > 	The problem is that kthread_stop() is a blocking
> > function. It waits thread to terminate. It can not wakeup
> > thread blocked in down(), so we add master_stopped flag
> > that will unblock the down() loop while kthread_stop() will also
> > unblock thread if waiting for write_space. I.e. up()+kthread_stop()
> > is racy without additional flag while kthread_stop()+up()
> > is not possible to work.
> 
> I don't see the up+kthread_stop() race you mention.

	The problem is that __down_common exits only
on waiter.up != 0 (set only by __up). Here is the race:

master_thread		stop_sync_thread
----------------------------------------
down*

			STOP MASTER
			up()
next_sync_buff()=NULL
- no buffer to send

kthread_should_stop()?
Not yet

down*()

			- some delay here

			kthread_stop()
wakeup. Is semaphore
up (waiter.up)?
No => block again
			- we are blocked in
			kthread_stop()

The race is that master_thread can block again with
down() before kthread_stop() is reached by stop_sync_thread.
If master uses down_timeout it can exit this block but
after the timeout (-ETIME) which is not very good.
down_timeout uses TASK_UNINTERRUPTIBLE state :(

> > 	I'm appending untested version with up+down but I think
> > we should use wake_up_process and schedule_timeout instead,
> > as in previous version.
> 
> OK.
> 
> I still think that using an intermediate queue is *not* the way
> to achieve reliability and congestion control, sorry.

	It seems the idea here is not to delay the packet
processing with sending sync traffic from softirq, so we use
thread and intermediate queue for sending of sync messages,
probably by using idle CPU for this. It is a compromise
for setups with overloaded CPU for packets and other
idle CPU. During our tests for some sync parameters the
sync traffic was 100-200mbit which is not a small thing to
offload to other CPUs, even by using multiple master threads.
In such cases the CPU speed is bigger problem than the
memory used for intermediate queue.

> But, you seem to persist on the idea and I don't want to block your
> developments, I just wanted to show my point and provide some ideas.
> After all, you maintain that part of the code.
> 
> Please, tell me what patch you want me to apply and I'll take it.

	I'm posting new patchset that includes new version
of this patch. I hope it should be better, it limits the
delay of queued messages, so that conn state is synced without
big delays (20ms).

Regards

--
Julian Anastasov <ja@ssi.bg>
