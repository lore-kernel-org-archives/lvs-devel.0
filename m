From: yao zhao <dragonlinux@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 11:04:02 -0400
Message-ID: <AANLkTikCd_xCWUN+dkb_BkOrkBGSPe4xkmAebtgEiufy@mail.gmail.com>
References: <20100820133320.GA29311@verge.net.au>
	<AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
	<1282313150.2484.65.camel@edumazet-laptop>
	<AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
	<1282314765.2484.104.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=qXKDfQM2bUa6Xe1bXljqEiKUBBKck2ngRbOu0g4SGcQ=;
        b=WBg2UZH6KebvYxWATh8LIA5R2x/l1f+g3EnBPk+6M0kYbJUKJqpf1U/qHO2C6884n2
         v5mCCYnkXL6N9emZ62KbfSphipjm2FHsRTKgVcJlKOkcXFe3osrvLY1N/DAaGA2itMgs
         BmNqN9pfS76zGUkbxQiT21cpM8njdXrRQTZDk=
In-Reply-To: <1282314765.2484.104.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

On Fri, Aug 20, 2010 at 10:32 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 20 ao=FBt 2010 =E0 10:16 -0400, yao zhao a =E9crit :
>
>> if it is not performance critical, you should use =A0the
>> read_lock/write_lock, it should make the readers happier than
>> spinlock. the name "mutex" is a little bit confuse.
>
> Yes, I mentioned the 'mutex' name oddity.
>
> Point is :
>
> We want to remove read_write locks. They dont fit the bill.
>
> If performance critical, lot of readers -> RCU (a lot faster)
> If not, or too much writers versus readers -> spinlock (a bit faster)
>
>
for writers more than readers of course spin will be better, that is
what read/write lock for and spin for.
But the case here is whether these register_ip_vs_scheduler or
unregister are more frequent than the readers.
if not definitely read_lock will better than spin_lock. although worse =
than rcu.
>
>> synchronize_rcu() is not necessary when you only need to delete from=
 a
>> list as it is atomic.
>>
>
> Thats a rather strange and completely wrong claim. A big part of RCU =
job
> is to have appropriate work done on deletes. Inserts are more easy (o=
nly
> needs a smp_wmb())
>
> Take a look at Documentation/RCU/* before saying such things ;)
>
> Not only synchronize_rcu() is not enough to protect this kind of code=
,
> but you need something stronger.
>
>
>
The code here is deleting a global from the list, am I right? I didn't
see any called case.
what are you going to do more? free it? write_unlock_bh should make the=
 mb.

yao
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
