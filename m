From: Inju Song <inju.song@navercorp.com>
Subject: Re: [PATCH 0/3] =?iso-8859-1?Q?netfilter?=
 =?iso-8859-1?B?OiBpcHZzOqBBZGQ=?= Maglev consistent hashing scheduler
Date: Mon, 18 Dec 2017 14:09:35 +0900
Message-ID: <20171218050934.GA5113@centos7.nhncorp.com>
References: <cover.1512888407.git.inju.song@navercorp.com>
 <alpine.LFD.2.20.1712101547210.4343@ja.home.ssi.bg>
 <20171217084000.GA9802@centos7.nhncorp.com>
 <alpine.LFD.2.20.1712171312360.30653@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=navercorp.com;
        s=s20171120; t=1513573779;
        bh=jlrsGPrWJ2RpwkTYIEDHhJ5LgmdtZYS7Er/djFosnsY=;
        h=Date:From:To:Subject:Message-ID;
        b=nCqqMU3cv5o//3f2lg5v4l6esTx/ic7yHR1aFJFbR2K4zlu155PpeTOR1/D5N6cUa
         VNzACmt5FjmzXFmtMMvIp1s58fWL/lVNzFzQ0q0t8/YAzuYB1FablMjrsFz2SvIRLp
         4UnxwzJ5v6BEC+RoQvNr3JlT4G4pNFpSaysbTvPFJ5aNyyk4/OFZtvR0EhyJNEG8HS
         txbNT7vzPQrHKKtYvYP8Bb1/098zR2v1Or7XESXrnoSzdKhmq3o18PkaknUvrLbf/a
         GCXtZrYwW1ofuxMFLik9WAeQ7/ikmpP7GKm9OICFbtxmUgdG9DBNPlC+Z8A2j6TjRy
         aOhUKF+QyxcfQ==
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1712171312360.30653@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org


	Hello,
	Thanks for your comments. I will send patchsets for v2 of MH.

On Sun, Dec 17, 2017 at 01:47:55PM +0200, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Sun, 17 Dec 2017, Inju Song wrote:
>=20
> > On Sun, Dec 10, 2017 at 03:53:21PM +0200, Julian Anastasov wrote:
> > >=20
> > 	yes. I will make next maglev patch as single but maybe
> > there will be some patchsets for v2 If it needed(ie. add some
> > config to Kconfig).
>=20
> 	Yes, Kconfig, Makefile should be in same patch.
>=20
> > > - .upd_dest: changing weight to 0 should be ignored
> > > but if we want to allow changing the weight from/to non-0 values
> > > then we should save in array the latest non-0 weights for the
> > > current dests. As it is difficult to track the dest deletions
> > > may be we can add last_weight in struct ip_vs_dest. Then MH
> > > will work with dest->last_weight.
> > >=20
> >=20
> > 	I think that It needs to allow=A0changing the weight from/to
> > non-0 values so I will add to allow only if is non-0 values.
>=20
> 	Yep, then we should catch .upd_dest and to use last_weight.
> In fact, adding last_weight to IPVS core should be separate
> patch to apply before the MH patch.
>=20

	Ok. So should I send patch about adding last_weight to IPVS core
before appling the MH patch? Then I will.

> > > - To avoid waste of memory due to kmalloc's orders we can use the
> > > previous prime number, 65521, others can be 32749, 16381, 8191,
> > > 4093, 2039, 1021, some no so useful values due to page size:
> > >=20
> > > 	- 509 (2KB with 4-byte ptr, 4KB for 8-byte ptr)
> > > 	- 251 (1KB/2KB of 4KB page)
> > >=20
> > > 	With such primes the table should be a separate allocation.
> > >=20
> >=20
> > 	I agress this. To avoid waste of memory and provide=A0various
> > prime number, it is saved with static array like below.
> >=20
> > //=A0available prime number
> > static int PRIMES[] =3D
>=20
> 	Do not use upper case for var names...
>=20
> > {=A01021,=A02039,=A04093,=A08191,=A016381,=A032749,=A065521,=A0131071};
> >=20
> > 	I want to proivde larger space then=A065521, so add=A0131071 to
> > last index of primes. If large value is not so fatal I think it is
> > better in case of disruption of consistent hashing. I think It is
> > helpful for users who have high performance machine and want more
> > minimal disruption when destinations are add/deleted.
>=20
> 	OK, may be 131071 can help if using hundreds of servers...
>=20
> > > - another possible issue is that users can use crazy values for
> > > weight, for example, 64 and 127. In such case even the gcd()
> > > function can not help enough for something that would be 1:2
> > > relation. But we can warn users to use as small as possible
> > > values for weights. If needed, we can rshift the weights, so
> > > that only the highest 5-6 bits of the largest weight are considered.
> > > I.e. if we find the largest weight is 2000 we see that 2000
> > > occupies 11 bits, so we decide to use the highest 6 bits and
> > > rshift with 5 (11-6) all weights. All resulting weights will
> > > fit in 6 bits.
> > >=20
> >=20
> > 	I agree that huge weight values are considerd and rshift is
> > good idea I think.
> > 	To handle it, both rshift and last_weight are considerd. I
> > wrote my opinion below.
> >=20
> > > - ip_vs_mh_populate allocates IP_VS_MH_TAB_SIZE ints for next[] but
> > > later next[i] can go up to num_dests which can be above the
> > > IP_VS_MH_TAB_SIZE. We should use IP_VS_MH_TAB_SIZE as M and
> > > Kconfig should show the above prime numbers as options. Or
> > > we can configure IP_VS_MH_TAB_BITS as 8..16 and to use it as
> > > index to get the actual prime value from array:
> > >=20
> > > static int primes[] =3D { 251, ... 65521 };
> > >=20
> >=20
> > 	I will add IP_VS_MH_BITS and help message in Kconfig to able to
> > configure it like below.
> >=20
> > 	config IP_VS_MH_TAB_INDEX
> > 		range 8..16
>=20
> 	OK. May be 8 .. 17 if we include 131071
>=20
> > 		default 12
> > 		// and some helpful messages.
> >=20
> > and
> >=20
> > 	#define IP_VS_MH_TAB_INDEX	CONFIG_IP_VS_MH_TAB_INDEX - 8
> > 	#define IP_VS_MH_TAB_SIZE=A0=A0=A0=A0=A0=A0=A0PRIMES[IP_VS_MH_TAB_INDE=
X]
> >=20
> > in header of ip_vs_mh.c
>=20
> 	OK
>=20
> > > - we can avoid large allocations for s->permutation(N*M),
> > > instead we can use:
> > >=20
> > > struct ip_vs_mh_dest_setup {
> > > 	int		offset;		/* Starting offset */
> > > 	int		skip;		/* skip */
> > > 	int		turns;		/* weight / gcd() */
> > > 	int		perm;		/* next_offset */
> > > };
> > >=20
> > > struct ip_vs_mh_dest_setup *dests;	/* 1..num_dests */
> > >=20
> > > 	dests should be allocated (-ENOMEM) and freed on
> > > every ip_vs_mh_reassign.
> > >=20
> > > 	Initially, we should calculate .offset and .skip for all
> > > dests. Then we should set dests[i].perm to dests[i].offset.
> > > When adding weight to the picture, we can calculate greatest
> > > common divisor with the gcd() function and then to use it for
> > > calculating 'turns' per dest. ip_vs_wrr_gcd_weight() is a good
> > > example how to get gcd() among all dests.
> > >=20
> > > 	When populating table:
> > >=20
> > > 	The operation 'c =3D permutation[i][next[i]];' becomes
> > >=20
> > > 	c =3D dests[i].perm;
> > >=20
> > > The operation 'next[i] =3D next[i] + 1;' becomes:
> > >=20
> > > 	/* Add skip, mod M */
> > > 	dests[i].perm +=3D dests[i].skip;
> > > 	if (dests[i].perm >=3D M)
> > > 		dests[i].perm -=3D M;
> > >=20
> > > 	This should be cheaper than '% 65537'. And it is correct
> > > because:
> > > 	1. offset is 0 .. M-1
> > > 	2. skip is 1 .. M-1
> > >=20
> >=20
> > 	This is very good idea I think. It shoud be used so I will
> > change ip_vs_mh_permutate and ip_vs_mh_populate to avoid allocating
> > s->permutation.
> >=20
> > 	And re-configuring weight of dests maybe have some flow in
> > ip_vs_init_svc and ip_vs_mh_ dest_changed like below.
> >=20
> >     1. check max weight, decide value of bits range for rshift
> >        and set last weigit to dests->last_weight with rshift.
> > =A0 =A0    - last_weight should be set only when it is changed.
> > =A0 =A0    - If weight is zero, skip to set last_weight
>=20
> 	Yes, but as I said last_weight change in ip_vs_ctl.c
> should be a separate patch, MH will just use last_weight for
> turns. If last_weight is 0 (server added with weight=3D0), we
> should ignore the server for MH table.
>=20
> >     2. get gcd with all dests
> >        - maybe gcd() will use dest->last_weight value not dest->weight.=
=20
>=20
> 	Yep
>=20
> >     3. set offset, skip and turns in ip_vs_mh_permutate
> >=20
> >        dests[i].tunrs =3D dest->last_weight / gcd;
>=20
> 	Yep. But we have to be careful, gcd is usually >=3D 1 but
> if all servers are with last_weight=3D0 then we should avoid
> divizion by zero and should populate the table with NULLs.
> ip_vs_mh_gcd_weight will give a clue if there is a server
> with last_weight>0, i.e. it should return 0 if all servers
> are with last_weight=3D0.
>

	Of course. These case should be handled. Thanks for your
advice.

> >     4. use relative weight in ip_vs_mh_populate
> >=20
> >        if (++dt_count >=3D dests[i].turns) {
> >     =A0 =A0		p =3D p -> next;
> >     =A0=A0 		dt_count =3D 0;
> >     =A0=A0 		i++;
> >     =A0=A0 }
>=20
> 	Yep
>=20
> >=20
> > 	and I think that the configuring weight flow need to be protected
> > by spin_lock.
>=20
> 	locks are not needed, configuration is serialzed by
> using __ip_vs_mutex, the configuration methods run concurrently
> only with packet processing and we use RCU for the table.
>=20

	Ok. then I will use RCU for the mh_setup table.=20

> > > - Lets do not put limit for number of dests. We can add
> > > only such check:
> > >=20
> > > 	if (svc->num_dest > IP_VS_MH_LOOKUP_SIZE)
> > > 		return -EINVAL;
> > >=20
> >=20
> > 	yes. I will add such check.
> >=20
> > > - IP_VS_MH_LOOKUP_SIZE should be replaced with IP_VS_MH_TAB_SIZE
> > >=20
> >=20
> > 	It is will be replaced with=A0IP_VS_MH_TAB_SIZE.
> >=20
> > > 	Note that I only check the implementation for problems,
> > > I don't run any tests for the algorithm. I hope you have some
> > > test program that pushes bunch of random IP[:PORT] values via the
> > > algorithm and the result is correct distribution based on the relative
> > > weights.
> > >=20
> >=20
> > 	I alredy have some a kind of test program with destination as
> > container and always run it when I add some features and make patches.
> > so I will attach some result about correct distribtion at next patch
> > if needed.
>=20
> 	As you wish, it is enough to know that the algorithm
> was tested to work as expected.

Regards

--=20
Inju Song
NAVER Corporation

