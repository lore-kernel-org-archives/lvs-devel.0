From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Fri, 18 Apr 2008 13:59:47 +0900
Message-ID: <200804181359.47421.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <200804171225.54424.j.stubbs@linkthink.co.jp> <200804171559.47753.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804171559.47753.j.stubbs@linkthink.co.jp>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Thursday 17 April 2008 15:59:47 Jason Stubbs wrote:
> On further investigation, the behaviour is the same regardless of whe=
ther
> it is a VIP or a real host. When a SYN_SENT state exists traffic does=
n't
> flow. However, if there is no state and an ACK (no SYN) packet arrive=
s, an
> ESTABLISHED entry is created such as:
>
> ipv4     2 tcp      6 431996 ESTABLISHED src=3D192.168.0.104 dst=3D19=
2.168.1.3
> sport=3D20001 dport=3D80 packets=3D1 bytes=3D54 [UNREPLIED] src=3D192=
=2E168.1.3
> dst=3D192.168.0.104 sport=3D80 dport=3D20001 packets=3D0 bytes=3D0 ma=
rk=3D0 use=3D1
>
> After this the connection can complete normally. I wonder if this is =
not a
> bug in conntrack handling? It doesn't seem right to me.

There's an undocumented (as far as I can tell) sysctl that controls thi=
s=20
called net.netfilter.nf_conntrack_tcp_loose which defaults to 1. Turnin=
g it=20
off gave the behaviour I expected.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
