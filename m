From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Thu, 17 Apr 2008 15:59:47 +0900
Message-ID: <200804171559.47753.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804161051400.2944@u.domain.uli> <200804171225.54424.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804171225.54424.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Thursday 17 April 2008 12:25:54 Jason Stubbs wrote:
> On Wednesday 16 April 2008 18:10:52 Julian Anastasov wrote:
> > It is interesting what is -m state in Netfilter when
> > no replies are forwarded for LVS-DR setups, replies go directly
> > from real server to client. Are you sure long established connectio=
ns
> > do not timeout shorter due to bad state in netfilter? May be
> > conntrack_tcp will be confused that only one direction works?
>
> This is currently working, but shouldn't be. When forwarding to a reg=
ular
> server via the LVS box, a conntrack entry in the SYN_SENT state is se=
t up
> and no further traffic is allowed. When forwarding for a VIP, traffic=
 is
> flowing through regardless of whether there's a conntrack entry or no=
t. It
> must be something that ip_vs_out is doing so I'll look into it a litt=
le
> more and try to fix it.

On further investigation, the behaviour is the same regardless of wheth=
er it=20
is a VIP or a real host. When a SYN_SENT state exists traffic doesn't f=
low.=20
However, if there is no state and an ACK (no SYN) packet arrives, an=20
ESTABLISHED entry is created such as:

ipv4     2 tcp      6 431996 ESTABLISHED src=3D192.168.0.104 dst=3D192.=
168.1.3=20
sport=3D20001 dport=3D80 packets=3D1 bytes=3D54 [UNREPLIED] src=3D192.1=
68.1.3=20
dst=3D192.168.0.104 sport=3D80 dport=3D20001 packets=3D0 bytes=3D0 mark=
=3D0 use=3D1

After this the connection can complete normally. I wonder if this is no=
t a bug=20
in conntrack handling? It doesn't seem right to me.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
