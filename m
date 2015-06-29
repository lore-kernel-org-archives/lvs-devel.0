From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix crash if scheduler is changed
Date: Mon, 29 Jun 2015 10:09:11 +0900
Message-ID: <20150629010911.GC13676@verge.net.au>
References: <1435405062-20918-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435405062-20918-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Alexander Vasiliev <a.vasylev@404-group.com>

On Sat, Jun 27, 2015 at 02:37:42PM +0300, Julian Anastasov wrote:
> I overlooked the svc->sched_data usage from schedulers
> when the services were converted to RCU in 3.10. Now
> the rare ipvsadm -E command can change the scheduler
> but due to the reverse order of ip_vs_bind_scheduler
> and ip_vs_unbind_scheduler we provide new sched_data
> to the old scheduler resulting in a crash.
> 
> To fix it without changing the scheduler methods we
> have to use synchronize_rcu() only for the editing case.
> It means all svc->scheduler readers should expect a
> NULL value. To avoid breakage for the service listing
> and ipvsadm -R we can use the "none" name to indicate
> that scheduler is not assigned, a state when we drop
> new connections.
> 
> Reported-by: Alexander Vasiliev <a.vasylev@404-group.com>
> Fixes: ceec4c381681 ("ipvs: convert services to rcu")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have applied this to the ipvs tree.
