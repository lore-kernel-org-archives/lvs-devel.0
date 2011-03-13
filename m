From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Sun, 13 Mar 2011 11:57:32 +0100
Message-ID: <1300013852.2761.14.camel@edumazet-laptop>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
	 <1299368760-14271-4-git-send-email-horms@verge.net.au>
	 <1299402367.2758.87.camel@edumazet-laptop>
	 <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:subject:from:to:cc:in-reply-to:references
         :content-type:date:message-id:mime-version:x-mailer
         :content-transfer-encoding;
        bh=rK/ghnd/9n9KsXYAH97ozb1QpYnpaOeJV2jES3ufd2c=;
        b=B2WvvV/RcyuRQC02bR3QQ4IjR0w24zqTX5PSRNb1o4qkcKRdKY64ekbEgANbUYsDpM
         G4ws6qEtl2s8n9VJ8ML1web7pW0JAdagEiz1qjQafueT5Jjn2UWVOXmozuFv6XrmpUv6
         o/hkcjH6mAemyGKmDb7qKaRGhnW4UzuakVq0o=
In-Reply-To: <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

Le dimanche 06 mars 2011 =C3=A0 14:18 +0200, Julian Anastasov a =C3=A9c=
rit :
> 	Hello,
>=20
> On Sun, 6 Mar 2011, Eric Dumazet wrote:
>=20
> >>  	Zero the new percpu stats because we copy from there.
> >>
> >> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >> ---
> >>  net/netfilter/ipvs/ip_vs_ctl.c |   17 +++++++++++++++++
> >>  1 files changed, 17 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/i=
p_vs_ctl.c
> >> index a2a67ad..fd74527 100644
> >> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> >> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> >> @@ -715,8 +715,25 @@ static void ip_vs_trash_cleanup(struct net *n=
et)
> >>  static void
> >>  ip_vs_zero_stats(struct ip_vs_stats *stats)
> >>  {
> >> +	struct ip_vs_cpu_stats *cpustats =3D stats->cpustats;
> >> +	int i;
> >> +
> >>  	spin_lock_bh(&stats->lock);
> >>
> >> +	for_each_possible_cpu(i) {
> >> +		struct ip_vs_cpu_stats *u =3D per_cpu_ptr(cpustats, i);
> >> +		unsigned int start;
> >> +
> >> +		/* Do not pretend to be writer, it is enough to
> >> +		 * sync with writers that modify the u64 counters
> >> +		 * because under stats->lock we are the only reader.
> >> +		 */
> >> +		do {
> >> +			start =3D u64_stats_fetch_begin(&u->syncp);
> >> +			memset(&u->ustats, 0, sizeof(u->ustats));
> >> +		} while (u64_stats_fetch_retry(&u->syncp, start));
> >
> >
> > Sorry this makes no sense to me.
>=20
>  	Hm, yes, the comment is a little bit misleading.
> I fixed it below...
>=20
> > This code _is_ a writer, and hardly a hot path.
>=20
>  	Yes, the picture is as follows:
>=20
> - in 2.6.38-rc we remove the global spin lock (stats->lock)
> from packet processing which is a hot path, adding percpu
> counters instead
>=20
> - we need protection for percpu counters and for the sum
>=20
> - the chain is: interrupts increment percpu counters, the
> estimation timer reads them and creates sum every 2 seconds,
> then user context can read the sum or even to show the percpu
> counters, not to forget the zeroing of sum and counters
>=20
> The players in detail:
>=20
> - packet processing:
>  	- softirq context, hot path
>  	- increments counters by using u64_stats_update_begin and
>  	u64_stats_update_end, does not wait readers or zeroing
>  	- sum not touched, stats->lock usage removed in 2.6.38-rc
>=20
> - 2-second estimation timer:
>  	- funcs: estimation_timer()
>  	- timer context, softirq
>  	- reads percpu counters with u64_stats_fetch_begin and
>  	u64_stats_fetch_retry to sync with counter incrementing
>  	- uses spin_lock (stats->lock) to protect the written sum
>  	which is later read by user context: provides
>  	at least u64 atomicity but additionally the relation
>  	between packets and bytes
>=20
> - sum readers:
>  	- funcs: ip_vs_stats_show(), ip_vs_stats_percpu_show(),
>  	ip_vs_copy_stats(), ip_vs_genl_fill_stats()
>  	- user context, not a hot path
>  	- uses spin_lock_bh (stats->lock) for atomic reading of
>  	the sum created by estimation_timer()
>=20
> - show percpu counters:
>  	- funcs: ip_vs_stats_percpu_show()
>  	- user context, not a hot path
>  	- uses u64_stats_fetch_begin_bh and u64_stats_fetch_retry_bh
>  	to synchronize with counter incrementing
>  	- still missing: should use spin_lock_bh (stats->lock)
>  	to synchronize with ip_vs_zero_stats() that modifies
>  	percpu counters.
>=20
> - zero stats and percpu counters
>  	- funcs: ip_vs_zero_stats()
>  	- user context, not a hot path
>  	- uses spin_lock_bh (stats->lock) while modifying
>  	sum but also while zeroing percpu counters because
>  	we are a hidden writer which does not allow other
>  	percpu counter readers at the same time but we are
>  	still synchronized with percpu counter incrementing
>  	without delaying it
>=20
> To summarize, I see 2 solutions, in order of preference:
>=20
> 1. all players except packet processing should use stats->lock
> when reading/writing sum or when reading/zeroing percpu
> counters. Use u64_stats to avoid delays in incrementing.
>=20
> 2. Use seqlock instead of u64_stats if we want to treat the
> percpu counters zeroing as writer. This returns us before
> 2.6.38-rc where we used global stats->lock even for counter
> incrementing. Except that now we can use percpu seqlock
> just to register the zeroing as writer.
>=20
> > Why try to pretend its a reader and confuse people ?
> >
> > Either :
> >
> > - Another writer can modify the counters in same time, and we must
> > synchronize with them (we are a writer after all)
>=20
>  	Global mutex allows only one zeroing at a time.
> But zeroing runs in parallel with incrementing, so we
> have 2 writers for a per-CPU state. This sounds like
> above solution 2 with percpu seqlock? But it adds extra
> spin_lock in hot path, even if it is percpu. It only
> saves the spin_lock_bh while reading percpu counters in
> ip_vs_stats_percpu_show(). That is why a prefer solution 1.
>=20
> > - Another reader can read the counters in same time, and we must le=
t
> > them catch we mihjt have cleared half of their values.
>=20
>  	Yes, zeroing can run in parallel with /proc reading,
> that is why I now try to serialize all readers with the
> stats spin lock to guarantee u64 atomicity.
>=20
> > - No reader or writer can access data, no synch is needed, a pure
> > memset() is OK.
>=20
>  	Packet processing can damage the counters while we
> do memset, so we need at least u64_stats_fetch_* to sync
> with incrementing.
>=20

OK I now understand what you wanted to do.

Problem is you do synchronize your memset() with a concurrent writer bu=
t
one way only. (You detect a writer did some changes on the counters
while you memset() them), but a writer has no way to detect your writes
(could be partially committed to main memory) : It could read a
corrupted value.

I feel memory barriers are wrong and not really fixable without slowing
down the hot path.

As implied in include/linux/u64_stats_sync.h file, a "writer" should be
alone :)

One other way to handle that (and let hot path packet processing withou=
t
extra locking) would be to never memset() this data, but use a separate
"summed" value as a relative point, and substract this sum to the
current one (all this in slow path, so not a problem)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
