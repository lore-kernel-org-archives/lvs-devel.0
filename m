From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv7 0/6] ipvs: Use kthreads for stats
Date: Sat, 10 Dec 2022 02:47:45 +0200 (EET)
Message-ID: <6d155743-5bd-ba4e-225d-ac2875c99c76@ssi.bg>
References: <20221122164604.66621-1-ja@ssi.bg> <Y5HTM6jY/ZRw+ar0@salvia> <Y5HV0EpOrQtdU11y@salvia> <1866fdd6-dff-67b5-cd66-41bc8962957d@ssi.bg> <Y5OhfLeQiOXhQ2/s@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Y5OhfLeQiOXhQ2/s@salvia>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Jiri Wiesner <jwiesner@suse.de>, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Fri, 9 Dec 2022, Pablo Neira Ayuso wrote:

> On Thu, Dec 08, 2022 at 07:03:44PM +0200, Julian Anastasov wrote:
> > 
> > > Is there any particular reason for not using the generic workqueue
> > > infrastructure? I could not find a reason in the commit logs.
> > 
> > 	The estimation can take long time when using
> > multiple IPVS rules (eg. millions estimator structures) and
> > especially when box has multiple CPUs due to the for_each_possible_cpu
> > usage that expects packets from any CPU. With est_nice sysctl
> > we have more control how to prioritize the estimation
> > kthreads compared to other processes/kthreads that
> > have latency requirements (such as servers). As a benefit,
> > we can see these kthreads in top and decide if we will
> > need some further control to limit their CPU usage (max
> > number of structure to estimate per kthread).
> 
> OK, then my understanding is that you have requirements to have more
> control on the kthreads than what the workqueue interface provides.
> 
> I can see there is WQ_HIGHPRI and WQ_CPU_INTENSIVE flags to signal
> latency sensitive and work taking long time to complete in the
> workqueue respectively, but I have never used them though. sysfs also
> exposes cpumask and nice, but you set the nice level while creating
> kthreads on-demand from the kernel itself using the value provided by
> new sysctl knob to set the nice value.

	There are probably more reasons why kthreads look
better:

- with kthreads we run code that is read-mostly, no write/lock
operations to process the estimators in 2-second intervals

- work items are one-shot: as estimators are processed every
2 seconds, they need to be re-added every time. This again
loads the timers (add_timer) if we use delayed works, as there are
no kthreads to do the timings.

> I'd like to include the text above you wrote in the pull request.
> Please, let me know if you would like to expand it, I'll apply these
> to nf-next and prepare the pull request by tomorrow.

	There is such paragraph in 0/6:

===
	Spread the estimation on multiple (configured) CPUs and
multiple time slots (timer ticks) by using multiple chains
organized under RCU rules. When stats are not needed, it is recommended
to use run_estimation=0 as already implemented before this change.
===

	After it we can add something like that which
explains why we prefer kthreads over work queue from
performance point of view:

===
	Solution with kthreads was preferred over workqueues
because there is less overhead to process the entries in
specific time intervals:

- entries are not unlinked before processing, so no write/lock
operations to re-queue them
- not using kernel timers as it is done by the delayed works,
the entries do not change position in lists and processing
is read-only
===

Regards

--
Julian Anastasov <ja@ssi.bg>

