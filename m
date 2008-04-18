From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Fri, 18 Apr 2008 17:26:09 +0900
Message-ID: <200804181726.09816.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <200804171559.47753.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804180937220.2843@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0804180937220.2843@u.domain.uli>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Friday 18 April 2008 16:14:29 Julian Anastasov wrote:
> 	Hello,
>
> On Thu, 17 Apr 2008, Jason Stubbs wrote:
> > On further investigation, the behaviour is the same regardless of w=
hether
> > it is a VIP or a real host. When a SYN_SENT state exists traffic do=
esn't
> > flow. However, if there is no state and an ACK (no SYN) packet arri=
ves,
> > an ESTABLISHED entry is created such as:
>
> 	This conntrack does not look good, dst=3D192.168.1.3 in
> original direction is RIP instead of VIP.

That is because this testing was done by accessing the host's IP direct=
ly.

> > After this the connection can complete normally. I wonder if this i=
s not
> > a bug in conntrack handling? It doesn't seem right to me.
>
> 	loose flag has different prurpose:
>
> /* If it is set to zero, we disable picking up already established
>    connections. */
> static int nf_ct_tcp_loose __read_mostly =3D 1;

This is what I was testing. I wasn't aware of the flag until just a cou=
ple of=20
hours ago. With outgoing packets leaving via a different gateway and=20
connection tracking enabled and --state NEW rules in place, the followi=
ng=20
happens:

1. client sends SYN
2. director sets up SYN_SENT state and forwards SYN
3. server receives SYN
4. server sends SYN/ACK via other gateway
5. client receives SYN/ACK and sends ACK
6. director sees SYN_SENT entry without a SYN/ACK and blocks ACK
(4-6 are repeated a few times as server assumes the SYN/ACK got lost)
7. SYN_SENT entry times out and is deleted on the director
8. server sends SYN/ACK via other gateway
9. client receives SYN/ACK and sends ACK
10. director assumes an active connection and creates an ESTABLISHED en=
try
11. traffic flows fine until the end of the connection

Not being aware of the tcp_loose setting, steps 8-11 were confusing to =
me=20
which is why I was testing direct access to the server. Behaviour with =
a VIP=20
is the same.

Conntrack entries with both LVS-NAT and LVS-DR (when the director is al=
so the=20
return gateway) look like this:

ipv4     2 tcp      6 431996 ESTABLISHED src=3D192.168.0.104 dst=3D192.=
168.0.7=20
sport=3D35235 dport=3D80 packets=3D3 bytes=3D176 src=3D192.168.0.7 dst=3D=
192.168.0.104=20
sport=3D80 dport=3D35235 packets=3D1 bytes=3D60 [ASSURED] mark=3D0 use=3D=
1

iptables rules are:

# iptables -A FORWARD -p tcp -d 192.168.0.7 --dport 80 \
                      -m state --state NEW -j ACCEPT
# iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -P FORWARD DROP

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
