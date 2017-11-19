From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: Add Maglev consistent hashing
 scheduler
Date: Sun, 19 Nov 2017 18:04:35 +0200 (EET)
Message-ID: <alpine.LFD.2.20.1711191748110.2409@ja.home.ssi.bg>
References: <20171119063507.GA9306@centos7.nhncorp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463811672-1716951281-1511107476=:2409"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20171119063507.GA9306@centos7.nhncorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Inju Song <inju.song@navercorp.com>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, =?UTF-8?Q?=C2=A0Simon_Horman?= <horms@verge.net.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1716951281-1511107476=:2409
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Sun, 19 Nov 2017, Inju Song wrote:

> Implements the Google's Maglev hashing algorithm as a IPVS scheduler.
> 
> Basically it provides consistent hashing but offers some special
> features about disruption and load balancing.
> 
>   1) minimal disruption: when the set of destinations changes,
>      a connection will likely be sent to the same destination
>      as it was before.
> 
>   2) load balancing: each destination will receive an almost
>      equal number of connections.
> 
> Seel also for detail: [3.4 Consistent Hasing] in
> https://static.googleusercontent.com/media/research.google.com/ko//pubs/archive/44824.pdf

	 I see that the PDF shows implementation only for servers
with same weight. It would be better to see implementation that
considers dest->weight.

> Signed-off-by: Inju Song <inju.song@navercorp.com>
> ---
>  net/netfilter/ipvs/ip_vs_mh.c | 402 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 402 insertions(+)
>  create mode 100644 net/netfilter/ipvs/ip_vs_mh.c
> 
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> new file mode 100644
> index 0000000..534a9f5
> --- /dev/null
> +++ b/net/netfilter/ipvs/ip_vs_mh.c

> +static inline int
> +ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc,
> +		  unsigned int **permutation)
> +{
> +	int i;
> +	unsigned int *next;
> +	struct ip_vs_mh_lookup *entry, *l;
> +	struct list_head *p;
> +	struct ip_vs_dest *dest;
> +	int dcnt;
> +	unsigned int n, c;
> +
> +	dcnt = svc->num_dests;

	While calling del_dest svc->num_dests can be 0, this should
be considered in ip_vs_mh_permutate and ip_vs_mh_populate. We should
set the table with NULLs in such case.

> +	next = kcalloc(dcnt, sizeof(unsigned int), GFP_KERNEL);
> +	entry = kcalloc(IP_VS_MH_LOOKUP_SIZE, sizeof(*entry),
> +			GFP_KERNEL);

	It is current drawback that add_dest, upd_dest and del_dest
are considered as non-failing methods, we can not fail the operation
if memory allocation fails, for example. This is bad for add_dest,
not so for upd_dest and del_dest. In this regard, I think, the MH
scheduler should not crash if allocation fails.

> +/* Assign all the hash buckets of the specified table with the service.
> + */
> +static int
> +ip_vs_mh_reassign(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
> +{
> +	int dcnt;
> +	unsigned int **permutation;
> +
> +	/* flush all the hash entry before assigning mh entry */
> +	ip_vs_mh_flush(s);

	ip_vs_mh_reassign should not call ip_vs_mh_flush.
ip_vs_mh_populate while copying the temp table to s->lookup[]
should put the refcnt to old dests (as in SH:ip_vs_sh_reassign)
and then to assign new value. NULL should be assigned if
svc->num_dests = 0.

> +/* IPVS MH Scheduler structure */
> +static struct ip_vs_scheduler ip_vs_mh_scheduler = {
> +	.name =			"mh",
> +	.refcnt =		ATOMIC_INIT(0),
> +	.module =		THIS_MODULE,
> +	.n_list	 =		LIST_HEAD_INIT(ip_vs_mh_scheduler.n_list),
> +	.init_service =		ip_vs_mh_init_svc,
> +	.done_service =		ip_vs_mh_done_svc,
> +	.add_dest =		ip_vs_mh_dest_changed,
> +	.del_dest =		ip_vs_mh_dest_changed,
> +	.upd_dest =		ip_vs_mh_dest_changed,

	As upd_dest is called only when weight changes, the SH and MH
schedulers should not handle this method. Their goal is to fill
the table with all added dests by ignoring health state (it is
considered only on dest selection).

	I guess, the correct configuration for SH and MH would be:

1.1 Add all dests with specific weight, so that the schedulers can
fill their table based on the weights.
1.2 Set weight to 0 for all servers that are not healthy. SH and MH
should ignore these configuration events.

after the initial configuration:

2. Traffic will ignore non-healthy servers, fallbacks to healthy ones.
3. If other servers become unavailable, change their weight to 0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1716951281-1511107476=:2409--
