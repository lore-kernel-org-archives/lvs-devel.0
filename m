From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Mon, 26 Aug 2013 12:55:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308261155520.1860@ja.ssi.bg>
References: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com> <alpine.LFD.2.00.1308220925340.1727@ja.ssi.bg> <CAJiejCSdfBKC3c1dqya55R5T0VBCTm3qaM6nL-CY+H0o5hbwoA@mail.gmail.com> <alpine.LFD.2.00.1308221558160.2993@ja.ssi.bg>
 <CAJiejCT-WemVeAkWoDib2ZXHLRj=Lme3-Lk=prOOVKL=w3vA5A@mail.gmail.com> <alpine.LFD.2.00.1308231708450.1852@ja.ssi.bg> <CAJiejCRKMe=tHdre0DY5=B70FnLV29tvLimW7K____0VPcW=Xg@mail.gmail.com> <alpine.LFD.2.00.1308241543030.1976@ja.ssi.bg>
 <CAJiejCTBmSqog3WrfbgD9Cw6e4wXGCyhJX+cKvFbv9Dg=zF_AA@mail.gmail.com> <CAJiejCSZKAZz0cmsys-xfuNUOQPD3qvEkR-Bm_X7aEF0aPu97w@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAJiejCSZKAZz0cmsys-xfuNUOQPD3qvEkR-Bm_X7aEF0aPu97w@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Drunkard Zhang <gongfan193@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 26 Aug 2013, Drunkard Zhang wrote:

> Good news, I finally found the crap source, it's keepalived. I tested
> several times without keepalived in runlevel 3, after kernel boots I
> add the ipvs service by hand:

	OK, I was worried that my recent RCU changes broke
something in the WRR scheduler and the configuration process.

> ./ipvsadm -C
> # Clear previous log
> > /var/log/kern.log
> sleep 1
> # Start debug
> echo 20 > /proc/sys/net/ipv4/vs/debug_level
> ./ipvsadm -R < /etc/keepalived/rules-with-ops
> usleep 30000
> # Stop debug
> echo 0 > /proc/sys/net/ipv4/vs/debug_level
> 
> Then add VIP manually, then do ARP announce manually:
> vs3 ~/pkgs # ip a add 150.164.100.120/32 dev eno1
> vs3 ~/pkgs # arp-sk -i eno1 -S 150.164.100.120:90:b1:1c:1a:59:46 -d
> 150.164.100.126
> 
> After these actions, traffic starts come in. and all ipvsadm checks
> are fine, OPS is fine too. So I figured that maybe outdated libipvs in
> keepalived broke the ipvs in kernel. I'll try to report this to
> upstream.

	OK, I have no more doubts. To summarize,
here is what I think happened:

- packet is scheduled while there is virtual service without
the --ops flag. The result is that an UDP connection is
created that expires after 5mins by default, if there are
no more packets.

- traffic is not stopped, it hits the connection and
restarts its timer. As result, this connection stays
forever and forwards traffic to single server.

- as single connection is used we see that the stats for
Conns and CPS rate do not move because we do not create
connections anymore, all traffic comes from single client
address and the scheduler is not called.

- there is one variation here: ipvsadm -C is called,
dests are moved to the trash list, new rules are
added but before the RCU grace period is expired.
In such case IP_VS_DEST_STATE_REMOVING is still set and
prevents the same dest to be reused when adding the
same dest parameters. In this case the connection will point
to unavailable dest for 5mins and the traffic that hits it
will not restart its timer. After 5mins the connection
will be removed and the first packet that comes
will use the --ops flag. There is a chance everything
to work. So, if new rules are added we have 2
situations:

	1. rules reuse old dests and traffic goes to single server.
	This happens if the new rules are added after at least
	10ms (the RCU grace period, in fact), eg. with
	usleep 10000 after ipvsadm -C. We have CPS=0 and
	InPPS above 0 for single server.

	2. rules allocate new dest and traffic is stopped
	for 5mins. This will happen if rules are added
	immediately after ipvsadm -C (while in RCU grace period).
	After 5mins everything works.

- CPS 0 means we are reusing existing connection

- even if you replace the service or set --ops, the
existing connection is still used, even ipvsadm -C
can not remove it. There is only one chance: to set
expire_nodest_conn=1, to call ipvsadm -C and to wait
next packet to remove the connection. Then to add
all rules again but not before the connection is removed.

> On the other hand, ipvs didn't recovery from ipvsadm -C, rmmod ip_vs
> && ./ipvsadm -R < rules-with-ops is needed (I tested, reload ip_vs
> module could make OPS work). So robustness of IPVS needs improvement.

	Some problem? May be you refer to the fact that
connections survive ipvsadm -C and that is what prevented
your traffic to be scheduled.

	So, I see two problems here:

- tools do not set --ops, connection is created and is
reused from all packets from same client. The trick
to add --ops later can not work. Idea: drop traffic
before reaching IPVS (-j DROP) until --ops is applied,
by this way no connections should be created.

- no way to flush connections in IPVS without removing the
module because expire_nodest_conn works only when traffic is
received. I think, your above remark points here.

Regards

--
Julian Anastasov <ja@ssi.bg>
