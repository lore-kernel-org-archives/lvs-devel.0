From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Reduce checkpatch noise in ip_vs_lblc.c
Date: Thu, 13 Feb 2014 16:05:51 +0900
Message-ID: <20140213070551.GB11245@verge.net.au>
References: <1392110241-14437-1-git-send-email-tingw.liu@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392110241-14437-1-git-send-email-tingw.liu@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tingwei Liu <tingw.liu@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Tingwei Liu <liutingwei@hisense.com>, lvs-devel@vger.kernel.org

On Tue, Feb 11, 2014 at 05:17:21PM +0800, Tingwei Liu wrote:
> Add whitespace after operator and put open brace { on the previous line

Thanks, applied to ipvs-next.

> 
> Cc: Tingwei Liu <liutingwei@hisense.com>
> Cc: lvs-devel@vger.kernel.org
> Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_lblc.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index ca056a3..547ff33 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -238,7 +238,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
>  
>  	spin_lock_bh(&svc->sched_lock);
>  	tbl->dead = 1;
> -	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
>  		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
>  			ip_vs_lblc_del(en);
>  			atomic_dec(&tbl->entries);
> @@ -265,7 +265,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
>  	unsigned long now = jiffies;
>  	int i, j;
>  
> -	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
> +	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
>  		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
>  
>  		spin_lock(&svc->sched_lock);
> @@ -321,7 +321,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
>  	if (goal > tbl->max_size/2)
>  		goal = tbl->max_size/2;
>  
> -	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
> +	for (i = 0, j = tbl->rover; i < IP_VS_LBLC_TAB_SIZE; i++) {
>  		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
>  
>  		spin_lock(&svc->sched_lock);
> @@ -340,7 +340,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
>  	tbl->rover = j;
>  
>    out:
> -	mod_timer(&tbl->periodic_timer, jiffies+CHECK_EXPIRE_INTERVAL);
> +	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
>  }
>  
>  
> @@ -363,7 +363,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
>  	/*
>  	 *    Initialize the hash buckets
>  	 */
> -	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
>  		INIT_HLIST_HEAD(&tbl->bucket[i]);
>  	}
>  	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
> @@ -536,8 +536,7 @@ out:
>  /*
>   *      IPVS LBLC Scheduler structure
>   */
> -static struct ip_vs_scheduler ip_vs_lblc_scheduler =
> -{
> +static struct ip_vs_scheduler ip_vs_lblc_scheduler = {
>  	.name =			"lblc",
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
> -- 
> 1.6.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
