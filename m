From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH nf-next] netfilter: ipvs: Divide estimators into
 groups
Date: Thu, 25 Aug 2022 13:32:35 +0300 (EEST)
Message-ID: <5af573f-b773-d43-4b11-dea3c2797d7e@ssi.bg>
References: <20220812103459.GA7521@incl> <f1657ace-59fb-7265-faf8-8a1a26aaf560@ssi.bg> <20220816162257.GA18621@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220816162257.GA18621@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Tue, 16 Aug 2022, Jiri Wiesner wrote:

> On Sat, Aug 13, 2022 at 03:11:48PM +0300, Julian Anastasov wrote:
> > > The intention is to develop this RFC patch into a short series addressing
> > > the design changes proposed in [1]. Also, after moving the rate estimation
> > > out of softirq context, the whole estimator list could be processed
> > > concurrently - more than one work item would be used.
> > 
> > 	Other developers tried solutions with workqueues
> > but so far we don't see any results. Give me some days, may be
> > I can come up with solution that uses kthread(s) to allow later
> > nice/cpumask cfg tuning and to avoid overload of the system
> > workqueues.
> 
> The RFC patch already resolves the issue despite having the code still run in softirq context. Even if estimators were processed in groups, moving the rate estimation out of softirq context is a good idea. I am interested in implementing this. An alternative approach would be moving the rate estimation out of softirq context and reworking locking so that cond_resched() could be used to let other processes run as the scheduler sees fit. I would be willing to try to implement this alternative approach as well.

	I started reworking the estimation code. I think,
I'll have results in few days. I'm using kthreads, the
locking is ready, just finishing the cpumask/nice
configuration and will do simple tests. When a RFC patch
is ready we can comment what should be the final version.

Regards

--
Julian Anastasov <ja@ssi.bg>

