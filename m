From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] IPVS: Convert connection table lock over to RCU
Date: Fri, 26 Feb 2010 14:57:18 +0100
Message-ID: <1267192638.9082.9.camel@edumazet-laptop>
References: <20100226030054.GA6111@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=2S7DNwucd6Cbpvn7dCqSFW7JygH7pRu+PngWFiSOvXo=;
        b=f6AAvf2ldJhkqMmdXA2/kaLcyv6+6nJIOobQi6tGfdNFlaC72K4xQHR8Mf+zB6eGDU
         1oDX8fwGWV59X7SJWo8l/c+Hohet/ZzdIflLFXk1kE78/5+QvMfzVUqtOKWT139Q1Ajy
         Rk7ASR2Rbmj1f6P410Pv4OsWBDISTSAQh3ZOE=
In-Reply-To: <20100226030054.GA6111@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 14:00 +1100, Simon Horman a =C3=
=A9crit :
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> ---=20
>=20
> This seems to be a fairly clean conversion to me. But its my journey
> into the world of RCU, so I would appreciate a careful review.
>=20
> I have deliberately introduced some noise into this patch
> in the form of changing the name of some global variables and functio=
ns.
> This is in order to clearly highlight changes at the call-sites.
>=20
> The table of 16 locks (4 bits) used for the connection table seems
> to be somewhat arbitrary to me, this patch intentionally leaves
> that as is.
>=20
> Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-02-26 10:4=
2:16.000000000 +1100
> +++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-02-26 10:52:32.=
000000000 +1100
> @@ -35,6 +35,8 @@
>  #include <linux/seq_file.h>
>  #include <linux/jhash.h>
>  #include <linux/random.h>
> +#include <linux/spinlock.h>
> +#include <linux/rculist.h>
> =20
>  #include <net/net_namespace.h>
>  #include <net/ip_vs.h>
> @@ -75,57 +77,37 @@ static unsigned int ip_vs_conn_rnd;
>  /*
>   *  Fine locking granularity for big connection hash table
>   */
> -#define CT_LOCKARRAY_BITS  4
> -#define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
> -#define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
> +#define CT_MUTEX_BITS  4
> +#define CT_MUTEX_SIZE  (1<<CT_MUTEX_BITS)
> +#define CT_MUTEX_MASK  (CT_MUTEX_SIZE-1)
> =20
> -struct ip_vs_aligned_lock
> +struct ip_vs_aligned_spinlock
>  {
> -	rwlock_t	l;
> +	spinlock_t	l;
>  } __attribute__((__aligned__(SMP_CACHE_BYTES)));
> =20
> -/* lock array for conn table */
> -static struct ip_vs_aligned_lock
> -__ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;
> +/* mutex array for connection table */
> +static struct ip_vs_aligned_spinlock
> +__ip_vs_conntbl_mutex[CT_MUTEX_SIZE] __cacheline_aligned;
> =20
> -static inline void ct_read_lock(unsigned key)
> +static inline void ct_mutex_lock(unsigned key)
>  {
> -	read_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
> +	spin_lock(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
>  }
> =20
> -static inline void ct_read_unlock(unsigned key)
> +static inline void ct_mutex_unlock(unsigned key)
>  {
> -	read_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
> +	spin_unlock(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
>  }
> =20
> -static inline void ct_write_lock(unsigned key)
> +static inline void ct_mutex_lock_bh(unsigned key)
>  {
> -	write_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
> +	spin_lock_bh(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
>  }
> =20
> -static inline void ct_write_unlock(unsigned key)
> +static inline void ct_mutex_unlock_bh(unsigned key)
>  {
> -	write_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
> -}
> -
> -static inline void ct_read_lock_bh(unsigned key)
> -{
> -	read_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
> -}
> -
> -static inline void ct_read_unlock_bh(unsigned key)
> -{
> -	read_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l=
);
> -}
> -
> -static inline void ct_write_lock_bh(unsigned key)
> -{
> -	write_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l)=
;
> -}
> -
> -static inline void ct_write_unlock_bh(unsigned key)
> -{
> -	write_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].=
l);
> +	spin_unlock_bh(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
>  }
> =20
>=20
> @@ -155,27 +137,27 @@ static unsigned int ip_vs_conn_hashkey(i
>  static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  {
>  	unsigned hash;
> -	int ret;
> =20
>  	/* Hash by protocol, client address and port */
>  	hash =3D ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->c=
port);
> =20
> -	ct_write_lock(hash);
> +	ct_mutex_lock(hash);
> =20
>  	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
> -		list_add(&cp->c_list, &ip_vs_conn_tab[hash]);
> +		list_add_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
>  		cp->flags |=3D IP_VS_CONN_F_HASHED;
>  		atomic_inc(&cp->refcnt);
> -		ret =3D 1;
> -	} else {
> -		pr_err("%s(): request for already hashed, called from %pF\n",
> -		       __func__, __builtin_return_address(0));
> -		ret =3D 0;
> +		ct_mutex_unlock(hash);
> +		synchronize_rcu();

Why is synchronize_rcu() necessary here ?

When adding a new item in a list, you dont need any rcu grace period.

> +		return 1;
>  	}
> =20
> -	ct_write_unlock(hash);
> +	ct_mutex_unlock(hash);
> =20
> -	return ret;
> +	pr_err("%s(): request for already hashed, called from %pF\n",
> +	       __func__, __builtin_return_address(0));
> +
> +	return 0;
>  }
> =20
>=20
> @@ -186,24 +168,24 @@ static inline int ip_vs_conn_hash(struct
>  static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
>  {
>  	unsigned hash;
> -	int ret;
> =20
>  	/* unhash it and decrease its reference counter */
>  	hash =3D ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->c=
port);
> =20
> -	ct_write_lock(hash);
> +	ct_mutex_lock(hash);
> =20
>  	if (cp->flags & IP_VS_CONN_F_HASHED) {
> -		list_del(&cp->c_list);
> +		list_del_rcu(&cp->c_list);
>  		cp->flags &=3D ~IP_VS_CONN_F_HASHED;
>  		atomic_dec(&cp->refcnt);
> -		ret =3D 1;
> -	} else
> -		ret =3D 0;
> +		ct_mutex_unlock(hash);
> +		synchronize_rcu();

Are you sure we can afford a synchronize_rcu() call here ?

This is a very long primitive, and I bet this is not acceptable for IPV=
S
use case.

> +		return 1;
> +	}
> =20
> -	ct_write_unlock(hash);
> +	ct_mutex_unlock(hash);
> =20
> -	return ret;
> +	return 0;
>  }
> =20
>=20
> @@ -222,9 +204,9 @@ static inline struct ip_vs_conn *__ip_vs
> =20
>  	hash =3D ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
> =20
> -	ct_read_lock(hash);
> +	rcu_read_lock();
> =20
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af =3D=3D af &&
>  		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
>  		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
> @@ -233,12 +215,12 @@ static inline struct ip_vs_conn *__ip_vs
>  		    protocol =3D=3D cp->protocol) {
>  			/* HIT */
>  			atomic_inc(&cp->refcnt);
> -			ct_read_unlock(hash);
> +			rcu_read_unlock();
>  			return cp;
>  		}
>  	}
> =20
> -	ct_read_unlock(hash);
> +	rcu_read_unlock();
> =20
>  	return NULL;
>  }
> @@ -273,9 +255,9 @@ struct ip_vs_conn *ip_vs_ct_in_get
> =20
>  	hash =3D ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
> =20
> -	ct_read_lock(hash);
> +	rcu_read_lock();
> =20
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af =3D=3D af &&
>  		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
>  		    /* protocol should only be IPPROTO_IP if
> @@ -293,7 +275,7 @@ struct ip_vs_conn *ip_vs_ct_in_get
>  	cp =3D NULL;
> =20
>    out:
> -	ct_read_unlock(hash);
> +	rcu_read_unlock();
> =20
>  	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
>  		      ip_vs_proto_name(protocol),
> @@ -322,9 +304,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
>  	 */
>  	hash =3D ip_vs_conn_hashkey(af, protocol, d_addr, d_port);
> =20
> -	ct_read_lock(hash);
> +	rcu_read_lock();
> =20
> -	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> +	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
>  		if (cp->af =3D=3D af &&
>  		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
>  		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
> @@ -337,7 +319,7 @@ struct ip_vs_conn *ip_vs_conn_out_get
>  		}
>  	}
> =20
> -	ct_read_unlock(hash);
> +	rcu_read_unlock();
> =20
>  	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
>  		      ip_vs_proto_name(protocol),
> @@ -776,14 +758,16 @@ static void *ip_vs_conn_array(struct seq
>  	struct ip_vs_conn *cp;
> =20
>  	for (idx =3D 0; idx < ip_vs_conn_tab_size; idx++) {
> -		ct_read_lock_bh(idx);
> -		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> +		rcu_read_lock_bh();
> +		list_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
>  			if (pos-- =3D=3D 0) {
>  				seq->private =3D &ip_vs_conn_tab[idx];
> +				/* N.B: no rcu_read_unlock_bh() here
> +				 *      Seems really horrible :-( */
>  				return cp;
>  			}
>  		}
> -		ct_read_unlock_bh(idx);
> +		rcu_read_unlock_bh();
>  	}
> =20
>  	return NULL;
> @@ -807,19 +791,22 @@ static void *ip_vs_conn_seq_next(struct
> =20
>  	/* more on same hash chain? */
>  	if ((e =3D cp->c_list.next) !=3D l)
> -		return list_entry(e, struct ip_vs_conn, c_list);
> +		return list_entry_rcu(e, struct ip_vs_conn, c_list);
> =20
>  	idx =3D l - ip_vs_conn_tab;
> -	ct_read_unlock_bh(idx);
> +	rcu_read_unlock_bh();
> =20
>  	while (++idx < ip_vs_conn_tab_size) {
> -		ct_read_lock_bh(idx);
> -		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> +		rcu_read_lock_bh();
> +		list_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
>  			seq->private =3D &ip_vs_conn_tab[idx];
> +			/* N.B: no rcu_read_unlock_bh() here
> +			 *      Seems really horrible :-( */

=2E.. if you add a comment, please write why you need to keep rcu locke=
d
=2E.. or dont add a comment, since this construct is quite common.



