Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D0933644A2;
	Tue, 14 Jul 2026 10:14:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784024089; cv=none; b=JKhAXk/AYvUhnPweAdpvn48JYE/v9cr3rj03iLnDNBouL41B/x05tWVRHbg72WDybyP/apsqZHWsUmeFHO6/eyoZnTfNAZa5uoaTXKUSvkiMz59O8Yx+NFzGhxMYnUCda3p5j+HpsJJyD4rnoPSrQ0/IzoW8X9W/QvUHvglJ69I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784024089; c=relaxed/simple;
	bh=k2y6eKRyQd9xitXlNB5vezm5h6JQXUgJ+EgHkABjhp0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=a9BfLbsy/pS5Xtgs6RE4NKNbAi+wfpQyjhMno7z/N5rI7zcCfym7jEx5cncv9vKnMTqRnEkebs/+gnO8SnnOSkCzU3NaSbu3dBCzWPLXKl4rdit1hlfs9Z7yyaYhUEOmwAX6kfIJO6ycUJtvnf7HoAKHkII16lLr0JOwTM5gUPM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DEgtHDY9; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DEgtHDY9"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 68AF221B1C;
	Tue, 14 Jul 2026 13:14:41 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=l90Arcdl3rLdnwFtQLT++L3suc3VBNLy1xRNB8kAmek=; b=DEgtHDY9Vrxz
	pgPKf2nWc4EqClUQAfu7VLX4/KIA9XSgE5yNCD58+NjbEb/yEa75f35xz60a1xHp
	prwU9RkpVoQUMxL/MABy+VFEz3fZjMPVE2LyoFAuDQjzCoUR4vFWBxHaQ1E/Ey2n
	yBjQgjM4t3M1+Ee7eDCEVCIN1I/z5iPdZfop/c844AUbupF6vWBxcYm+0p/MKN5U
	PUT2T9GPumSXgufLNx7SiqN0g2qs9JIYTE165Gbx3hrlSuHPBEDAXOjOjyl2Ez9Z
	RrW74kDOF4mBFr3GOOdTvrzQNEPczYYEjJE4WRiRG5Nf8rxXA+CbwzA5DO5p5wqb
	kU6xpyL/JrmNm7UQNJpRQVVz+Uabi42iVOiB95zVStu+VjJPBtYvkODygWQWUFQQ
	emh+iYDOZFd4C12mZt0ogEAlT3AnhH/P6wbxzaqh6rGWltI5rV1CzO78uDh4LJvZ
	dUd70X54UwcdxC8OeRoxSWHyw4dO+EQfp0NVMnou+Z656E9Y/CcRaNkntpplSDAH
	DsD6RvrXiwXmWmSdWYqFjxgn1SjRA6UpkP8Xm00OAiTBYqWSL2RKzxvVdtI0gFvD
	S40UvgIDjdmU+afBX6AG5ynX0TAVwmbwImuWPYMIbCT8wcuTRouh8swRatbZpJ6u
	3WkpsJLNhXgI4ljO3wjWcOgD9NajyEc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 14 Jul 2026 13:14:41 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id AA4EB60890;
	Tue, 14 Jul 2026 13:14:41 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66EAEdcR026482;
	Tue, 14 Jul 2026 13:14:39 +0300
Date: Tue, 14 Jul 2026 13:14:39 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <n05ec@lzu.edu.cn>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        nick@loadbalancer.org, kaber@trash.net, yuantan098@gmail.com,
        yifanwucs@gmail.com, tomapufckgml@gmail.com, bird@lzu.edu.cn,
        roxy520tt@gmail.com
Subject: Re: [PATCH v2 2/2] ipvs: adjust double hashing when fwd method
 changes
In-Reply-To: <f5b5a291ad1546ac9b3acd762f628a6c4c3b78ff.1783917666.git.roxy520tt@gmail.com>
Message-ID: <9ae3fcbe-ae51-ebde-7694-17ea73b29d89@ssi.bg>
References: <cover.1783917666.git.roxy520tt@gmail.com> <f5b5a291ad1546ac9b3acd762f628a6c4c3b78ff.1783917666.git.roxy520tt@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 13 Jul 2026, Ren Wei wrote:

> From: Julian Anastasov <ja@ssi.bg>
> 
> Synced conns can be created with one forwarding method
> and later updated with different one after the dest
> server is configured. This needs adjusting the hashing
> for node hn1 because only MASQ supports double hashing.
> 
> Modify conn_tab_lock() to support seeking for hash node
> hn0 together with adding for hn1. By this way we can
> safely modify the forwarding method and hn1.hash_key
> under bucket lock for the first node hn0. The forwarding
> method is also protected by cp->lock as it is part of
> cp->flags.
> 
> Fix the usage of stale idx/idx2 values in conn_tab_lock
> after jumping to the retry label. Instead, use idx/idx2
> values just to order the locking for the old/new tables.
> 
> Reported-by: Zhiling Zou <roxy520tt@gmail.com>
> Link: https://lore.kernel.org/lvs-devel/1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com/
> Link: https://sashiko.dev/#/patchset/CALMqdkR704S2BG_QD_bgHTFp2%2B1QCi7n0T4zoZyTo8mDZevYSA%40mail.gmail.com
> Fixes: f20c73b0460d ("ipvs: use more keys for connection hashing")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Pablo, Florian, this patch already has my

Signed-off-by: Julian Anastasov <ja@ssi.bg>

	and can be applied to the nf tree too.

	As for the other issues reported by Sashiko for the
first patch:

https://sashiko.dev/#/patchset/cover.1783917666.git.roxy520tt%40gmail.com

- the hashing is fixed by this 2nd patch

- packet_xmit needs additional fix, may be we should remove
the field from the structure, I'll provide additional patch
for this

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 189 +++++++++++++++++++++++++-------
>  1 file changed, 147 insertions(+), 42 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 0682cec5f0a7..36c5cba03f5b 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -70,25 +70,45 @@ static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
>   * bucket or hash table
>   * - hash table resize works like rehash but always rehashes into new table
>   * - bit lock on bucket serializes all operations that modify the chain
> + * - on resize, bucket from the old table is locked before bucket from the
> + * new table
>   * - cp->lock protects conn fields like cp->flags, cp->dest
>   */
>  
> -/* Lock conn_tab bucket for conn hash/unhash, not for rehash */
> +/**
> + * conn_tab_lock - Lock conn_tab buckets for conn hash/unhash, not for rehash
> + * @t:		hash table for hn0, new_tbl when new_hash=true
> + * @t2:		hash table for hn1, new_tbl when new_hash2=true
> + * @cp:		connection
> + * @hash_key:	hash key for hn0
> + * @hash_key2:	hash key for hn1
> + * @use2:	using hn1 (double hashing) based on the forwarding method
> + * @new_hash:	mode for hn0, hash node (true) or seek node (false)
> + * @new_hash2:	mode for hn1, hash node (true) or seek node (false)
> + * @head_ret:	returned head for hn0
> + * @head2_ret:	returned head for hn1
> + *
> + * We support 3 modes:
> + * - seek mode for both nodes, used for unhashing
> + * - hash mode for both nodes, used for hashing
> + * - seek hn0 and hash hn1, used when forwarding method is changed
> + */
>  static __always_inline void
> -conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_conn *cp, u32 hash_key,
> -	      u32 hash_key2, bool use2, bool new_hash,
> -	      struct hlist_bl_head **head_ret, struct hlist_bl_head **head2_ret)
> +conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_rht *t2, struct ip_vs_conn *cp,
> +	      u32 hash_key, u32 hash_key2, bool use2, bool new_hash,
> +	      bool new_hash2, struct hlist_bl_head **head_ret,
> +	      struct hlist_bl_head **head2_ret)
>  {
>  	struct hlist_bl_head *head, *head2;
>  	u32 hash_key_new, hash_key_new2;
> -	struct ip_vs_rht *t2 = t;
> -	u32 idx, idx2;
> +	int idx = 0, idx2 = 0;
> +
> +	/* Advance idx2 when new_hash is not set but hash_key2
> +	 * is for new table
> +	 */
> +	if (new_hash2 && use2 && t != t2)
> +		idx2++;
>  
> -	idx = hash_key & t->mask;
> -	if (use2)
> -		idx2 = hash_key2 & t->mask;
> -	else
> -		idx2 = idx;
>  	if (!new_hash) {
>  		/* We need to lock the bucket in the right table */
>  
> @@ -100,46 +120,45 @@ conn_tab_lock(struct ip_vs_rht *t, struct ip_vs_conn *cp, u32 hash_key,
>  			 * both nodes in different tables, use idx/idx2
>  			 * for proper lock ordering for heads.
>  			 */
> -			idx = hash_key & t->mask;
> -			idx |= IP_VS_RHT_TABLE_ID_MASK;
> -		}
> -		if (use2) {
> -			if (!ip_vs_rht_same_table(t2, hash_key2)) {
> -				/* It is already moved to new table */
> -				t2 = rcu_dereference(t2->new_tbl);
> -				idx2 = hash_key2 & t2->mask;
> -				idx2 |= IP_VS_RHT_TABLE_ID_MASK;
> -			}
> -		} else {
> -			idx2 = idx;
> +			idx++;
>  		}
>  	}
> +	if (use2 && !new_hash2 && !ip_vs_rht_same_table(t2, hash_key2)) {
> +		/* It is already moved to new table */
> +		t2 = rcu_dereference(t2->new_tbl);
> +		idx2++;
> +	}
>  
> +	if (!use2)
> +		idx2 = idx;
>  	head = t->buckets + (hash_key & t->mask);
>  	head2 = use2 ? t2->buckets + (hash_key2 & t2->mask) : head;
>  
> -	local_bh_disable();
> -	/* Do not touch seqcount, this is a safe operation */
> -
> -	if (idx <= idx2) {
> +	if (idx > idx2 || (head > head2 && idx == idx2)) {
> +		hlist_bl_lock(head2);
>  		hlist_bl_lock(head);
> -		if (head != head2)
> -			hlist_bl_lock(head2);
>  	} else {
> -		hlist_bl_lock(head2);
>  		hlist_bl_lock(head);
> +		if (head != head2)
> +			hlist_bl_lock(head2);
>  	}
>  	if (!new_hash) {
> +		bool changed;
> +
>  		/* Ensure hash_key is read under lock */
>  		hash_key_new = READ_ONCE(cp->hn0.hash_key);
> -		hash_key_new2 = READ_ONCE(cp->hn1.hash_key);
> +		changed = hash_key != hash_key_new;
> +		if (use2 && !new_hash2) {
> +			hash_key_new2 = READ_ONCE(cp->hn1.hash_key);
> +			changed |= hash_key2 != hash_key_new2;
> +		} else {
> +			hash_key_new2 = hash_key2;
> +		}
>  		/* Hash changed ? */
> -		if (hash_key != hash_key_new ||
> -		    (hash_key2 != hash_key_new2 && use2)) {
> +		if (changed) {
>  			if (head != head2)
>  				hlist_bl_unlock(head2);
>  			hlist_bl_unlock(head);
> -			local_bh_enable();
>  			hash_key = hash_key_new;
>  			hash_key2 = hash_key_new2;
>  			goto retry;
> @@ -155,7 +174,6 @@ static inline void conn_tab_unlock(struct hlist_bl_head *head,
>  	if (head != head2)
>  		hlist_bl_unlock(head2);
>  	hlist_bl_unlock(head);
> -	local_bh_enable();
>  }
>  
>  static void ip_vs_conn_expire(struct timer_list *t);
> @@ -268,8 +286,9 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  		use2 = false;
>  	}
>  
> -	conn_tab_lock(t, cp, hash_key, hash_key2, use2, true /* new_hash */,
> -		      &head, &head2);
> +	local_bh_disable();
> +	conn_tab_lock(t, t, cp, hash_key, hash_key2, use2, true /* new_hash */,
> +		      true /* new_hash2 */, &head, &head2);
>  
>  	cp->flags |= IP_VS_CONN_F_HASHED;
>  	WRITE_ONCE(cp->hn0.hash_key, hash_key);
> @@ -280,6 +299,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
>  
>  	conn_tab_unlock(head, head2);
> +	local_bh_enable();
>  	ret = 1;
>  
>  	/* Schedule resizing if load increases */
> @@ -306,18 +326,20 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
>  		return refcount_dec_if_one(&cp->refcnt);
>  
>  	rcu_read_lock();
> +	local_bh_disable();
>  
>  	t = rcu_dereference(ipvs->conn_tab);
>  	hash_key = READ_ONCE(cp->hn0.hash_key);
>  	hash_key2 = READ_ONCE(cp->hn1.hash_key);
>  	use2 = ip_vs_conn_use_hash2(cp);
>  
> -	conn_tab_lock(t, cp, hash_key, hash_key2, use2, false /* new_hash */,
> -		      &head, &head2);
> +	conn_tab_lock(t, t, cp, hash_key, hash_key2, use2, false /* new_hash */,
> +		      false /* new_hash2 */, &head, &head2);
>  
>  	if (cp->flags & IP_VS_CONN_F_HASHED) {
>  		/* Decrease refcnt and unlink conn only if we are last user */
> -		if (refcount_dec_if_one(&cp->refcnt)) {
> +		if (use2 == ip_vs_conn_use_hash2(cp) &&
> +		    refcount_dec_if_one(&cp->refcnt)) {
>  			hlist_bl_del_rcu(&cp->hn0.node);
>  			if (use2)
>  				hlist_bl_del_rcu(&cp->hn1.node);
> @@ -328,6 +350,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
>  
>  	conn_tab_unlock(head, head2);
>  
> +	local_bh_enable();
>  	rcu_read_unlock();
>  
>  	return ret;
> @@ -632,6 +655,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
>  	int ntbl;
>  	int dir;
>  
> +restart:
>  	/* No packets from inside, so we can do it in 2 steps. */
>  	dir = use2 ? 1 : 0;
>  
> @@ -686,6 +710,23 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
>  	/* Protect the cp->flags modification */
>  	spin_lock_bh(&cp->lock);
>  
> +	/* Recheck the forwarding method under lock */
> +	if (use2 != ip_vs_conn_use_hash2(cp)) {
> +		use2 = !use2;
> +		if (use2) {
> +			spin_unlock_bh(&cp->lock);
> +			/* Restart with new use2 value */
> +			goto restart;
> +		}
> +		if (dir) {
> +			/* Not started yet, so just skip dir 1 */
> +			spin_unlock_bh(&cp->lock);
> +			dir--;
> +			goto next_dir;
> +		}
> +		/* Just finish dir 0 */
> +	}
> +
>  	/* Lock seqcount only for the old bucket, even if we are on new table
>  	 * because it affects the del operation, not the adding.
>  	 */
> @@ -752,6 +793,61 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
>  		goto next_dir;
>  }
>  
> +/* Change forwarding method for hashed conn */
> +static void ip_vs_conn_change_fwd_mask(struct ip_vs_conn *cp, u32 new_flags)
> +{
> +	struct netns_ipvs *ipvs = cp->ipvs;
> +	struct hlist_bl_head *head, *head2;
> +	u32 hash2, hash_key, hash_key2;
> +	struct ip_vs_rht *t, *t2;
> +
> +	/* See ip_vs_conn_use_hash2() for reference */
> +	if ((cp->flags & IP_VS_CONN_F_TEMPLATE) ||
> +	    /* No change in double hashing ? */
> +	    (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ) ==
> +	    ((new_flags & IP_VS_CONN_F_FWD_MASK) == IP_VS_CONN_F_MASQ)) {
> +		cp->flags = new_flags;
> +		return;
> +	}
> +	t = rcu_dereference(ipvs->conn_tab);
> +	if (ip_vs_conn_use_hash2(cp)) {
> +		/* Stop double hashing */
> +		hash_key = READ_ONCE(cp->hn0.hash_key);
> +		hash_key2 = READ_ONCE(cp->hn1.hash_key);
> +
> +		conn_tab_lock(t, t, cp, hash_key, hash_key2, true /* use2 */,
> +			      false /* new_hash */, false /* new_hash2 */,
> +			      &head, &head2);
> +
> +		/* Keep both hash keys in same table */
> +		hash_key = READ_ONCE(cp->hn0.hash_key);
> +		WRITE_ONCE(cp->hn1.hash_key, hash_key);
> +		hlist_bl_del_rcu(&cp->hn1.node);
> +		cp->flags = new_flags;
> +
> +		conn_tab_unlock(head, head2);
> +	} else {
> +		/* Start double hashing */
> +
> +		hash_key = READ_ONCE(cp->hn0.hash_key);
> +
> +		t2 = rcu_dereference(t->new_tbl);
> +		hash2 = ip_vs_conn_hashkey_conn(t2, cp, true);
> +		hash_key2 = ip_vs_rht_build_hash_key(t2, hash2);
> +
> +		/* Change the forwarding method under locked hn0 */
> +		conn_tab_lock(t, t2, cp, hash_key, hash_key2, true /* use2 */,
> +			      false /* new_hash */, true /* new_hash2 */,
> +			      &head, &head2);
> +
> +		WRITE_ONCE(cp->hn1.hash_key, hash_key2);
> +		cp->flags = new_flags;
> +		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
> +
> +		conn_tab_unlock(head, head2);
> +	}
> +}
> +
>  /* Get default load factor to map conn_count/u_thresh to t->size */
>  static int ip_vs_conn_default_load_factor(struct netns_ipvs *ipvs)
>  {
> @@ -1024,9 +1120,18 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
>  		/* connections inherit forwarding method from dest */
>  		flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
> +		flags |= conn_flags;
> +		/* Changing forwarding method for hashed conn can
> +		 * happen only under locks
> +		 */
> +		if (cp->flags & IP_VS_CONN_F_HASHED)
> +			ip_vs_conn_change_fwd_mask(cp, flags);
> +		else
> +			cp->flags = flags;
> +	} else {
> +		flags |= conn_flags;
> +		cp->flags = flags;
>  	}
> -	flags |= conn_flags;
> -	cp->flags = flags;
>  	cp->dest = dest;
>  
>  	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

