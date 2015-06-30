From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 net] ipvs: fix crash if scheduler is changed
Date: Tue, 30 Jun 2015 10:52:32 +0900
Message-ID: <20150630015231.GB3517@verge.net.au>
References: <1435603900-6307-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435603900-6307-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Alexander Vasiliev <a.vasylev@404-group.com>

On Mon, Jun 29, 2015 at 09:51:40PM +0300, Julian Anastasov wrote:
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

Thanks, I have pushed this to the ipvs tree after dropping
the previous version of this patch.
