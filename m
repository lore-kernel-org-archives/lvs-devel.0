From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Sun, 6 Mar 2011 14:18:35 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>  <1299368760-14271-4-git-send-email-horms@verge.net.au> <1299402367.2758.87.camel@edumazet-laptop>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1299402367.2758.87.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>


 	Hello,

On Sun, 6 Mar 2011, Eric Dumazet wrote:

>>  	Zero the new percpu stats because we copy from there.
>>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>> ---
>>  net/netfilter/ipvs/ip_vs_ctl.c |   17 +++++++++++++++++
>>  1 files changed, 17 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
>> index a2a67ad..fd74527 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -715,8 +715,25 @@ static void ip_vs_trash_cleanup(struct net *net)
>>  static void
>>  ip_vs_zero_stats(struct ip_vs_stats *stats)
>>  {
>> +	struct ip_vs_cpu_stats *cpustats = stats->cpustats;
>> +	int i;
>> +
>>  	spin_lock_bh(&stats->lock);
>>
>> +	for_each_possible_cpu(i) {
>> +		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
>> +		unsigned int start;
>> +
>> +		/* Do not pretend to be writer, it is enough to
>> +		 * sync with writers that modify the u64 counters
>> +		 * because under stats->lock we are the only reader.
>> +		 */
>> +		do {
>> +			start = u64_stats_fetch_begin(&u->syncp);
>> +			memset(&u->ustats, 0, sizeof(u->ustats));
>> +		} while (u64_stats_fetch_retry(&u->syncp, start));
>
>
> Sorry this makes no sense to me.

 	Hm, yes, the comment is a little bit misleading.
I fixed it below...

> This code _is_ a writer, and hardly a hot path.

 	Yes, the picture is as follows:

- in 2.6.38-rc we remove the global spin lock (stats->lock)
from packet processing which is a hot path, adding percpu
counters instead

- we need protection for percpu counters and for the sum

- the chain is: interrupts increment percpu counters, the
estimation timer reads them and creates sum every 2 seconds,
then user context can read the sum or even to show the percpu
counters, not to forget the zeroing of sum and counters

The players in detail:

- packet processing:
 	- softirq context, hot path
 	- increments counters by using u64_stats_update_begin and
 	u64_stats_update_end, does not wait readers or zeroing
 	- sum not touched, stats->lock usage removed in 2.6.38-rc

- 2-second estimation timer:
 	- funcs: estimation_timer()
 	- timer context, softirq
 	- reads percpu counters with u64_stats_fetch_begin and
 	u64_stats_fetch_retry to sync with counter incrementing
 	- uses spin_lock (stats->lock) to protect the written sum
 	which is later read by user context: provides
 	at least u64 atomicity but additionally the relation
 	between packets and bytes

- sum readers:
 	- funcs: ip_vs_stats_show(), ip_vs_stats_percpu_show(),
 	ip_vs_copy_stats(), ip_vs_genl_fill_stats()
 	- user context, not a hot path
 	- uses spin_lock_bh (stats->lock) for atomic reading of
 	the sum created by estimation_timer()

- show percpu counters:
 	- funcs: ip_vs_stats_percpu_show()
 	- user context, not a hot path
 	- uses u64_stats_fetch_begin_bh and u64_stats_fetch_retry_bh
 	to synchronize with counter incrementing
 	- still missing: should use spin_lock_bh (stats->lock)
 	to synchronize with ip_vs_zero_stats() that modifies
 	percpu counters.

- zero stats and percpu counters
 	- funcs: ip_vs_zero_stats()
 	- user context, not a hot path
 	- uses spin_lock_bh (stats->lock) while modifying
 	sum but also while zeroing percpu counters because
 	we are a hidden writer which does not allow other
 	percpu counter readers at the same time but we are
 	still synchronized with percpu counter incrementing
 	without delaying it

To summarize, I see 2 solutions, in order of preference:

1. all players except packet processing should use stats->lock
when reading/writing sum or when reading/zeroing percpu
counters. Use u64_stats to avoid delays in incrementing.

2. Use seqlock instead of u64_stats if we want to treat the
percpu counters zeroing as writer. This returns us before
2.6.38-rc where we used global stats->lock even for counter
incrementing. Except that now we can use percpu seqlock
just to register the zeroing as writer.

> Why try to pretend its a reader and confuse people ?
>
> Either :
>
> - Another writer can modify the counters in same time, and we must
> synchronize with them (we are a writer after all)

 	Global mutex allows only one zeroing at a time.
But zeroing runs in parallel with incrementing, so we
have 2 writers for a per-CPU state. This sounds like
above solution 2 with percpu seqlock? But it adds extra
spin_lock in hot path, even if it is percpu. It only
saves the spin_lock_bh while reading percpu counters in
ip_vs_stats_percpu_show(). That is why a prefer solution 1.

> - Another reader can read the counters in same time, and we must let
> them catch we mihjt have cleared half of their values.

 	Yes, zeroing can run in parallel with /proc reading,
that is why I now try to serialize all readers with the
stats spin lock to guarantee u64 atomicity.

> - No reader or writer can access data, no synch is needed, a pure
> memset() is OK.

 	Packet processing can damage the counters while we
do memset, so we need at least u64_stats_fetch_* to sync
with incrementing.

>> +	}
>> +
>>  	memset(&stats->ustats, 0, sizeof(stats->ustats));
>>  	ip_vs_zero_estimator(stats);

 	So, here is solution 1 fully implemented:

==============

 	Zero the new percpu stats because we copy from there.
Use the stats spin lock to synchronize the percpu zeroing with
the percpu reading, both in user context and not in a hot path.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-06 13:39:59.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-06 13:44:56.108275455 +0200
@@ -713,8 +713,25 @@ static void ip_vs_trash_cleanup(struct n
  static void
  ip_vs_zero_stats(struct ip_vs_stats *stats)
  {
+	struct ip_vs_cpu_stats *cpustats = stats->cpustats;
+	int i;
+
  	spin_lock_bh(&stats->lock);

+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
+		unsigned int start;
+
+		/* Do not pretend to be writer, it is enough to
+		 * sync with writers that modify the u64 counters
+		 * because under stats->lock there are no other readers
+		 */
+		do {
+			start = u64_stats_fetch_begin(&u->syncp);
+			memset(&u->ustats, 0, sizeof(u->ustats));
+		} while (u64_stats_fetch_retry(&u->syncp, start));
+	}
+
  	memset(&stats->ustats, 0, sizeof(stats->ustats));
  	ip_vs_zero_estimator(stats);

@@ -2015,16 +2032,19 @@ static int ip_vs_stats_percpu_show(struc
  	seq_printf(seq,
  		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");

+	/* Use spin lock early to synchronize with percpu zeroing */
+	spin_lock_bh(&tot_stats->lock);
+
  	for_each_possible_cpu(i) {
  		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
  		unsigned int start;
  		__u64 inbytes, outbytes;

  		do {
-			start = u64_stats_fetch_begin_bh(&u->syncp);
+			start = u64_stats_fetch_begin(&u->syncp);
  			inbytes = u->ustats.inbytes;
  			outbytes = u->ustats.outbytes;
-		} while (u64_stats_fetch_retry_bh(&u->syncp, start));
+		} while (u64_stats_fetch_retry(&u->syncp, start));

  		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
  			   i, u->ustats.conns, u->ustats.inpkts,
@@ -2032,7 +2052,6 @@ static int ip_vs_stats_percpu_show(struc
  			   (__u64)outbytes);
  	}

-	spin_lock_bh(&tot_stats->lock);
  	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n",
  		   tot_stats->ustats.conns, tot_stats->ustats.inpkts,
  		   tot_stats->ustats.outpkts,
