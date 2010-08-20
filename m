From: yao zhao <dragonlinux@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 10:16:23 -0400
Message-ID: <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
References: <20100820133320.GA29311@verge.net.au>
	<AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
	<1282313150.2484.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=DqpB/gHPdTa/Ad2lYbI71mqKAwjOMYj48k2qE0dUb60=;
        b=EY5eCIssHjGQpviUa/aUIq5sT4HkTeNeuzu04OP5EPhdGXfPnSBnuVpSaH6wvkjjFr
         pXkTu/Aq32eebsW5aOKUzkXT7BaEfuGu+p+YnzFIT9Ue5k5y8bGncaPpUAuF++YUJ1bo
         qR0cNjl3BBKlOzt+8CrwXwSxIjRDhdNtQPX5I=
In-Reply-To: <1282313150.2484.65.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 10:05 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 20 ao=FBt 2010 =E0 21:44 +0800, Changli Gao a =E9crit :
>> On Fri, Aug 20, 2010 at 9:33 PM, Simon Horman <horms@verge.net.au> w=
rote:
>> > Signed-off-by: Simon Horman <horms@verge.net.au>
>> >
>> > ---
>> >
>> > I'm still getting my head around RCU, so review would be greatly a=
ppreciated.
>> >
>> > It occurs to me that this code is not performance critical, so
>> > perhaps simply replacing the rwlock with a spinlock would be bette=
r?
>> >
>> > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
>
>
>> > - =A0 =A0 =A0 write_unlock_bh(&__ip_vs_sched_lock);
>> > + =A0 =A0 =A0 list_del_rcu(&scheduler->n_list);
>> > + =A0 =A0 =A0 spin_unlock_bh(&ip_vs_sched_mutex);
>>
>> Need a rcu_barrier_bh().
>>
>> >
>> > =A0 =A0 =A0 =A0/* decrease the module use count */
>> > =A0 =A0 =A0 =A0ip_vs_use_count_dec();
>
>
> Quite frankly, if this is not performance critical, just use the
> spinlock (and dont use 'mutex' in its name ;) )
>
if it is not performance critical, you should use  the
read_lock/write_lock, it should make the readers happier than
spinlock. the name "mutex" is a little bit confuse.
synchronize_rcu() is not necessary when you only need to delete from a
list as it is atomic.

> Using RCU here will force at least one RCU grace period at dismantle
> time...
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

yao
