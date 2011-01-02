From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [*v3 PATCH 00/22] IPVS Network Name Space aware
Date: Sun, 2 Jan 2011 17:27:42 +0100
Message-ID: <201101021727.42759.hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com> <alpine.LFD.2.00.1101011421410.2559@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1101011421410.2559@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Saturday, January 01, 2011 13:27:00 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Thu, 30 Dec 2010, hans@schillstrom.com wrote:
> 
> > From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> >
> > This patch series adds network name space support to the LVS.
> >
> > REVISION
> >
> > This is version 3
> >
> > OVERVIEW
> >
> > The patch doesn't remove or add any functionality except for netns.
> > For users that don't use network name space (netns) this patch is
> > completely transparent.
> >
> > Now it's possible to run LVS in a Linux container (see lxc-tools)
> > i.e.  a light weight visualization. For example it's possible to run
> > one or several lvs on a real server in their own network name spaces.
> >> From the LVS point of view it looks like it runs on it's own machine.
> 
>  	Only some comments for two of the patches:
> 
> v3 PATCH 10/22 use ip_vs_proto_data as param
> 
>  	- Can ip_vs_protocol_timeout_change() walk
>  	proto_data_table instead of ip_vs_proto_table to avoid the
>  	__ipvs_proto_data_get call?
> 

I just forget to do that ...

> v3 PATCH 15/22 ip_vs_stats
> 
>  	- Is ustats_seq allocated with alloc_percpu?
> 
>  	Such reader sections should be changed to use tmp vars because
>  	on retry we risk to add the values multiple times. For example:
> 
>  		do {
>  			start = read_seqcount_begin(seq_count);
>  			ipvs->ctl_stats->ustats.inbytes += u->inbytes;
>  			ipvs->ctl_stats->ustats.outbytes += u->outbytes;
>  		} while (read_seqcount_retry(seq_count, start));
> 
>  	should be changed as follows:
> 
>  		u64 inbytes, outbytes;
> 
>  		do {
>  			start = read_seqcount_begin(seq_count);
>  			inbytes = u->inbytes;
>  			outbytes = u->outbytes;
>  		} while (read_seqcount_retry(seq_count, start));
>  		ipvs->ctl_stats->ustats.inbytes += inbytes;
>  		ipvs->ctl_stats->ustats.outbytes += outbytes;
> 

Ooops, that was a bug :-(

>  	Or it is better to create new struct for percpu stats,
>  	they will have their own syncp, because we can not
>  	change struct ip_vs_stats_user. syncp should be percpu
>  	because we remove locks.
> 
>  	For example:
> 
>  	struct ip_vs_cpu_stats {
>  		struct ip_vs_stats_user	ustats;
>  		struct u64_stats_sync	syncp;
>  	};
> 
>  	Then we can add this in struct netns_ipvs:
> 
>  	struct ip_vs_cpu_stats __percpu *stats;	/* Statistics */
> 
>  	without the seqcount_t * ustats_seq;
> 
>  	Then syncp does not need any initialization, it seems
>  	alloc_percpu returns zeroed area.
> 
>  	When we use percpu stats for all places (dest and svc) we
>  	can create new struct struct ip_vs_counters, so that we
>  	can reduce the memory usage from percpu data. Now stats
>  	include counters and estimated values. The estimated
>  	values should not be percpu. Then ip_vs_cpu_stats
>  	will be shorter (it is not visible to user space):
> 
>  	struct ip_vs_cpu_stats {
>  		struct ip_vs_counters	ustats;
>  		struct u64_stats_sync	syncp;
>  	};
> 
>  	For writer side in softirq context we should protect the whole
>  	section with u64 counters, for example this code:
> 

There is only two u64,  inbytes and outbytes

>  	spin_lock(&ip_vs_stats.lock);
>  	ip_vs_stats.ustats.outpkts++;
>  	ip_vs_stats.ustats.outbytes += skb->len;
>  	spin_unlock(&ip_vs_stats.lock);
> 
>  	should be changed to:
> 
>  	struct ip_vs_cpu_stats *s = this_cpu_ptr(ipvs->stats);
> 
>  	u64_stats_update_begin(&s->syncp);
>  	s->ustats.outpkts++;
>  	s->ustats.outbytes += skb->len;
>  	u64_stats_update_end(&s->syncp);
> 
>  	Readers should look in similar way, only that _bh fetching
>  	should be used only for the u64 counters because writer is in
>  	softirq context:
> 
>  	u64 inbytes, outbytes;
> 
>  	for_each_possible_cpu(i) {
>  		const struct ip_vs_cpu_stats *s = per_cpu_ptr(ipvs->stats, i);
>  		unsigned int start;
> 
>  		...
>  		do {
>  			start = u64_stats_fetch_begin_bh(&s->syncp);
>  			inbytes = s->ustats.inbytes;
>  			outbytes = s->ustats.outbytes;
>  		} while (u64_stats_fetch_retry_bh(&s->syncp, start));
>  		ipvs->ctl_stats->ustats.inbytes += inbytes;
>  		ipvs->ctl_stats->ustats.outbytes += outbytes;
>  	}
> 
>  	Then IPVS_STAT_ADD and IPVS_STAT_INC can not access
>  	the syncp. They do not look generic enough, in case we
>  	decide to use struct ip_vs_cpu_stats for dest and svc stats.
>  	I think, these macros are not needed.
>  	It is possible to have other macros for write side,
>  	for percpu stats:
> 
>  	#define IP_VS_STATS_UPDATE_BEGIN(stats)		\
>  		{ struct ip_vs_cpu_stats *s = this_cpu_ptr(stats); \
>  		u64_stats_update_begin(&s->syncp)
> 
>  	#define IP_VS_STATS_UPDATE_END()		\
>  		u64_stats_update_end(&s->syncp);	\
>  		}
> 
>  	Then usage can be:
> 
>  	IP_VS_STATS_UPDATE_BEGIN(ipvs->stats);
>  	s->ustats.outpkts++;
>  	s->ustats.outbytes += skb->len;
>  	IP_VS_STATS_UPDATE_END();
> 
>  	Then we can rename ctl_stats to total_stats or full_stats.
>  	get_stats() can be changed to ip_vs_read_cpu_stats(), it
>  	will be used to read all percpu stats as sum in the
>  	total_stats/full_stats structure or tmp space:
> 
>  	/* Get sum of percpu stats */
>  	... ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
>  		struct ip_vs_cpu_stats *stats)
>  	{
>  		...
>  		for_each_possible_cpu(i) {
>  			const struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
>  			unsigned int start;
> 
>  			if (i) {...
>  			...
>  			do {
>  				start = u64_stats_fetch_begin_bh(&s->syncp);
>  				inbytes = s->ustats.inbytes;
>  				outbytes = s->ustats.outbytes;
>  			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
>  			sum->inbytes += inbytes;
>  			sum->outbytes += outbytes;
>  		}
>  	}
> 
>  	As result, ip_vs_read_cpu_stats() will be used in
>  	estimation_timer() instead of get_stats():
> 
>  	ip_vs_read_cpu_stats(&ipvs->total_stats->ustats, ipvs->stats);
> 
>  	but also in ip_vs_stats_show()
>  	{
>  		// I hope struct ip_vs_stats_user can fit in stack:
>  		struct ip_vs_stats_user sum;
> 
>  		here we do not need to use spin_lock_bh(&ctl_stats->lock);
>  		because now the stats are lockless, estimation_timer
>  		does not use ctl_stats->lock, so we have to call
>  		ip_vs_read_cpu_stats to avoid problems with
>  		reading incorrect u64 values directly from
>  		ipvs->total_stats->ustats.
> 
>  		ip_vs_read_cpu_stats(&sum, ipvs->stats);
>  		seq_printf for sum
>  	}
> 
>  	ip_vs_read_cpu_stats can be used also in ip_vs_copy_stats()
>  	which copies values to user space and needs proper u64 reading.
>  	But it is used only for svc and dest stats which are not
>  	percpu yet.
> 
>  	Now this code does not look ok:
> 
>  	ip_vs_zero_stats(net_ipvs(net)->ctl_stats);
> 
>  	May be we need new func ip_vs_zero_percpu_stats that will
>  	reset stats for all CPUs, i.e. ipvs->stats in our case?
>  	Even if this operation is not very safe if done from
>  	user space while the softirq can modify u64 counters
>  	on another CPU.

OK, I will take a look at this when I'm back from my vacation at 20 Jan.
I guess it might be worth the work to make all the stat counters per_cpu.

My tests shows that the big "CPU cycle bandit" was the one that I made per_cpu.

> 
> 
> Happy New Year!
> 
