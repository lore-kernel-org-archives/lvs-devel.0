From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 4/7] ipvs: use kthreads for stats estimation
Date: Thu, 10 Nov 2022 16:39:15 +0100
Message-ID: <20221110153915.GD3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-5-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668094756; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=D1wGi0OOM3x8z8rsmnWVm2C4yLCZBionOdkXg5tWAvI=;
        b=aJNXsDmP9ZEnCiZol3EkCtVP80vypyqNUb5OV6JNCvz1XIXjWtgFm06xfA5+fcsP5IT9uf
        hl4DB5foNE3SEDYbIA8EQ2zr4+bUPkZkP43KTMHoSPzxB+w9J3h0sVZAR8ekBuJgbF4JHE
        aKlj6twpxBq/TkG3jSFPhj5BbhyWWWI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668094756;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=D1wGi0OOM3x8z8rsmnWVm2C4yLCZBionOdkXg5tWAvI=;
        b=QJ6eDTDGYa1MRDq5PzVpRdorlazJ4R9yM8ko7PbYG/Exy8nOtMoM5+6Q2CWa3wUUWBD/Ew
        bTC7IhP+3UAbufAw==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-5-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:44PM +0200, Julian Anastasov wrote:
> +/* Calculate limits for all kthreads */
> +static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
> +{
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(wq);
> +	struct ip_vs_est_kt_data *kd;
> +	struct hlist_head chain;
> +	struct ip_vs_stats *s;
> +	int cache_factor = 4;
> +	int i, loops, ntest;
> +	s32 min_est = 0;
> +	ktime_t t1, t2;
> +	s64 diff, val;
> +	int max = 8;
> +	int ret = 1;
> +
> +	INIT_HLIST_HEAD(&chain);
> +	mutex_lock(&__ip_vs_mutex);
> +	kd = ipvs->est_kt_arr[0];
> +	mutex_unlock(&__ip_vs_mutex);
> +	s = kd ? kd->calc_stats : NULL;
> +	if (!s)
> +		goto out;
> +	hlist_add_head(&s->est.list, &chain);
> +
> +	loops = 1;
> +	/* Get best result from many tests */
> +	for (ntest = 0; ntest < 12; ntest++) {
> +		if (!(ntest & 3)) {
> +			wait_event_idle_timeout(wq, kthread_should_stop(),
> +						HZ / 50);
> +			if (!ipvs->enable || kthread_should_stop())
> +				goto stop;
> +		}

I was testing the stability of chain_max:
Intel(R) Xeon(R) Gold 6326 CPU @ 2.90GHz
64 CPUs, 2 NUMA nodes
> while :; do ipvsadm -A -t 10.10.10.1:2000; sleep 3; ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs; sleep 10m; done
> # dmesg | awk '/calc: chain_max/{m = $(NF - 5); sub("chain_max=", "", m); sub(",", "", m); m = int(m / 10) * 10; hist[m]++} END {PROCINFO["sorted_in"] = "@ind_num_asc"; for (m in hist) printf "%5d %5d\n", m, hist[m]}'
>    30    90
>    40     2
Chain_max was often 30-something. Chain_max was never below 30, which was observed earlier when only 3 tests were carried out.

AMD EPYC 7601 32-Core Processor
128 CPUs, 8 NUMA nodes
Zen 1 machines such as this one have a large number of NUMA nodes due to restrictions in the CPU architecture. First, tests with different governors:
> cpupower frequency-set -g ondemand
> [  653.441325] IPVS: starting estimator thread 0...
> [  653.514918] IPVS: calc: chain_max=8, single est=11171ns, diff=11301, loops=1, ntest=12
> [  653.523580] IPVS: dequeue: 892ns
> [  653.527528] IPVS: using max 384 ests per chain, 19200 per kthread
> [  655.349916] IPVS: tick time: 3059313ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> [  685.230016] IPVS: starting estimator thread 1...
> [  717.110852] IPVS: starting estimator thread 2...
> [  719.349755] IPVS: tick time: 2896668ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> [  750.349974] IPVS: starting estimator thread 3...
> [  783.349841] IPVS: tick time: 2942604ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
> [  847.349811] IPVS: tick time: 2930872ns for 128 CPUs, 384 ests, 1 chains, chain_max=384
>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>  74902 root      20   0       0      0      0 I 7.591 0.000   0:13.95 ipvs-e:0:1
>  94104 root      20   0       0      0      0 I 7.591 0.000   0:11.59 ipvs-e:0:2
>  55669 root      20   0       0      0      0 I 6.931 0.000   0:15.75 ipvs-e:0:0
> 113311 root      20   0       0      0      0 I 0.990 0.000   0:01.31 ipvs-e:0:3
> cpupower frequency-set -g performance
> [ 1448.118857] IPVS: starting estimator thread 0...
> [ 1448.194882] IPVS: calc: chain_max=22, single est=4138ns, diff=4298, loops=1, ntest=12
> [ 1448.203435] IPVS: dequeue: 340ns
> [ 1448.207373] IPVS: using max 1056 ests per chain, 52800 per kthread
> [ 1450.029581] IPVS: tick time: 2727370ns for 128 CPUs, 518 ests, 1 chains, chain_max=1056
> [ 1510.792734] IPVS: starting estimator thread 1...
> [ 1514.032300] IPVS: tick time: 5436826ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> [ 1578.032593] IPVS: tick time: 5691875ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>  42514 root      20   0       0      0      0 I 14.24 0.000   0:14.96 ipvs-e:0:0
>  95356 root      20   0       0      0      0 I 1.987 0.000   0:01.34 ipvs-e:0:1
While having the services loaded, I switched to the ondemand governor:
> [ 1706.032577] IPVS: tick time: 5666868ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> [ 1770.032534] IPVS: tick time: 5638505ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>  42514 root      20   0       0      0      0 I 18.15 0.000   0:35.75 ipvs-e:0:0
>  95356 root      20   0       0      0      0 I 2.310 0.000   0:04.05 ipvs-e:0:1
While having the services loaded, I kept the ondemand governor and saturated all logical CPUs on the machine:
> [ 1834.033988] IPVS: tick time: 7129383ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
> [ 1898.038151] IPVS: tick time: 7281418ns for 128 CPUs, 1056 ests, 1 chains, chain_max=1056
>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> 102581 root      20   0 1047636 262304   1580 R 12791 0.100 161:03.94 a.out
>  42514 root      20   0       0      0      0 I 17.76 0.000   1:06.88 ipvs-e:0:0
>  95356 root      20   0       0      0      0 I 2.303 0.000   0:08.33 ipvs-e:0:1
As for the stability of chain_max:
> while :; do ipvsadm -A -t 10.10.10.1:2000; sleep 3; ipvsadm -D -t 10.10.10.1:2000; modprobe -r ip_vs_wlc ip_vs; sleep 2m; done
> dmesg | awk '/calc: chain_max/{m = $(NF - 5); sub("chain_max=", "", m); sub(",", "", m); m = int(m / 2) * 2; hist[m]++} END {PROCINFO["sorted_in"] = "@ind_num_asc"; for (m in hist) printf "%5d %5d\n", m, hist[m]}'
>     8    22
>    24     1

Basically, chain_max calculation under gonernors than ramp up CPU frequency more slowly (ondemand on AMD or powersave for intel_pstate) is stabler than before on both AMD and Intel. We know from previous results that even ARM with multiple NUMA nodes is not a complete disaster. Switching CPU frequency gonernors, including the unfavourable switches from performance to ondemand, does not saturate CPUs. When it comes to CPU frequency gonernors, people tend to use either ondemand (or powersave for intel_pstate) or performance consistently - switches between gonernors can be expected to be rare in production.
I will need to find out to read through the latest version of the patch set.

> +
> +		local_bh_disable();
> +		rcu_read_lock();
> +
> +		/* Put stats in cache */
> +		ip_vs_chain_estimation(&chain);
> +
> +		t1 = ktime_get();
> +		for (i = loops * cache_factor; i > 0; i--)
> +			ip_vs_chain_estimation(&chain);
> +		t2 = ktime_get();
> +
> +		rcu_read_unlock();
> +		local_bh_enable();
> +
> +		if (!ipvs->enable || kthread_should_stop())
> +			goto stop;
> +		cond_resched();
> +
> +		diff = ktime_to_ns(ktime_sub(t2, t1));
> +		if (diff <= 1 * NSEC_PER_USEC) {
> +			/* Do more loops on low resolution */
> +			loops *= 2;
> +			continue;
> +		}
> +		if (diff >= NSEC_PER_SEC)
> +			continue;
> +		val = diff;
> +		do_div(val, loops);
> +		if (!min_est || val < min_est) {
> +			min_est = val;
> +			/* goal: 95usec per chain */
> +			val = 95 * NSEC_PER_USEC;
> +			if (val >= min_est) {
> +				do_div(val, min_est);
> +				max = (int)val;
> +			} else {
> +				max = 1;
> +			}
> +		}
> +	}
> +
> +out:
> +	if (s)
> +		hlist_del_init(&s->est.list);
> +	*chain_max = max;
> +	return ret;
> +
> +stop:
> +	ret = 0;
> +	goto out;
> +}

-- 
Jiri Wiesner
SUSE Labs
