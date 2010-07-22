From: Simon Horman <horms@verge.net.au>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 22:20:04 +0900
Message-ID: <20100722132003.GA28362@verge.net.au>
References: <27901279770680@web67.yandex.ru>
 <1279781811.2405.15.camel@edumazet-laptop>
 <20100722122422.GD16234@verge.net.au>
 <1279803583.2467.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1279803583.2467.43.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Jul 22, 2010 at 02:59:43PM +0200, Eric Dumazet wrote:
> Le jeudi 22 juillet 2010 =C3=A0 21:24 +0900, Simon Horman a =C3=A9cri=
t :
> > On Thu, Jul 22, 2010 at 08:56:51AM +0200, Eric Dumazet wrote:
> >=20
> > [snip]
> >=20
> > > lvs seems not very SMP friendly and a bit complex.
> >=20
> > I'd be interested to hear some thoughts on
> > how the SMP aspect of that statement could
> > be improved.
>=20
> Hi Simon
>=20
> I am not familiar with LVS code, so I am probably wrong, but it seems=
 it
> could be changed a bit.
>=20
> Some rwlocks might become spinlocks (faster than rwlocks)
>=20
> __ip_vs_securetcp_lock for example is always used with
> write_lock()/write_unlock().
> This can be a regular spinlock without even knowing the code.

I'll get that fixed.

> Some lookups could use RCU to avoid cache line misses, and to be able=
 to
> use spinlocks for the write side.

Agreed. I took a look at RCUing things a while back, but got bogged
down and then forgot about it. I'll take anther stab at it.

> It would be good to have a bench setup with the case of 16 legacy
> daemons, and check how many new connections per second can be
> established, in an LVS setup and an iptables based one.
>=20
> With 2.6.35 and RPS, a REDIRECT based solution can chose the target p=
ort
> without taking any lock (not counting conntrack internal costs of
> course), each cpu accessing local memory only.
>=20
> # No need is eth0 is a multiqueue NIC
> echo ffff >/sys/class/net/eth0/queues/rx-0/rps_cpus
>=20
> for c in `seq 0 15`
> do
>   iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu $c -j
> REDIRECT --to-port $((1000 + $c))
> done

Its hard for lvs to compete with those kind of lightweight solutions an=
d
it probably shouldn't. However, I'd just like to see LVS working as
well as it can within the constraint that, as you pointed out, its rath=
er
complex. Thanks for your suggestions.

