From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Mon, 14 Apr 2008 20:04:39 +0900
Message-ID: <200804142004.39881.j.stubbs@linkthink.co.jp>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804121021110.2942@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0804121021110.2942@u.domain.uli>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

Replying again now that I've got a lot of testing done. I'm heading hom=
e soon=20
so just posting an update and will test the last few things tomorrow. I=
'll=20
also try to submit a broken up patch tomorrow so that specific changes =
and=20
reasoning can be discussed more easily.

On Saturday 12 April 2008 18:07:59 Julian Anastasov wrote:
> - all forwarding methods can be tested on LAN, even LVS-TUN

Haven't been able to test LVS-TUN yet, but I can't see any reason why i=
t=20
shouldn't work. Will test tomorrow morning.

> - forwarding of related ICMP traffic (ICMP errors) in both directions=
,
> for all methods

Tested.

> - ICMP generation to both sides (client and real server): when there =
is no
> real server, when skb is longer than PMTU.

I tested the no real server case. How can i test the skb-too-large case=
? I=20
tried changing the MTU on the director's interface on the real-server s=
ide,=20
but traffic continued to pass fine...

> - scheduling by nfmark

Tested.

> - firewall: at least basic packet fields matching

iptables -t filter -A FORWARD -d 192.168.0.7 -i eth0 -j ACCEPT
iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j A=
CCEPT
iptables -t filter -P FORWARD REJECT

where 192.168.0.7 is the VIP I'm testing with worked fine. Pretty much =
any=20
firewall rules should work fine as I've moved LVS hooks to the points o=
f=20
entry/exit of the netfilter flow.

> - ip_vs_ftp testing (LVS-NAT) when netfilter ftp module is in
> effect: test if double NAT happens resulting in broken packets (TCP
> sequence numbers or payload) when payload is changed if IP:PORT
> strings in FTP commands have different length (VIP and RIP).

Tested plain LVS-NAT as well as with SNAT and DNAT. Surprisingly, it wo=
rks=20
even with the above conntrack-based filter in place. I think that indic=
ates=20
that double NAT is happening (else RELATED wouldn't match) but with the=
 order=20
that hooks are called things don't get screwed up - I think. I'll inves=
tigate=20
this a little further.

> > * IP_VS_CONN_F_BYPASS - what is this?
>
> 	IP_VS_CONN_F_BYPASS is used for transparent proxy setups when
> real server (cache server) is not present and we should forward the
> traffic to original destination. The idea is request still to be serv=
ed.
> In such case IPVS traffic uses the original destination instead of re=
al
> server.

Not tested yet. I assume I just need to add a real server with the same=
=20
IP/port as the virtual server?

> There are some issues that prevent IPVS to benefit from Netfilter
> connection tracking:
>
> - Netfilter's NAT and routing are not in single place (hook), difficu=
lt to
> handle LVS-DR

LVS-DR with real server as a client using SNAT... Will test this tomorr=
ow too.

> - Netfilter can re-route sometimes (eg. after mangle), it can cause
> properly routed LVS-DR traffic to fail.

I don't understand exactly what you mean by this. It could only happen =
if the=20
user sets rules that causes it to happen right?

> - Double NAT for ip_vs_ftp

Addressed above.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
