From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: use hlist instead of list
Date: Tue, 22 Feb 2011 15:45:12 +0900
Message-ID: <20110222064510.GA7954@verge.net.au>
References: <1298109908-29272-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1298109908-29272-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Changli Gao <xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Thanks, I have queued this change.

On Sat, Feb 19, 2011 at 06:05:08PM +0800, Changli Gao wrote:
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  include/net/ip_vs.h             |    2 -
>  net/netfilter/ipvs/ip_vs_conn.c |   52 ++++++++++++++++++++++------------------
>  2 files changed, 30 insertions(+), 24 deletions(-)
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index e80ffb7..2078a47 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -494,7 +494,7 @@ struct ip_vs_conn_param {
>   *	IP_VS structure allocated for each dynamically scheduled connection
>   */
>  struct ip_vs_conn {
> -	struct list_head        c_list;         /* hashed list heads */
> +	struct hlist_node	c_list;         /* hashed list heads */
>  #ifdef CONFIG_NET_NS
>  	struct net              *net;           /* Name space */
>  #endif
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 83233fe..9c2a517 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -59,7 +59,7 @@ static int ip_vs_conn_tab_mask __read_mostly;
>  /*
>   *  Connection hash table: for input and output packets lookups of IPVS
>   */
> -static struct list_head *ip_vs_conn_tab __read_mostly;
> +static struct hlist_head *ip_vs_conn_tab __read_mostly;
>  
>  /*  SLAB cache for IPVS connections */
>  static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
> @@ -201,7 +201,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  	spin_lock(&cp->lock);
>  
>  	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
> -		list_add(&cp->c_list, &ip_vs_conn_tab[hash]);
> +		hlist_add_head(&cp->c_list, &ip_vs_conn_tab[hash]);
>  		cp->flags |= IP_VS_CONN_F_HASHED;
>  		atomic_inc(&cp->refcnt);
>  		ret = 1;
> @@ -234,7 +234,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
>  	spin_lock(&cp->lock);
>  
>  	if (cp->flags & IP_VS_CONN_F_HASHED) {
> -		list_del(&cp->c_list);
> +		hlist_del(&cp->c_list);
>  		cp->flags &= ~IP_VS_CONN_F_HASHED;
>  		atomic_dec(&cp->refcnt);
>  		ret = 1;
> @@ -259,12 +259,13 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
>  {
>  	unsigned hash;
>  	struct ip_vs_conn *cp;
> +	struct hlist_node *n;
>  
>  	hash = ip_vs_conn_hashkey_param(p, false);
>  
>  	ct_read_lock(hash);
>  
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	hlist_for_each_entry(cp, n, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af == p->af &&
>  		    p->cport == cp->cport && p->vport == cp->vport &&
>  		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
> @@ -345,12 +346,13 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
>  {
>  	unsigned hash;
>  	struct ip_vs_conn *cp;
> +	struct hlist_node *n;
>  
>  	hash = ip_vs_conn_hashkey_param(p, false);
>  
>  	ct_read_lock(hash);
>  
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	hlist_for_each_entry(cp, n, &ip_vs_conn_tab[hash], c_list) {
>  		if (!ip_vs_conn_net_eq(cp, p->net))
>  			continue;
>  		if (p->pe_data && p->pe->ct_match) {
> @@ -394,6 +396,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  {
>  	unsigned hash;
>  	struct ip_vs_conn *cp, *ret=NULL;
> +	struct hlist_node *n;
>  
>  	/*
>  	 *	Check for "full" addressed entries
> @@ -402,7 +405,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  
>  	ct_read_lock(hash);
>  
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	hlist_for_each_entry(cp, n, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af == p->af &&
>  		    p->vport == cp->cport && p->cport == cp->dport &&
>  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
> @@ -818,7 +821,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
>  		return NULL;
>  	}
>  
> -	INIT_LIST_HEAD(&cp->c_list);
> +	INIT_HLIST_NODE(&cp->c_list);
>  	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
>  	ip_vs_conn_net_set(cp, p->net);
>  	cp->af		   = p->af;
> @@ -894,8 +897,8 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
>   */
>  #ifdef CONFIG_PROC_FS
>  struct ip_vs_iter_state {
> -	struct seq_net_private p;
> -	struct list_head *l;
> +	struct seq_net_private	p;
> +	struct hlist_head	*l;
>  };
>  
>  static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> @@ -903,13 +906,14 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
>  	int idx;
>  	struct ip_vs_conn *cp;
>  	struct ip_vs_iter_state *iter = seq->private;
> +	struct hlist_node *n;
>  
>  	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
>  		ct_read_lock_bh(idx);
> -		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> +		hlist_for_each_entry(cp, n, &ip_vs_conn_tab[idx], c_list) {
>  			if (pos-- == 0) {
>  				iter->l = &ip_vs_conn_tab[idx];
> -			return cp;
> +				return cp;
>  			}
>  		}
>  		ct_read_unlock_bh(idx);
> @@ -930,7 +934,8 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  {
>  	struct ip_vs_conn *cp = v;
>  	struct ip_vs_iter_state *iter = seq->private;
> -	struct list_head *e, *l = iter->l;
> +	struct hlist_node *e;
> +	struct hlist_head *l = iter->l;
>  	int idx;
>  
>  	++*pos;
> @@ -938,15 +943,15 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  		return ip_vs_conn_array(seq, 0);
>  
>  	/* more on same hash chain? */
> -	if ((e = cp->c_list.next) != l)
> -		return list_entry(e, struct ip_vs_conn, c_list);
> +	if ((e = cp->c_list.next))
> +		return hlist_entry(e, struct ip_vs_conn, c_list);
>  
>  	idx = l - ip_vs_conn_tab;
>  	ct_read_unlock_bh(idx);
>  
>  	while (++idx < ip_vs_conn_tab_size) {
>  		ct_read_lock_bh(idx);
> -		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> +		hlist_for_each_entry(cp, e, &ip_vs_conn_tab[idx], c_list) {
>  			iter->l = &ip_vs_conn_tab[idx];
>  			return cp;
>  		}
> @@ -959,7 +964,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
>  {
>  	struct ip_vs_iter_state *iter = seq->private;
> -	struct list_head *l = iter->l;
> +	struct hlist_head *l = iter->l;
>  
>  	if (l)
>  		ct_read_unlock_bh(l - ip_vs_conn_tab);
> @@ -1148,13 +1153,14 @@ void ip_vs_random_dropentry(struct net *net)
>  	 */
>  	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
>  		unsigned hash = net_random() & ip_vs_conn_tab_mask;
> +		struct hlist_node *n;
>  
>  		/*
>  		 *  Lock is actually needed in this loop.
>  		 */
>  		ct_write_lock_bh(hash);
>  
> -		list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +		hlist_for_each_entry(cp, n, &ip_vs_conn_tab[hash], c_list) {
>  			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
>  				/* connection template */
>  				continue;
> @@ -1202,12 +1208,14 @@ static void ip_vs_conn_flush(struct net *net)
>  
>  flush_again:
>  	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +		struct hlist_node *n;
> +
>  		/*
>  		 *  Lock is actually needed in this loop.
>  		 */
>  		ct_write_lock_bh(idx);
>  
> -		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> +		hlist_for_each_entry(cp, n, &ip_vs_conn_tab[idx], c_list) {
>  			if (!ip_vs_conn_net_eq(cp, net))
>  				continue;
>  			IP_VS_DBG(4, "del connection\n");
> @@ -1265,8 +1273,7 @@ int __init ip_vs_conn_init(void)
>  	/*
>  	 * Allocate the connection hash table and initialize its list heads
>  	 */
> -	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size *
> -				 sizeof(struct list_head));
> +	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size * sizeof(*ip_vs_conn_tab));
>  	if (!ip_vs_conn_tab)
>  		return -ENOMEM;
>  
> @@ -1286,9 +1293,8 @@ int __init ip_vs_conn_init(void)
>  	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
>  		  sizeof(struct ip_vs_conn));
>  
> -	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> -		INIT_LIST_HEAD(&ip_vs_conn_tab[idx]);
> -	}
> +	for (idx = 0; idx < ip_vs_conn_tab_size; idx++)
> +		INIT_HLIST_HEAD(&ip_vs_conn_tab[idx]);
>  
>  	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++)  {
>  		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
