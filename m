From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fixed style errors in ip_vs_dh
Date: Tue, 6 Aug 2013 15:20:33 +0900
Message-ID: <20130806062033.GE18246@verge.net.au>
References: <1373570144-4785-1-git-send-email-dragos.foianu@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1373570144-4785-1-git-send-email-dragos.foianu@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dragos Foianu <dragos.foianu@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thu, Jul 11, 2013 at 10:15:44PM +0300, Dragos Foianu wrote:
> found with the help of checkpatch.pl

Thanks for your contribution and sorry for taking so long to look at it.

While in principle I have no problem with these changes.
I would like them to be be accompanied by more descriptive changelogs.

In the case of this patch there seem to be two fixes.

1. Fix whitespace associated with for statements.
2. Place opening '{' of structure initialiser on its won line.

I'm sure that the wording above can be improved, but as a minimum
I would like something like that included in the changelog.

I think that I would also prefer each of the two changes in their own
patch, rather than grouping them together because they happen to be in the
same file.

Likewise for the following patches that you also submitted:

* [PATCH] ipvs: fixed style error in ip_vs_sched
* [PATCH] ipvs: fixed style errors and warnings in ip_vs_conn

I would not object if you grouped together the same change in multiple
files into a single patch.

> Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_dh.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
> index c3b8454..8ab2fc8 100644
> --- a/net/netfilter/ipvs/ip_vs_dh.c
> +++ b/net/netfilter/ipvs/ip_vs_dh.c
> @@ -110,7 +110,7 @@ ip_vs_dh_reassign(struct ip_vs_dh_state *s, struct ip_vs_service *svc)
>  	b = &s->buckets[0];
>  	p = &svc->destinations;
>  	empty = list_empty(p);
> -	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_DH_TAB_SIZE; i++) {
>  		dest = rcu_dereference_protected(b->dest, 1);
>  		if (dest)
>  			ip_vs_dest_put(dest);
> @@ -142,7 +142,7 @@ static void ip_vs_dh_flush(struct ip_vs_dh_state *s)
>  	struct ip_vs_dest *dest;
>  
>  	b = &s->buckets[0];
> -	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
> +	for (i = 0; i < IP_VS_DH_TAB_SIZE; i++) {
>  		dest = rcu_dereference_protected(b->dest, 1);
>  		if (dest) {
>  			ip_vs_dest_put(dest);
> @@ -244,8 +244,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
>  /*
>   *      IPVS DH Scheduler structure
>   */
> -static struct ip_vs_scheduler ip_vs_dh_scheduler =
> -{
> +static struct ip_vs_scheduler ip_vs_dh_scheduler = {
>  	.name =			"dh",
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
