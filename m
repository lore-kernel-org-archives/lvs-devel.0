From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 08:56:51 +0200
Message-ID: <1279781811.2405.15.camel@edumazet-laptop>
References: <27901279770680@web67.yandex.ru>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=WbNccWc40gcKT6rQdMo+YaPiYMe0GQE7EwN3Ks796i8=;
        b=N2y/rlpXg6jyQ4pJSTEAu7YxAjZR1ybKbokWwO0rBnATnq9mNDT4cIyXl6SLrfQoeg
         uOKWBGs1v1lebphPUHEBNn14Lob00caczCANco/UKDxLMSm1csvX3A3fTt7tbxHCTQt8
         74TRKalSbNJAEKMEOdF8gJC0K9IdPv0NQAK5o=
In-Reply-To: <27901279770680@web67.yandex.ru>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Franchoze Eric <franchoze@yandex.ru>
Cc: wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 07:51 +0400, Franchoze Eric a =C3=A9cri=
t :
> Hello,
>=20
> I'm trying to do load balancing of incoming traffic to my application=
s. This applications are not very  smp friendly, and I want try to run =
some instances according to number of cpus on single machine. And balan=
ce load of incoming traffic/connections to this applications.
> Looks like is should be similar to http://www.austintek.com/LVS/LVS-H=
OWTO/HOWTO/LVS-HOWTO.localnode.html
>=20
>  linux kernel 2.6.32 with  or without hide interface patches.  Tried =
different configurations but could not see packets on application layer=
=2E
>=20
> 192.168.1.165 - eth0 - interface for external connections
> 195.0.0.1 - dummy0 - virtual interface, real application is binded to=
 that address.
>=20
> Configuration is:
> -A -t 192.168.1.165:1234 -s wlc
> -a -t 192.168.1.165:1234 -r 195.0.0.1:1234 -g -w
>=20
> #ipvsadm -L -n
> IP Virtual Server version 1.2.1 (size=3D4096)
> Prot LocalAddress:Port Scheduler Flags
>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> TCP  192.168.1.165:1234 wlc
>   -> 195.0.0.1:1234               Local   1      0          0       =20
> #
>=20
> Log:
> [ 2106.897409] IPVS: lookup/out TCP 192.168.1.165:44847->192.168.1.16=
5:1234 not hit
> [ 2106.897412] IPVS: lookup service: fwm 0 TCP 192.168.1.165:1234 hit
> [ 2106.897414] IPVS: ip_vs_wlc_schedule(): Scheduling...
> [ 2106.897416] IPVS: WLC: server 195.0.0.1:1234 activeconns 0 refcnt =
2 weight 1 overhead 1
> [ 2106.897418] IPVS: Enter: ip_vs_conn_new, net/netfilter/ipvs/ip_vs_=
conn.c line 693
> [ 2106.897421] IPVS: Bind-dest TCP c:192.168.1.165:44847 v:192.168.1.=
165:1234 d:195.0.0.1:1234 fwd:L s:0 conn->flags:181 conn->refcnt:1 dest=
->refcnt:3
> [ 2106.897425] IPVS: Schedule fwd:L c:192.168.1.165:44847 v:192.168.1=
=2E165:1234 d:195.0.0.1:1234 conn->flags:1C1 conn->refcnt:2
> [ 2106.897429] IPVS: TCP input  [S...] 195.0.0.1:1234->192.168.1.165:=
44847 state: NONE->SYN_RECV conn->refcnt:2
> [ 2106.897431] IPVS: Enter: ip_vs_null_xmit, net/netfilter/ipvs/ip_vs=
_xmit.c line 212
> [ 2106.897439] IPVS: lookup/in TCP 192.168.1.165:1234->192.168.1.165:=
44847 not hit
> [ 2106.897441] IPVS: lookup/out TCP 192.168.1.165:1234->192.168.1.165=
:44847 not hit
> [ 2107.277535] IPVS: packet type=3D1 proto=3D17 daddr=3D255.255.255.2=
55 ignored
> [ 2108.542691] IPVS: packet type=3D1 proto=3D17 daddr=3D192.168.1.255=
 ignored
>=20
> As the result, server application does receive anything on accept(). =
I tried to make dummy0 a hidden device and play with arp settings. But =
without result.
>=20
> I will be happy to hear any idea how to do connection in this environ=
ment.
>=20

lvs seems not very SMP friendly and a bit complex.

I would use an iptables setup and a slighly modified REDIRECT target
(and/or a nf_nat_setup_info() change)

Say you have 8 daemons listening on different ports (1000 to 1007)

iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --rxhash-=
dist --to-port 1000-1007

rxhash would be provided by RPS on recent kernels or locally computed i=
f
not already provided by core network (or old kernel)

This rule would be triggered only at connection establishment.
conntracking take care of following packets and is SMP friendly.



