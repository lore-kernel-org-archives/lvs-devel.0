From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv5 3/6] ipvs: use kthreads for stats estimation
Date: Sat, 22 Oct 2022 20:15:13 +0200
Message-ID: <20221022181513.GB3484@incl>
References: <20221009153710.125919-1-ja@ssi.bg>
 <20221009153710.125919-4-ja@ssi.bg>
 <20221015092158.GA3484@incl>
 <64d2975-357d-75f7-1d34-c43a1b3fc72a@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1666462513; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=jVWqfLVTEoBq3VxFB3Hd8UD51ZbT35LU17AsvIb91Vg=;
        b=U/S5gMJirev41Ivyp++UiULtB/vCJfugHGLXDocZecnd3sNe6k+qEUIm3Ef2iLqllbBDWH
        mfFyP7QReiJoTFOdgt7D8IO8dSoGEB3xnv/62hN2UgII4w6EbAvHwTHJuDdXh5Dromsxwa
        3qGHiJRVZJoWjlOd13c68uCGKO8dxlg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1666462513;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=jVWqfLVTEoBq3VxFB3Hd8UD51ZbT35LU17AsvIb91Vg=;
        b=Iy9yW0KWOIjHneF25Rn2Qn56mcaGilldPOpMjhYaNUjwOfgPRUd/VlwmGT05B3jB5+qEvC
        z0unxxImY67n4kDQ==
Content-Disposition: inline
In-Reply-To: <64d2975-357d-75f7-1d34-c43a1b3fc72a@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Sun, Oct 16, 2022 at 03:21:10PM +0300, Julian Anastasov wrote:
> > I have tested this. There is one problem: When the calc phase is carried out for the first time after booting the kernel the diff is several times higher than what is should be - it was 7325 ns on my testing machine. The wrong chain_max value causes 15 kthreads to be created when 500,000 estimators have been added, which is not abysmal (It's better to underestimate chain_max than to overestimate it) but not optimal either. When the ip_vs module is unloaded and then a new service is added again the diff has the expected value. The commands:
> 
> 	Yes, our goal allows underestimation of the tick time,
> 2-3 times is expected and not a big deal.

I agree that even if the max chain length was underestimated in many cases it can be expected that there will be occasions on which the max chain length would be just right. If parameters of the algorithm were changed to make the underestimates less severe there would be occasions when the max chain length would be overestimated, leading to high CPU utilization, which is undesirable.

> 	It is not a problem to add some wait_event_idle_timeout
> calls to sleep before/between tests if the system is so busy
> on boot that it can even disturb our tests with disabled BHs.

That is definitely not the case. When I get the underestimated max chain length:
> [  130.699910][ T2564] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
> [  130.707580][ T2564] IPVS: Connection hash table configured (size=4096, memory=32Kbytes)
> [  130.716633][ T2564] IPVS: ipvs loaded.
> [  130.723423][ T2570] IPVS: [wlc] scheduler registered.
> [  130.731071][  T477] IPVS: starting estimator thread 0...
> [  130.737169][ T2571] IPVS: calc: chain_max=12, single est=7379ns, diff=7379, loops=1, ntest=3
> [  130.746673][ T2571] IPVS: dequeue: 81ns
> [  130.750988][ T2571] IPVS: using max 576 ests per chain, 28800 per kthread
> [  132.678012][ T2571] IPVS: tick time: 5930ns for 64 CPUs, 2 ests, 1 chains, chain_max=576
the system is idle, not running any workload and the booting sequence has finished.

This is the scheduler trace for the calculation the underestimated max chain length above:
>  kworker/37:1-mm   477 [037]   130.737046:       sched:sched_waking: comm=ipvs-e:0:0 pid=2571 prio=120 target_cpu=062
>          swapper     0 [062]   130.737132:       sched:sched_switch: prev_comm=swapper/62 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=2571 next_prio=120
ip_vs_est_calc_limits() ran here.
>       ipvs-e:0:0  2571 [062]   130.746658: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=9537544 [ns] vruntime=579529909 [ns]
>       ipvs-e:0:0  2571 [062]   130.750979:       sched:sched_waking: comm=in:imklog pid=2248 prio=120 target_cpu=011
>       ipvs-e:0:0  2571 [062]   130.750981:       sched:sched_waking: comm=systemd-journal pid=1160 prio=120 target_cpu=017
>       ipvs-e:0:0  2571 [062]   130.750982: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=4324225 [ns] vruntime=583854134 [ns]
>       ipvs-e:0:0  2571 [062]   130.758608:       sched:sched_waking: comm=in:imklog pid=2248 prio=120 target_cpu=011
>       ipvs-e:0:0  2571 [062]   130.758609:       sched:sched_waking: comm=systemd-journal pid=1160 prio=120 target_cpu=017
>       ipvs-e:0:0  2571 [062]   130.758609: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=7627794 [ns] vruntime=591481928 [ns]
>       ipvs-e:0:0  2571 [062]   130.758617: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=7480 [ns] vruntime=591489408 [ns]
>       ipvs-e:0:0  2571 [062]   130.758619:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=2571 prev_prio=120 prev_state=I ==> next_comm=swapper/62 next_pid=0 next_prio=120
At this point, ipvs-e:0:0 blocked after finishing the first iteration of the loop in ip_vs_estimation_kthread(). Since ipvs-e:0:0 had been woken up until this point, all the trace entries from CPU 62 are listed above.
>          swapper     0 [062]   130.797980:       sched:sched_waking: comm=ipvs-e:0:0 pid=2571 prio=120 target_cpu=062
>          swapper     0 [062]   130.797992:       sched:sched_switch: prev_comm=swapper/62 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=2571 next_prio=120
>       ipvs-e:0:0  2571 [062]   130.797995: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=6252 [ns] vruntime=591495660 [ns]
>       ipvs-e:0:0  2571 [062]   130.797996:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=2571 prev_prio=120 prev_state=I ==> next_comm=swapper/62 next_pid=0 next_prio=120
>          swapper     0 [062]   130.837981:       sched:sched_waking: comm=ipvs-e:0:0 pid=2571 prio=120 target_cpu=062
>          swapper     0 [062]   130.837996:       sched:sched_switch: prev_comm=swapper/62 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=2571 next_prio=120
>       ipvs-e:0:0  2571 [062]   130.837998: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=2571 runtime=6362 [ns] vruntime=591502022 [ns]
>       ipvs-e:0:0  2571 [062]   130.838000:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=2571 prev_prio=120 prev_state=I ==> next_comm=swapper/62 next_pid=0 next_prio=120

> May be there are many IRQs that interrupt us.

I've tried that it made no difference.

> We have 2 seconds
> for the first tests, so we can add some gaps. If you want to
> test it you can add some schedule_timeout(HZ/10) between the
> 3 tests (total 300ms delay of the real estimation).

schedule_timeout(HZ/10) does not make the thread sleep - the function returns 25, which is the value of the timeout passed to it. msleep(100) works, though:
>  kworker/0:0-eve     7 [000]    70.223673:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.223770:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.223786: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=26009 [ns] vruntime=2654620258 [ns]
>       ipvs-e:0:0  8927 [051]    70.223787:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=D ==> next_comm=swapper/51 next_pid=0 next_prio=120
>          swapper     0 [051]    70.331221:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.331234:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.331241: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=11064 [ns] vruntime=2654631322 [ns]
>       ipvs-e:0:0  8927 [051]    70.331242:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=D ==> next_comm=swapper/51 next_pid=0 next_prio=120
>          swapper     0 [051]    70.439220:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.439235:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.439242: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=10324 [ns] vruntime=2654641646 [ns]
>       ipvs-e:0:0  8927 [051]    70.439243:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=D ==> next_comm=swapper/51 next_pid=0 next_prio=120
>          swapper     0 [051]    70.547220:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.547235:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.556717: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=9486028 [ns] vruntime=2664127674 [ns]
>       ipvs-e:0:0  8927 [051]    70.561134:       sched:sched_waking: comm=in:imklog pid=2210 prio=120 target_cpu=039
>       ipvs-e:0:0  8927 [051]    70.561136:       sched:sched_waking: comm=systemd-journal pid=1161 prio=120 target_cpu=001
>       ipvs-e:0:0  8927 [051]    70.561138: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=4421889 [ns] vruntime=2668549563 [ns]
>       ipvs-e:0:0  8927 [051]    70.568867:       sched:sched_waking: comm=in:imklog pid=2210 prio=120 target_cpu=039
>       ipvs-e:0:0  8927 [051]    70.568868:       sched:sched_waking: comm=systemd-journal pid=1161 prio=120 target_cpu=001
>       ipvs-e:0:0  8927 [051]    70.568870: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=7731843 [ns] vruntime=2676281406 [ns]
>       ipvs-e:0:0  8927 [051]    70.568878: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=8169 [ns] vruntime=2676289575 [ns]
>       ipvs-e:0:0  8927 [051]    70.568880:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=I ==> next_comm=swapper/51 next_pid=0 next_prio=120
>          swapper     0 [051]    70.611220:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.611239:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.611243: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=10196 [ns] vruntime=2676299771 [ns]
>       ipvs-e:0:0  8927 [051]    70.611245:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=I ==> next_comm=swapper/51 next_pid=0 next_prio=120
>          swapper     0 [051]    70.651220:       sched:sched_waking: comm=ipvs-e:0:0 pid=8927 prio=120 target_cpu=051
>          swapper     0 [051]    70.651239:       sched:sched_switch: prev_comm=swapper/51 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=ipvs-e:0:0 next_pid=8927 next_prio=120
>       ipvs-e:0:0  8927 [051]    70.651243: sched:sched_stat_runtime: comm=ipvs-e:0:0 pid=8927 runtime=10985 [ns] vruntime=2676310756 [ns]
>       ipvs-e:0:0  8927 [051]    70.651245:       sched:sched_switch: prev_comm=ipvs-e:0:0 prev_pid=8927 prev_prio=120 prev_state=I ==> next_comm=swapper/51 next_pid=0 next_prio=120
After adding msleep(), I have rebooted 3 times and added a service. The max chain length was always at the optimal value - around 35. I think more tests on other architecture would be needed. I can test on ARM next week.

-- 
Jiri Wiesner
SUSE Labs
