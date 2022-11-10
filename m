From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv6 4/7] ipvs: use kthreads for stats estimation
Date: Thu, 10 Nov 2022 22:16:24 +0200 (EET)
Message-ID: <ff8bf15e-ddf3-76d1-b23b-814133ae5b@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg> <20221031145647.156930-5-ja@ssi.bg> <20221110153915.GD3484@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221110153915.GD3484@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Thu, 10 Nov 2022, Jiri Wiesner wrote:

> On Mon, Oct 31, 2022 at 04:56:44PM +0200, Julian Anastasov wrote:
> > +
> > +	loops = 1;
> > +	/* Get best result from many tests */
> > +	for (ntest = 0; ntest < 12; ntest++) {
> > +		if (!(ntest & 3)) {
> > +			wait_event_idle_timeout(wq, kthread_should_stop(),
> > +						HZ / 50);
> > +			if (!ipvs->enable || kthread_should_stop())
> > +				goto stop;
> > +		}
> 
> I was testing the stability of chain_max:
> Intel(R) Xeon(R) Gold 6326 CPU @ 2.90GHz
> 64 CPUs, 2 NUMA nodes
> > while :; do ipvsadm -A -t 10.10.10.1:2000; sleep 3; ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs; sleep 10m; done
> > # dmesg | awk '/calc: chain_max/{m = $(NF - 5); sub("chain_max=", "", m); sub(",", "", m); m = int(m / 10) * 10; hist[m]++} END {PROCINFO["sorted_in"] = "@ind_num_asc"; for (m in hist) printf "%5d %5d\n", m, hist[m]}'
> >    30    90
> >    40     2
> Chain_max was often 30-something. Chain_max was never below 30, which was observed earlier when only 3 tests were carried out.

	So, 12 tests and 3 20ms gaps eliminate any cpufreq
issues in most of the cases and we do not see small chain_max
value.

> AMD EPYC 7601 32-Core Processor
> 128 CPUs, 8 NUMA nodes
> Zen 1 machines such as this one have a large number of NUMA nodes due to restrictions in the CPU architecture. First, tests with different governors:
> > cpupower frequency-set -g ondemand
> > [  653.441325] IPVS: starting estimator thread 0...
> > [  653.514918] IPVS: calc: chain_max=8, single est=11171ns, diff=11301, loops=1, ntest=12
> > [  653.523580] IPVS: dequeue: 892ns
> > [  653.527528] IPVS: using max 384 ests per chain, 19200 per kthread
> > [  655.349916] IPVS: tick time: 3059313ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> > [  685.230016] IPVS: starting estimator thread 1...
> > [  717.110852] IPVS: starting estimator thread 2...
> > [  719.349755] IPVS: tick time: 2896668ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> > [  750.349974] IPVS: starting estimator thread 3...
> > [  783.349841] IPVS: tick time: 2942604ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> > [  847.349811] IPVS: tick time: 2930872ns for 128 CPUs, 384 ests, 1 chains, chain_max=384

	Looks like cache_factor of 4 is good both to
ondemand which prefers cache_factor 3 (2.9->4ms) and performance
which prefers cache_factor 5 (5.6->4.3ms):

gov/cache_factor	chain_max	tick time (goal 4.8ms)
ondemand/4		8		2.9ms
ondemand/3		11		4ms
performance/4		22		5.6ms
performance/5		17		4.3ms

> >    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> >  74902 root      20   0       0      0      0 I 7.591 0.000   0:13.95 ipvs-e:0:1
> >  94104 root      20   0       0      0      0 I 7.591 0.000   0:11.59 ipvs-e:0:2
> >  55669 root      20   0       0      0      0 I 6.931 0.000   0:15.75 ipvs-e:0:0
> > 113311 root      20   0       0      0      0 I 0.990 0.000   0:01.31 ipvs-e:0:3
> > cpupower frequency-set -g performance
> > [ 1448.118857] IPVS: starting estimator thread 0...
> > [ 1448.194882] IPVS: calc: chain_max=22, single est=4138ns, diff=4298, loops=1, ntest=12
> > [ 1448.203435] IPVS: dequeue: 340ns
> > [ 1448.207373] IPVS: using max 1056 ests per chain, 52800 per kthread
> > [ 1450.029581] IPVS: tick time: 2727370ns for 128 CPUs, 518 ests, 1 chains, chain_max=1056
> > [ 1510.792734] IPVS: starting estimator thread 1...
> > [ 1514.032300] IPVS: tick time: 5436826ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056

	performance takes 5.4-5.6ms with chain_max 22

> > [ 1578.032593] IPVS: tick time: 5691875ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> >    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> >  42514 root      20   0       0      0      0 I 14.24 0.000   0:14.96 ipvs-e:0:0
> >  95356 root      20   0       0      0      0 I 1.987 0.000   0:01.34 ipvs-e:0:1
> While having the services loaded, I switched to the ondemand governor:
> > [ 1706.032577] IPVS: tick time: 5666868ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> > [ 1770.032534] IPVS: tick time: 5638505ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056

	Hm, ondemand governor takes 5.6ms just like
the above performance result? This is probabllly still
performance mode?

> >    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> >  42514 root      20   0       0      0      0 I 18.15 0.000   0:35.75 ipvs-e:0:0
> >  95356 root      20   0       0      0      0 I 2.310 0.000   0:04.05 ipvs-e:0:1
> While having the services loaded, I kept the ondemand governor and saturated all logical CPUs on the machine:
> > [ 1834.033988] IPVS: tick time: 7129383ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> > [ 1898.038151] IPVS: tick time: 7281418ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056

	Or ondemand takes 7.1ms with performance's chain_max=22
which is more real if we do 2.9*22/8=7.9ms.

> >    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> > 102581 root      20   0 1047636 262304   1580 R 12791 0.100 161:03.94 a.out
> >  42514 root      20   0       0      0      0 I 17.76 0.000   1:06.88 ipvs-e:0:0
> >  95356 root      20   0       0      0      0 I 2.303 0.000   0:08.33 ipvs-e:0:1

	If kthreads are isolated at some unused CPUs they
have space to go from desired 12.5% to 100% :) 17% is still
not so scary :) The scheduler can probably allow even 100%
usage by moving the kthreads between idle CPUs.

> As for the stability of chain_max:
> > while :; do ipvsadm -A -t 10.10.10.1:2000; sleep 3; ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs; sleep 2m; done
> > dmesg | awk '/calc: chain_max/{m = $(NF - 5); sub("chain_max=", "", m); sub(",", "", m); m = int(m / 2) * 2; hist[m]++} END {PROCINFO["sorted_in"] = "@ind_num_asc"; for (m in hist) printf "%5d %5d\n", m, hist[m]}'
> >     8    22
> >    24     1
> 
> Basically, chain_max calculation under gonernors than ramp up CPU frequency more slowly (ondemand on AMD or powersave for intel_pstate) is stabler than before on both AMD and Intel. We know from previous results that even ARM with multiple NUMA nodes is not a complete disaster. Switching CPU frequency gonernors, including the unfavourable switches from performance to ondemand, does not saturate CPUs. When it comes to CPU frequency gonernors, people tend to use either ondemand (or powersave for intel_pstate) or performance consistently - switches between gonernors can be expected to be rare in production.
> I will need to find out to read through the latest version of the patch set.

	OK. Thank you for testing the different cases!
Let me know if any changes are needed before releasing
the patchset. We can even include some testing results
in the commit messages.

Regards

--
Julian Anastasov <ja@ssi.bg>

