From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/3] ipvs: avoid rcu_barrier during netns cleanup
Date: Wed, 16 Oct 2013 12:43:06 +0200
Message-ID: <20131016104306.GA10288@localhost>
References: <1381802507-7934-1-git-send-email-horms@verge.net.au>
 <1381802507-7934-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381802507-7934-3-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Oct 15, 2013 at 11:01:46AM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> commit 578bc3ef1e473a ("ipvs: reorganize dest trash") added
> rcu_barrier() on cleanup to wait dest users and schedulers
> like LBLC and LBLCR to put their last dest reference.
> Using rcu_barrier with many namespaces is problematic.
> 
> Trying to fix it by freeing dest with kfree_rcu is not
> a solution, RCU callbacks can run in parallel and execution
> order is random.
> 
> Fix it by creating new function ip_vs_dest_put_and_free()
> which is heavier than ip_vs_dest_put(). We will use it just
> for schedulers like LBLC, LBLCR that can delay their dest
> release.
> 
> By default, dests reference is above 0 if they are present in
> service and it is 0 when deleted but still in trash list.
> Change the dest trash code to use ip_vs_dest_put_and_free(),
> so that refcnt -1 can be used for freeing. As result,
> such checks remain in slow path and the rcu_barrier() from
> netns cleanup can be removed.

I can enqueue this fix to nf if you like. No need to resend, I can
manually apply.

Let me know.
