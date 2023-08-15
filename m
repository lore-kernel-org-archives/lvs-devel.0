From: "Paul E. McKenney" <paulmck@kernel.org>
Subject: Re: [PATCH RFC net-next 01/14] rculist_bl: add
 hlist_bl_for_each_entry_continue_rcu
Date: Tue, 15 Aug 2023 11:39:43 -0700
Message-ID: <958d687d-9f7f-4baf-af26-2ec351ef8699@paulmck-laptop>
References: <20230815173031.168344-1-ja@ssi.bg>
 <20230815173031.168344-2-ja@ssi.bg>
Reply-To: paulmck@kernel.org
Mime-Version: 1.0
Return-path: <netdev+bounces-27769-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1692124784;
	bh=Pgizj0LFdMrJQmmpDQUSLN1qFP0xOur9LnBf40ch4vM=;
	h=Date:From:To:Cc:Subject:Reply-To:References:In-Reply-To:From;
	b=h5A0+8gj8pfZVw52EdSoZq3KmyXa1EZptPQKeimmZyvCGh/jCp5aaiSU6II6Ju4sg
	 c1/+BHDfpXOWA710NI8DBUcXp7cqPKYjxMx+09WKZdc5uYVaVFtY5kte1D5znCunw0
	 WfVQ6g591PlfhjPnE+q2wOQ2LUUw50p96HK2Q5j5pU193PEN/yOIZhJ3CRY6kMldKr
	 MD0uh1EtXO71LHfKjNGHajVN66K0ltMsFb/D6a9aF1RGKHzfkKeoO5qRLrqS7Y+Iit
	 4/Ln4Ov1lQ+2X8COKJrQp575/+3r/YkCI5c7fQa8Lhxhi+XYtZZBQa4QZseX794M0/
	 OhY2T9mnbVYng==
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20230815173031.168344-2-ja@ssi.bg>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, rcu@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>, Jiejian Wu <jiejian@linux.alibaba.com>, Jiri Wiesner <jwiesner@suse.de>

On Tue, Aug 15, 2023 at 08:30:18PM +0300, Julian Anastasov wrote:
> Add hlist_bl_for_each_entry_continue_rcu and hlist_bl_next_rcu
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/linux/rculist_bl.h | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/include/linux/rculist_bl.h b/include/linux/rculist_bl.h
> index 0b952d06eb0b..93a757793d83 100644
> --- a/include/linux/rculist_bl.h
> +++ b/include/linux/rculist_bl.h
> @@ -24,6 +24,10 @@ static inline struct hlist_bl_node *hlist_bl_first_rcu(struct hlist_bl_head *h)
>  		((unsigned long)rcu_dereference_check(h->first, hlist_bl_is_locked(h)) & ~LIST_BL_LOCKMASK);
>  }
>  
> +/* return the next element in an RCU protected list */
> +#define hlist_bl_next_rcu(node)	\
> +	(*((struct hlist_bl_node __rcu **)(&(node)->next)))
> +
>  /**
>   * hlist_bl_del_rcu - deletes entry from hash list without re-initialization
>   * @n: the element to delete from the hash list.
> @@ -98,4 +102,17 @@ static inline void hlist_bl_add_head_rcu(struct hlist_bl_node *n,
>  		({ tpos = hlist_bl_entry(pos, typeof(*tpos), member); 1; }); \
>  		pos = rcu_dereference_raw(pos->next))
>  
> +/**
> + * hlist_bl_for_each_entry_continue_rcu - iterate over a list continuing after
> + *   current point

Please add a comment to the effect that the element continued from
must have been either: (1) Iterated to within the same RCU read-side
critical section or (2) Nailed down using some lock, reference count,
or whatever suffices to keep the continued-from element from being freed
in the meantime.

							Thanx, Paul

> + * @tpos:	the type * to use as a loop cursor.
> + * @pos:	the &struct hlist_bl_node to use as a loop cursor.
> + * @member:	the name of the hlist_bl_node within the struct.
> + */
> +#define hlist_bl_for_each_entry_continue_rcu(tpos, pos, member)		\
> +	for (pos = rcu_dereference_raw(hlist_bl_next_rcu(&(tpos)->member)); \
> +	     pos &&							\
> +	     ({ tpos = hlist_bl_entry(pos, typeof(*tpos), member); 1; }); \
> +	     pos = rcu_dereference_raw(hlist_bl_next_rcu(pos)))
> +
>  #endif
> -- 
> 2.41.0
> 
> 

