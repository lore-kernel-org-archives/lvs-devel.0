From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net 3/4] ipvs: make the service replacement more robust
Date: Wed, 11 Sep 2013 12:58:58 +0900
Message-ID: <20130911035858.GF23073@verge.net.au>
References: <1377707376-4362-1-git-send-email-ja@ssi.bg>
 <1377707376-4362-4-git-send-email-ja@ssi.bg>
 <alpine.LFD.2.00.1309102214530.1691@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1309102214530.1691@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Tue, Sep 10, 2013 at 10:28:13PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 28 Aug 2013, Julian Anastasov wrote:
> 
> > -	/* Some dest can be in grace period even before cleanup, we have to
> > -	 * defer ip_vs_trash_cleanup until ip_vs_dest_wait_readers is called.
> > -	 */
> > -	rcu_barrier();
> >  	ip_vs_trash_cleanup(net);
> >  	ip_vs_stop_estimator(net, &ipvs->tot_stats);
> >  	ip_vs_control_net_cleanup_sysctl(net);
> 
> 	Simon, I have to update this patch. rcu_barrier
> can not simply disappear because LBLC[R] use RCU callbacks
> and we have to wait them to put the final reference to dest
> before calling ip_vs_trash_cleanup(). It needs different
> solution, if possible without rcu_barrier. I'll send updated
> patchset in next days.

Thanks, noted.
