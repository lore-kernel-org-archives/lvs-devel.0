From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/3] IPVS: add wlib & wlip schedulers
Date: Tue, 27 Jan 2015 10:36:34 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501271008210.4961@ja.home.ssi.bg>
References: <Pine.LNX.4.44.0501260832210.17893-100000@nacho.alt.net> <Pine.LNX.4.61.0502010007060.1148@penguin.linux-vs.org> <Pine.LNX.4.64.1501172217420.8217@nacho.alt.net> <alpine.LFD.2.11.1501192342190.2687@ja.home.ssi.bg> <Pine.LNX.4.64.1501200137310.8217@nacho.alt.net>
 <alpine.LFD.2.11.1501222308060.2572@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1501222308060.2572@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Caputo <ccaputo@alt.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Fri, 23 Jan 2015, Julian Anastasov wrote:

> On Tue, 20 Jan 2015, Chris Caputo wrote:
> 
> > My application consists of incoming TCP streams being load balanced to 
> > servers which receive the feeds. These are long lived multi-gigabyte 
> > streams, and so I believe the estimator's 2-second timer is fine. As an 
> > example:
> > 
> > # cat /proc/net/ip_vs_stats
> >    Total Incoming Outgoing         Incoming         Outgoing
> >    Conns  Packets  Packets            Bytes            Bytes
> >      9AB  58B7C17        0      1237CA2C325                0
> > 
> >  Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
> >        1     387C        0          B16C4AE                0
> 
> 	Not sure, may be everything here should be u64 because
> we have shifted values. I'll need some days to investigate
> this issue...

	For now I don't see hope in using schedulers that rely
on IPVS byte/packet stats, due to the slow update (2 seconds).
If we reduce this period we can cause performance problems to
other users.

Every *-LEAST-* (eg. LC, WLC) algorithm needs actual information
to take decision on every new connection. OTOH, all *-ROUND-ROBIN-*
algorithms (RR, WRR) use information (weights) from user space,
by this way kernel performs as expected.

	Currently, LC/WLC use feedback from the 3-way TCP handshake,
see ip_vs_dest_conn_overhead() where the established connections
have large preference. Such feedback from real servers is delayed
usually with microseconds, up to milliseconds. More time if
depends on clients.

	The proposed schedulers have round-robin function but
only among least loaded servers, so it is not dominant
and we suffer from slow feedback from the estimator.

	For load information that is not present in kernel
an user space daemon is needed to determine weights to use
with WRR. It can take actual stats from real server, for
example, it can take into account non-IPVS traffic.

	As alternative, it is possible to implement some new svc
method that can be called for every packet, for example, in
ip_vs_in_stats(). It does not look fatal to add some fields in
struct ip_vs_dest that only specific schedulers will update,
for example, byte/packet counters. Of course, the spin_locks
the scheduler must use will suffer on many CPUs. Such info can
be also attached as allocated structure in RCU pointer
dest->sched_info where data and corresponding methods can be
stored. It will need careful RCU-kind of update, especially when
scheduler is updated in svc. If you think such idea can work
we can discuss the RCU and scheduler changes that are needed.
The proposed schedulers have to implement counters, their
own estimator and WRR function.

	Another variant can be to extend WRR with some
support for automatic dynamic-weight update depending on 
parameters: -s wrr --sched-flags {wlip,wlib,...}

	or using new option --sched-param that can also
provide info for wrr estimator, etc. In any case, the
extended WRR scheduler will need above support to check
every packet.

Regards

--
Julian Anastasov <ja@ssi.bg>
