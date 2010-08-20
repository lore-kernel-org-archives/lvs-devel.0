From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 21:44:08 +0800
Message-ID: <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
References: <20100820133320.GA29311@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:mime-version:received:in-reply-to
         :references:from:date:message-id:subject:to:cc:content-type
         :content-transfer-encoding;
        bh=IHwUIy2IIohDm1578sbTicKKYSOwJKH/3dS2qUlf12c=;
        b=BOwNqj7sVcJBFCZ7pmTyKELaBkmM+0fALJSoUUIC/FpqaIMcf7eB6CzCt2YWla5yC5
         ICavciaPIgZLo63/tBm2HIsorQ0ivZ/dmjfkMz7kgEWu/oZ/fC9KgMNLFLQqdMikFTus
         ivtY3XKAFGwaLCY4kHAwfrVZqwxzk2a13GMQE=
In-Reply-To: <20100820133320.GA29311@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
>
> I'm still getting my head around RCU, so review would be greatly appr=
eciated.
>
> It occurs to me that this code is not performance critical, so
> perhaps simply replacing the rwlock with a spinlock would be better?
>
> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c =A0 2010-08-20 =
22:21:01.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c =A0 =A0 =A0 =A02010-=
08-20 22:21:51.000000000 +0900
> @@ -35,7 +35,7 @@
> =A0static LIST_HEAD(ip_vs_schedulers);
>
> =A0/* lock for service table */
> -static DEFINE_RWLOCK(__ip_vs_sched_lock);
> +static DEFINE_SPINLOCK(ip_vs_sched_mutex);
>
>
> =A0/*
> @@ -91,9 +91,9 @@ static struct ip_vs_scheduler *ip_vs_sch
>
> =A0 =A0 =A0 =A0IP_VS_DBG(2, "%s(): sched_name \"%s\"\n", __func__, sc=
hed_name);
>
> - =A0 =A0 =A0 read_lock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 rcu_read_lock_bh();
>
> - =A0 =A0 =A0 list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
> + =A0 =A0 =A0 list_for_each_entry_rcu(sched, &ip_vs_schedulers, n_lis=
t) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Test and get the modules atomically
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> @@ -105,14 +105,14 @@ static struct ip_vs_scheduler *ip_vs_sch
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strcmp(sched_name, sched->name)=3D=
=3D0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* HIT */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_unlock_bh(&__ip_vs=
_sched_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock_bh();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return sched;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sched->module)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0module_put(sched->modu=
le);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 read_unlock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 rcu_read_unlock_bh();
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> @@ -167,10 +167,10 @@ int register_ip_vs_scheduler(struct ip_v
> =A0 =A0 =A0 =A0/* increase the module use count */
> =A0 =A0 =A0 =A0ip_vs_use_count_inc();
>
> - =A0 =A0 =A0 write_lock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 spin_lock_bh(&ip_vs_sched_mutex);
>
> =A0 =A0 =A0 =A0if (!list_empty(&scheduler->n_list)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_unlock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&ip_vs_sched_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_vs_use_count_dec();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s(): [%s] scheduler already l=
inked\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, scheduler->name=
);
> @@ -181,9 +181,9 @@ int register_ip_vs_scheduler(struct ip_v
> =A0 =A0 =A0 =A0 * =A0Make sure that the scheduler with this name does=
n't exist
> =A0 =A0 =A0 =A0 * =A0in the scheduler list.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
> + =A0 =A0 =A0 list_for_each_entry_rcu(sched, &ip_vs_schedulers, n_lis=
t) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strcmp(scheduler->name, sched->nam=
e) =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_unlock_bh(&__ip_v=
s_sched_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&ip_vs_s=
ched_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_vs_use_count_dec();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s(): [%s] sch=
eduler already existed "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "in the s=
ystem\n", __func__, scheduler->name);
> @@ -193,8 +193,8 @@ int register_ip_vs_scheduler(struct ip_v
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Add it into the d-linked scheduler list
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 list_add(&scheduler->n_list, &ip_vs_schedulers);
> - =A0 =A0 =A0 write_unlock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 list_add_rcu(&scheduler->n_list, &ip_vs_schedulers);
> + =A0 =A0 =A0 spin_unlock_bh(&ip_vs_sched_mutex);
>
> =A0 =A0 =A0 =A0pr_info("[%s] scheduler registered.\n", scheduler->nam=
e);
>
> @@ -212,9 +212,9 @@ int unregister_ip_vs_scheduler(struct ip
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 write_lock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 spin_lock_bh(&ip_vs_sched_mutex);
> =A0 =A0 =A0 =A0if (list_empty(&scheduler->n_list)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_unlock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&ip_vs_sched_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s(): [%s] scheduler is not in=
 the list. failed\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, scheduler->name=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -223,8 +223,8 @@ int unregister_ip_vs_scheduler(struct ip
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Remove it from the d-linked scheduler li=
st
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 list_del(&scheduler->n_list);
> - =A0 =A0 =A0 write_unlock_bh(&__ip_vs_sched_lock);
> + =A0 =A0 =A0 list_del_rcu(&scheduler->n_list);
> + =A0 =A0 =A0 spin_unlock_bh(&ip_vs_sched_mutex);

Need a rcu_barrier_bh().

>
> =A0 =A0 =A0 =A0/* decrease the module use count */
> =A0 =A0 =A0 =A0ip_vs_use_count_dec();



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
