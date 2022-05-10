From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: ipvs: random start for RR scheduler
Date: Tue, 10 May 2022 23:18:40 +0300 (EEST)
Message-ID: <b8bf73ea-2ce9-2726-fde1-bd47d3b7a5d@ssi.bg>
References: <20220509122213.19508-1-imagedong@tencent.com> <cb8eaad0-83c5-a150-d830-e078682ba18b@ssi.bg> <CADxym3YH_76+5g29QF4Xp4gXJz5bwdQXD_gXv3esAVTgNGkXyg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CADxym3YH_76+5g29QF4Xp4gXJz5bwdQXD_gXv3esAVTgNGkXyg@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Menglong Dong <menglong8.dong@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Menglong Dong <imagedong@tencent.com>


	Hello,

On Tue, 10 May 2022, Menglong Dong wrote:

> On Tue, May 10, 2022 at 2:17 AM Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         or just use
> >
> >         start = prandom_u32_max(svc->num_dests);
> >
> >         Also, this line can be before the spin_lock_bh.
> >
> > > +     cur = &svc->destinations;
> >
> >         cur = svc->sched_data;
> >
> >         ... and to start from current svc->sched_data because
> > we are called for every added dest. Better to jump 0..127 steps
> > ahead, to avoid delay with long lists?
> >
> 
> I'm a little afraid that the 'steps' may make the starting dest not
> absolutely random, in terms of probability. For example, we have
> 256 services, and will the services in the middle have more chances
> to be chosen as the start? It's just a feeling, I'm not good at
> Probability :/

	Me too, so I created a test for the eyes :) I hope
it correctly implements the algorithm.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DESTS		1024
#define NTESTS		(500000)
#define MAX_STEP	32

/* MAX_STEP:
 * 4: last has 3 times more chance than first
 * 5: last has 2 times more chance than first
 * 6: last has 60% more chance than first
 * 7: last has 50% more chance than first
 * 10: last has 20% more chance than first
 * 16: last has 10% more chance than first
 * 32: last has 3% more chance than first
 */

int
main (int argc, char *argv[])
{
	int arr[DESTS];		/* Hits per dest */
	int i, n;
	int64_t perc = 0, perc2;

	memset(arr, 0, sizeof(arr));
	srand(257);
	/* Do more test for better stats */
	for (i = 0; i < NTESTS; i++)
	{
		int pos = 0;	/* sched_data */

		/* Show progress */
		perc2 = ((int64_t) i * 100) / NTESTS;
		if (perc != perc2)
		{
			fprintf(stderr, "\r%d%%", (int) perc2);
			fflush(stderr);
			perc = perc2;
		}
		/* Add all dests */
		for (n = 2; n < DESTS; n++)
		{
			int m, step;

			/* New dest -> new step */
			m = n;
			if (m > MAX_STEP)
				m = MAX_STEP;
			step = rand() % m;

			pos = (pos + step) % n;
		}
		/* Start pos determined */
		arr[pos] ++;
	}
	fprintf(stderr, "\n");
	for (n = 0; n < DESTS; n++)
	{
		printf("%d\t%d\n", n, arr[n]);
	}
	return 0;
}

$ gcc -Wall -O -o test test.c

	Output can be saved to file and shown with gnuplot:

$ ./test > file.out
$ gnuplot
gnuplot> plot 'file.out'

	What I see is that the value 128 is good but using
32 (MAX_STEP in the test) gives good enough results (3% diff).
The test shows that:

- last dests have more chance to be selected as starting point
- low value for MAX_STEP causes higher difference in probability
between first and last dests

	Our goal is to select lower value for MAX_STEP that
provides probability difference that is low enough.

Regards

--
Julian Anastasov <ja@ssi.bg>

