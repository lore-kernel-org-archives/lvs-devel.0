From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 14:59:43 +0200
Message-ID: <1279803583.2467.43.camel@edumazet-laptop>
References: <27901279770680@web67.yandex.ru>
	 <1279781811.2405.15.camel@edumazet-laptop>
	 <20100722122422.GD16234@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=VaJztHLhtxjuyd6E70ctaGM8Ppf9ovKj6qbDxkXh21o=;
        b=Azh76iW5pVsFCfvWslc0Mhaw149EXUbXMUcDLFuAzVF60vZgCaitciPFdJ0JgJyNDp
         PUkxMSoZL4H/2ofy5rNEQ9PPplA0iRWP9g+yVSBb7lXTIEHOsu9eMFqGKECp3W+om6Iv
         PP8Es2vvDRo65p807xyp92D2B9ANwJQh+XHMo=
In-Reply-To: <20100722122422.GD16234@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 21:24 +0900, Simon Horman a =C3=A9crit =
:
> On Thu, Jul 22, 2010 at 08:56:51AM +0200, Eric Dumazet wrote:
>=20
> [snip]
>=20
> > lvs seems not very SMP friendly and a bit complex.
>=20
> I'd be interested to hear some thoughts on
> how the SMP aspect of that statement could
> be improved.

Hi Simon

I am not familiar with LVS code, so I am probably wrong, but it seems i=
t
could be changed a bit.

Some rwlocks might become spinlocks (faster than rwlocks)

__ip_vs_securetcp_lock for example is always used with
write_lock()/write_unlock().
This can be a regular spinlock without even knowing the code.

Some lookups could use RCU to avoid cache line misses, and to be able t=
o
use spinlocks for the write side.

It would be good to have a bench setup with the case of 16 legacy
daemons, and check how many new connections per second can be
established, in an LVS setup and an iptables based one.

With 2.6.35 and RPS, a REDIRECT based solution can chose the target por=
t
without taking any lock (not counting conntrack internal costs of
course), each cpu accessing local memory only.

# No need is eth0 is a multiqueue NIC
echo ffff >/sys/class/net/eth0/queues/rx-0/rps_cpus

for c in `seq 0 15`
do
  iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu $c -j
REDIRECT --to-port $((1000 + $c))
done



