From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fixed spacing at for statements
Date: Tue, 6 Aug 2013 15:12:17 +0900
Message-ID: <20130806061217.GD18246@verge.net.au>
References: <1373525142-9099-1-git-send-email-dragos.foianu@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1373525142-9099-1-git-send-email-dragos.foianu@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dragos Foianu <dragos.foianu@gmail.com>
Cc: wensong@linux-vs.org, linux-kernel@vger.kernel.org, coreteam@netfilter.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org, ja@ssi.bg

On Thu, Jul 11, 2013 at 09:45:42AM +0300, Dragos Foianu wrote:
> found using checkpatch.pl

This seems reasonable to me. I will queue it up in the ipvs-next tree.

> 
> Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_lblcr.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 3cd85b2..5199448 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -414,7 +414,7 @@ static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
>  
>  	spin_lock_bh(&svc->sched_lock);
>  	tbl->dead = 1;
> -	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_LBLCR_TAB_SIZE; i++) {
>  		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
>  			ip_vs_lblcr_free(en);
>  		}
> @@ -440,7 +440,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
>  	struct ip_vs_lblcr_entry *en;
>  	struct hlist_node *next;
>  
> -	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
> +	for (i = 0, j = tbl->rover; i < IP_VS_LBLCR_TAB_SIZE; i++) {
>  		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
>  
>  		spin_lock(&svc->sched_lock);
> @@ -495,7 +495,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
>  	if (goal > tbl->max_size/2)
>  		goal = tbl->max_size/2;
>  
> -	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
> +	for (i = 0, j = tbl->rover; i < IP_VS_LBLCR_TAB_SIZE; i++) {
>  		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
>  
>  		spin_lock(&svc->sched_lock);
> @@ -536,7 +536,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
>  	/*
>  	 *    Initialize the hash buckets
>  	 */
> -	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_LBLCR_TAB_SIZE; i++) {
>  		INIT_HLIST_HEAD(&tbl->bucket[i]);
>  	}
>  	tbl->max_size = IP_VS_LBLCR_TAB_SIZE*16;
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
