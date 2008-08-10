From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH 2/9] ipvs: Fix possible deadlock in estimator code
Date: Sun, 10 Aug 2008 15:58:15 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808101402490.12259@titan.stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <1218366459-23971-3-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-3-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:

> From: Sven Wegener <sven.wegener@stealer.net>
> 
> There is a slight chance for a deadlock in the estimator code. We can't call
> del_timer_sync() while holding our lock, as the timer might be active and
> spinning for the lock on another cpu. Work around this issue by using
> try_to_del_timer_sync() and releasing the lock. We could actually delete the
> timer outside of our lock, as the add and kill functions are only every called
> from userspace via [gs]etsockopt() and are serialized by a mutex, but better
> make this explicit.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> Cc: stable <stable@kernel.org>
> ---
>  net/ipv4/ipvs/ip_vs_est.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
> index bc04eed..1d6e58e 100644
> --- a/net/ipv4/ipvs/ip_vs_est.c
> +++ b/net/ipv4/ipvs/ip_vs_est.c
> @@ -170,8 +170,11 @@ void ip_vs_kill_estimator(struct ip_vs_stats *stats)
>  		kfree(est);
>  		killed++;
>  	}
> -	if (killed && est_list == NULL)
> -		del_timer_sync(&est_timer);
> +	while (killed && !est_list && try_to_del_timer_sync(&est_timer) < 0) {
> +		write_unlock_bh(&est_lock);
> +		cpu_relax();
> +		write_lock_bh(&est_lock);
> +	}
>  	write_unlock_bh(&est_lock);
>  }
>  

As a side note, just noticed that this opens another race condition, if we 
leave the mutex serializing the [gs]etsockopt calls out:

If the timer reschedules itself, after we just removed the last estimator, 
but we failed to deactivate the timer due to it being active, we have the 
chance of add_timer() on already pending timer during creating a new 
estimator. This will then trigger the BUG_ON() in add_timer(). Thanks to 
the mutex this can't happen currently.

The "ipvs: Embed estimator object into stats object" patch will move to 
code from add_timer() to mod_timer() so at the the end of this series 
we're safe.

Sven
