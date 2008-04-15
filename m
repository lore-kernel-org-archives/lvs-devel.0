From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Tue, 15 Apr 2008 16:17:54 +0900
Message-ID: <200804151617.54155.j.stubbs@linkthink.co.jp>
References: <200804111400.12331.j.stubbs@linkthink.co.jp> <200804142004.39881.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804150127400.3092@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0804150127400.3092@u.domain.uli>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Tuesday 15 April 2008 08:16:58 Julian Anastasov wrote:
> On Mon, 14 Apr 2008, Jason Stubbs wrote:
> > > > * IP_VS_CONN_F_BYPASS - what is this?
> > >
> > > 	IP_VS_CONN_F_BYPASS is used for transparent proxy setups when
> > > real server (cache server) is not present and we should forward t=
he
> > > traffic to original destination. The idea is request still to be
> > > served. In such case IPVS traffic uses the original destination i=
nstead
> > > of real server.
> >
> > Not tested yet. I assume I just need to add a real server with the =
same
> > IP/port as the virtual server?
>
> 	Not sure, may be IP:PORT of LVS's uplink gateway. In such
> setups clients are usually internal hosts using LVS box as gateway.

I figured this one out by looking at the source and it tested fine too.=
 The=20
virtual server must be fwmark and the sysctl ip.vs.cache_bypass must be=
 set=20
to 1. With those settings, the packet is passed when there are no real=20
servers available rather than being rejected with ICMP_PORT_UNREACH.

> > > - Netfilter can re-route sometimes (eg. after mangle), it can cau=
se
> > > properly routed LVS-DR traffic to fail.
> >
> > I don't understand exactly what you mean by this. It could only hap=
pen if
> > the user sets rules that causes it to happen right?
>
> 	May be the things have changed, not sure. The problem is when
> functions like ip_route_me_harder() are called for packets that
> are already forwarded by IPVS (skb has attached route for the
> real server). In such case skb still shows VIP as iph->daddr and
> a rerouting can result in local route. But latest kernels may be
> reroute only in LOCAL_OUT, so this is not a problem.


> 	As for the double POST_ROUTING log entries ... I'm checking
> this NF_HOOK_THRESH call with NF_IP_PRI_LAST. For me, it looks like
> net/netfilter/core.c:nf_iterate() calls only handlers when
> elem->priority >=3D hook_thresh. But you put ip_vs_in() at the same
> priority NF_IP_PRI_LAST. May be ip_vs_in() is called twice?

The dst_output specified to NF_HOOK_THRESH is called after nf_iterate()=
 is=20
finished. dst_output then calls NF_HOOK_THRESH with POST_ROUTING again=20
passing the result to an internal function to actually send the packet =
out.
There's no way around it except perhaps with an NF_STOP hook. I'd like =
to=20
figure out how traffic (congestion) control fits in first though.

> 	Also, if ip_vs_in() is called  after SNAT I'm curious, isn't
> ip_vs_ftp working with DNAT-ed skb (if you have netfilter ftp nat
> module) ? May be things don't break because IPVS is careful not to
> damage packets it can not recognize. But do we work properly with
> the FTP commands in ip_vs_ftp_in(), do we create properly FTP data
> connections in IPVS? I assume you test both passive and active FTP.
> If the goal is -m state to work correctly, are you sure the IPVS FTP
> data connections work correctly (as RELATED traffic)?

I tried again with the accept rule as:

iptables -t filter -A FORWARD -p tcp -d 192.168.0.7 --dport 21 -i eth0 =
-j=20
ACCEPT

However, it still worked fine in both passive and active modes. The pat=
ch=20
series I posted may make it clear, but the way I visualize what's happe=
ning=20
is that there are two proxies between the client and the server. Someth=
ing=20
like: client =3D> DNAT =3D> LVS =3D> server. DNAT and LVS are unaware o=
f each=20
other's existence, but there is no problems because the order of proces=
sing=20
make it transparent.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
