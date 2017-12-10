From: Julian Anastasov <ja@ssi.bg>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH_0=2F3=5D_netfilter=3A_ipvs=3A=C2=A0Add_Maglev_consistent_hashing_scheduler?=
Date: Sun, 10 Dec 2017 15:53:21 +0200 (EET)
Message-ID: <alpine.LFD.2.20.1712101547210.4343@ja.home.ssi.bg>
References: <cover.1512888407.git.inju.song@navercorp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463811672-1733698953-1512914002=:4343"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1512888407.git.inju.song@navercorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Inju Song <inju.song@navercorp.com>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1733698953-1512914002=:4343
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Sun, 10 Dec 2017, Inju Song wrote:

> Implements the Google's Maglev hashing algorithm as a IPVS scheduler.
> Basically it provides consistent hashing but offers some special
> features about disruption and load balancing.
> 
> Seel also: [3.4 Consistent Hasing]
> in https://static.googleusercontent.com/media/research.google.com/ko//pubs/archive/44824.pdf
> 
> V2: Fix some methods and add features based on Julian's advice.

	It is good to see incremental changes but at the final
step it is better to see single patch with a well-formed subject,
with new version, eg:

[PATCHv2 nf-next] ipvs: Add Maglev consistent hashing

where the used tree is net-next, nf-next or ipvs-next.

	Few notes:

- .upd_dest: changing weight to 0 should be ignored
but if we want to allow changing the weight from/to non-0 values
then we should save in array the latest non-0 weights for the
current dests. As it is difficult to track the dest deletions
may be we can add last_weight in struct ip_vs_dest. Then MH
will work with dest->last_weight.

- it is good to have configurable table size, just like
IP_VS_SH_TAB_BITS in Kconfig. You can even use 5-6 prime numbers
like 65537 and below, if needed. Large value is not so fatal,
table is updated only when servers are added (at start), so
if one uses little differences in weights and small number of
servers the small prime number can reduce the cache usage.
As we know, the table should be able to map all possible dests
based on relative weights. To give few examples:

	- for 2 servers with same weight 5 we need 2 table entries,
	one per server

	- for 2 servers with weight 5 and 10 we need 3 entries,
	1 for first server and 2 for the second server

	- But in practice we can run hundreds of servers with
	relative weight difference 1-64 if number of CPUs are
	considered, for example.

- To avoid waste of memory due to kmalloc's orders we can use the
previous prime number, 65521, others can be 32749, 16381, 8191,
4093, 2039, 1021, some no so useful values due to page size:

	- 509 (2KB with 4-byte ptr, 4KB for 8-byte ptr)
	- 251 (1KB/2KB of 4KB page)

	With such primes the table should be a separate allocation.

- when table has constant size, it can be part of the state,
as result, it will be allocated only once by ip_vs_mh_init_svc
where any errors are handled properly, any reallocations in
ip_vs_mh_reassign are unwanted because currently the errors are
ignored by the IPVS core (add_dest/upd_dest/del_dest), so
we should keep the s->permutation[] allocated. But as it is too
large, see below how to avoid s->permutation[]...

- no need to use "inline" for ip_vs_mh_permutate and ip_vs_mh_populate,
they are used only on configuration time, better the compiler to decide

- another possible issue is that users can use crazy values for
weight, for example, 64 and 127. In such case even the gcd()
function can not help enough for something that would be 1:2
relation. But we can warn users to use as small as possible
values for weights. If needed, we can rshift the weights, so
that only the highest 5-6 bits of the largest weight are considered.
I.e. if we find the largest weight is 2000 we see that 2000
occupies 11 bits, so we decide to use the highest 6 bits and
rshift with 5 (11-6) all weights. All resulting weights will
fit in 6 bits.

- ip_vs_mh_populate allocates IP_VS_MH_TAB_SIZE ints for next[] but
later next[i] can go up to num_dests which can be above the
IP_VS_MH_TAB_SIZE. We should use IP_VS_MH_TAB_SIZE as M and
Kconfig should show the above prime numbers as options. Or
we can configure IP_VS_MH_TAB_BITS as 8..16 and to use it as
index to get the actual prime value from array:

static int primes[] = { 251, ... 65521 };

- we can avoid large allocations for s->permutation(N*M),
instead we can use:

struct ip_vs_mh_dest_setup {
	int		offset;		/* Starting offset */
	int		skip;		/* skip */
	int		turns;		/* weight / gcd() */
	int		perm;		/* next_offset */
};

struct ip_vs_mh_dest_setup *dests;	/* 1..num_dests */

	dests should be allocated (-ENOMEM) and freed on
every ip_vs_mh_reassign.

	Initially, we should calculate .offset and .skip for all
dests. Then we should set dests[i].perm to dests[i].offset.
When adding weight to the picture, we can calculate greatest
common divisor with the gcd() function and then to use it for
calculating 'turns' per dest. ip_vs_wrr_gcd_weight() is a good
example how to get gcd() among all dests.

	When populating table:

	The operation 'c = permutation[i][next[i]];' becomes

	c = dests[i].perm;

The operation 'next[i] = next[i] + 1;' becomes:

	/* Add skip, mod M */
	dests[i].perm += dests[i].skip;
	if (dests[i].perm >= M)
		dests[i].perm -= M;

	This should be cheaper than '% 65537'. And it is correct
because:
	1. offset is 0 .. M-1
	2. skip is 1 .. M-1

- Lets do not put limit for number of dests. We can add
only such check:

	if (svc->num_dest > IP_VS_MH_LOOKUP_SIZE)
		return -EINVAL;

- IP_VS_MH_LOOKUP_SIZE should be replaced with IP_VS_MH_TAB_SIZE

	Note that I only check the implementation for problems,
I don't run any tests for the algorithm. I hope you have some
test program that pushes bunch of random IP[:PORT] values via the
algorithm and the result is correct distribution based on the relative
weights.

> Inju Song (3):
>   netfilter: ipvs: handle memory allocation fail in mh scheduler.
>   netfilter: ipvs: release refcnt and improve ip_vs_mh_reassign()
>   netfilter: ipvs: change method to fill lookup table based on weight.
> 
>  net/netfilter/ipvs/ip_vs_mh.c | 147 +++++++++++++++++++++++++++++-------------
>  1 file changed, 101 insertions(+), 46 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1733698953-1512914002=:4343--
