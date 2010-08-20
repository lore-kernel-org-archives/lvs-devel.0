From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 17:32:17 +0200
Message-ID: <1282318337.2484.219.camel@edumazet-laptop>
References: <20100820133320.GA29311@verge.net.au>
	 <AANLkTimS7V3z1kEwmEFCCvPzJX=D9Oqw=BNEuN-YZ0tx@mail.gmail.com>
	 <1282313150.2484.65.camel@edumazet-laptop>
	 <AANLkTi=t7wDZO23Cim1LJ_Ot2FUe4bR+XG6H5uJfTuG+@mail.gmail.com>
	 <1282314765.2484.104.camel@edumazet-laptop>
	 <AANLkTikCd_xCWUN+dkb_BkOrkBGSPe4xkmAebtgEiufy@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=4TRmlVIVsGon3Y3/7ysnRSHU8xCWW7AQfjsAFVQ7krQ=;
        b=QVul0wTfLuvABq9LjVJXI86IMVwpMfdBTrbPKinX4tcmElVprNdzkPpTd0RXnDdXQw
         yf4FA7Woz0AL8mUikllMFajVLik63CLku8Z/030egHVMHRKKZGpX8GjuAdDGZi3DhFDe
         7AOWbKocIz1FHUlbCqvnVtw7iayrKZVME7wwk=
In-Reply-To: <AANLkTikCd_xCWUN+dkb_BkOrkBGSPe4xkmAebtgEiufy@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: yao zhao <dragonlinux@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Paul E McKenney <paulmck@linux.vnet.ibm.com>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 11:04 -0400, yao zhao a =C3=A9crit=
 :

> The code here is deleting a global from the list, am I right? I didn'=
t
> see any called case.
> what are you going to do more? free it? write_unlock_bh should make t=
he mb.


If you dont wait _after_ delete from list and following actions=20
(kfree() without a call_rcu(), or module unload, or whatever), a reader
might access your data/code and crash the box.

spin_unlock_bh() wont help you at all, since only writers are freezed b=
y
the lock (since readers only hold rcu_lock)

Documentation/RCU/whatisRCU.txt line 705

Documentation/RCU/checklist.txt  15)



