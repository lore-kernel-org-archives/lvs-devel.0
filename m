From: Julian Anastasov <ja@ssi.bg>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH_0=2F3=5D_netfilter=3A_ipvs=3A=C2=A0Add_Maglev_consistent_hashing_scheduler?=
Date: Sun, 17 Dec 2017 13:47:55 +0200 (EET)
Message-ID: <alpine.LFD.2.20.1712171312360.30653@ja.home.ssi.bg>
References: <cover.1512888407.git.inju.song@navercorp.com> <alpine.LFD.2.20.1712101547210.4343@ja.home.ssi.bg> <20171217084000.GA9802@centos7.nhncorp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463811672-574197399-1513511275=:30653"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20171217084000.GA9802@centos7.nhncorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Inju Song <inju.song@navercorp.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-574197399-1513511275=:30653
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Sun, 17 Dec 2017, Inju Song wrote:

> On Sun, Dec 10, 2017 at 03:53:21PM +0200, Julian Anastasov wrote:
> > 
> 	yes. I will make next maglev patch as single but maybe
> there will be some patchsets for v2 If it needed(ie. add some
> config to Kconfig).

	Yes, Kconfig, Makefile should be in same patch.

> > - .upd_dest: changing weight to 0 should be ignored
> > but if we want to allow changing the weight from/to non-0 values
> > then we should save in array the latest non-0 weights for the
> > current dests. As it is difficult to track the dest deletions
> > may be we can add last_weight in struct ip_vs_dest. Then MH
> > will work with dest->last_weight.
> > 
> 
> 	I think that It needs to allow changing the weight from/to
> non-0 values so I will add to allow only if is non-0 values.

	Yep, then we should catch .upd_dest and to use last_weight.
In fact, adding last_weight to IPVS core should be separate
patch to apply before the MH patch.

> > - To avoid waste of memory due to kmalloc's orders we can use the
> > previous prime number, 65521, others can be 32749, 16381, 8191,
> > 4093, 2039, 1021, some no so useful values due to page size:
> > 
> > 	- 509 (2KB with 4-byte ptr, 4KB for 8-byte ptr)
> > 	- 251 (1KB/2KB of 4KB page)
> > 
> > 	With such primes the table should be a separate allocation.
> > 
> 
> 	I agress this. To avoid waste of memory and provide various
> prime number, it is saved with static array like below.
> 
> // available prime number
> static int PRIMES[] =

	Do not use upper case for var names...

> { 1021, 2039, 4093, 8191, 16381, 32749, 65521, 131071};
> 
> 	I want to proivde larger space then 65521, so add 131071 to
> last index of primes. If large value is not so fatal I think it is
> better in case of disruption of consistent hashing. I think It is
> helpful for users who have high performance machine and want more
> minimal disruption when destinations are add/deleted.

	OK, may be 131071 can help if using hundreds of servers...

> > - another possible issue is that users can use crazy values for
> > weight, for example, 64 and 127. In such case even the gcd()
> > function can not help enough for something that would be 1:2
> > relation. But we can warn users to use as small as possible
> > values for weights. If needed, we can rshift the weights, so
> > that only the highest 5-6 bits of the largest weight are considered.
> > I.e. if we find the largest weight is 2000 we see that 2000
> > occupies 11 bits, so we decide to use the highest 6 bits and
> > rshift with 5 (11-6) all weights. All resulting weights will
> > fit in 6 bits.
> > 
> 
> 	I agree that huge weight values are considerd and rshift is
> good idea I think.
> 	To handle it, both rshift and last_weight are considerd. I
> wrote my opinion below.
> 
> > - ip_vs_mh_populate allocates IP_VS_MH_TAB_SIZE ints for next[] but
> > later next[i] can go up to num_dests which can be above the
> > IP_VS_MH_TAB_SIZE. We should use IP_VS_MH_TAB_SIZE as M and
> > Kconfig should show the above prime numbers as options. Or
> > we can configure IP_VS_MH_TAB_BITS as 8..16 and to use it as
> > index to get the actual prime value from array:
> > 
> > static int primes[] = { 251, ... 65521 };
> > 
> 
> 	I will add IP_VS_MH_BITS and help message in Kconfig to able to
> configure it like below.
> 
> 	config IP_VS_MH_TAB_INDEX
> 		range 8..16

	OK. May be 8 .. 17 if we include 131071

> 		default 12
> 		// and some helpful messages.
> 
> and
> 
> 	#define IP_VS_MH_TAB_INDEX	CONFIG_IP_VS_MH_TAB_INDEX - 8
> 	#define IP_VS_MH_TAB_SIZE       PRIMES[IP_VS_MH_TAB_INDEX]
> 
> in header of ip_vs_mh.c

	OK

> > - we can avoid large allocations for s->permutation(N*M),
> > instead we can use:
> > 
> > struct ip_vs_mh_dest_setup {
> > 	int		offset;		/* Starting offset */
> > 	int		skip;		/* skip */
> > 	int		turns;		/* weight / gcd() */
> > 	int		perm;		/* next_offset */
> > };
> > 
> > struct ip_vs_mh_dest_setup *dests;	/* 1..num_dests */
> > 
> > 	dests should be allocated (-ENOMEM) and freed on
> > every ip_vs_mh_reassign.
> > 
> > 	Initially, we should calculate .offset and .skip for all
> > dests. Then we should set dests[i].perm to dests[i].offset.
> > When adding weight to the picture, we can calculate greatest
> > common divisor with the gcd() function and then to use it for
> > calculating 'turns' per dest. ip_vs_wrr_gcd_weight() is a good
> > example how to get gcd() among all dests.
> > 
> > 	When populating table:
> > 
> > 	The operation 'c = permutation[i][next[i]];' becomes
> > 
> > 	c = dests[i].perm;
> > 
> > The operation 'next[i] = next[i] + 1;' becomes:
> > 
> > 	/* Add skip, mod M */
> > 	dests[i].perm += dests[i].skip;
> > 	if (dests[i].perm >= M)
> > 		dests[i].perm -= M;
> > 
> > 	This should be cheaper than '% 65537'. And it is correct
> > because:
> > 	1. offset is 0 .. M-1
> > 	2. skip is 1 .. M-1
> > 
> 
> 	This is very good idea I think. It shoud be used so I will
> change ip_vs_mh_permutate and ip_vs_mh_populate to avoid allocating
> s->permutation.
> 
> 	And re-configuring weight of dests maybe have some flow in
> ip_vs_init_svc and ip_vs_mh_ dest_changed like below.
> 
>     1. check max weight, decide value of bits range for rshift
>        and set last weigit to dests->last_weight with rshift.
>        - last_weight should be set only when it is changed.
>        - If weight is zero, skip to set last_weight

	Yes, but as I said last_weight change in ip_vs_ctl.c
should be a separate patch, MH will just use last_weight for
turns. If last_weight is 0 (server added with weight=0), we
should ignore the server for MH table.

>     2. get gcd with all dests
>        - maybe gcd() will use dest->last_weight value not dest->weight. 

	Yep

>     3. set offset, skip and turns in ip_vs_mh_permutate
> 
>        dests[i].tunrs = dest->last_weight / gcd;

	Yep. But we have to be careful, gcd is usually >= 1 but
if all servers are with last_weight=0 then we should avoid
divizion by zero and should populate the table with NULLs.
ip_vs_mh_gcd_weight will give a clue if there is a server
with last_weight>0, i.e. it should return 0 if all servers
are with last_weight=0.

>     4. use relative weight in ip_vs_mh_populate
> 
>        if (++dt_count >= dests[i].turns) {
>        		p = p -> next;
>        		dt_count = 0;
>        		i++;
>        }

	Yep

> 
> 	and I think that the configuring weight flow need to be protected
> by spin_lock.

	locks are not needed, configuration is serialzed by
using __ip_vs_mutex, the configuration methods run concurrently
only with packet processing and we use RCU for the table.

> > - Lets do not put limit for number of dests. We can add
> > only such check:
> > 
> > 	if (svc->num_dest > IP_VS_MH_LOOKUP_SIZE)
> > 		return -EINVAL;
> > 
> 
> 	yes. I will add such check.
> 
> > - IP_VS_MH_LOOKUP_SIZE should be replaced with IP_VS_MH_TAB_SIZE
> > 
> 
> 	It is will be replaced with IP_VS_MH_TAB_SIZE.
> 
> > 	Note that I only check the implementation for problems,
> > I don't run any tests for the algorithm. I hope you have some
> > test program that pushes bunch of random IP[:PORT] values via the
> > algorithm and the result is correct distribution based on the relative
> > weights.
> > 
> 
> 	I alredy have some a kind of test program with destination as
> container and always run it when I add some features and make patches.
> so I will attach some result about correct distribtion at next patch
> if needed.

	As you wish, it is enough to know that the algorithm
was tested to work as expected.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-574197399-1513511275=:30653--
