From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: handle connections started by real-servers
Date: Fri, 15 Apr 2016 10:14:42 +1000
Message-ID: <20160415001442.GC9557@verge.net.au>
References: <5703e735.EsjlanP0p7ANNSWm%marcoangaroni@gmail.com>
 <alpine.LFD.2.11.1604091310420.2087@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1460679283; bh=IFNMZNlETld6ydcqRCd0kpKbMZhGI5EHGDfmCp0ZXKw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=TjL9HpI2XIH7ZVBDfA64g9T9k4OlUoiNykbNM3GDdOEMVJWmUqGfloH35LOQiPWO1
	 Xx2yO9cjxnVbJD0E4JCX7Mk1gLfRsJdF/R+w0BcftzdukNa9S+zKH/+E1+6w3aCHRA
	 paFZxG6UoOt7IIi8yVSBLLWItcx5dSTbwU4RyHv0=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1604091310420.2087@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: Julian Anastasov <ja@ssi.bg>
Cc: Marco Angaroni <marcoangaroni@gmail.com>, lvs-devel@vger.kernel.org

On Sat, Apr 09, 2016 at 01:13:02PM +0300, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Tue, 5 Apr 2016, Marco Angaroni wrote:
>=20
> > When using LVS-NAT and SIP persistence-egine over UDP, the followin=
g
> > limitations are present with current implementation:
> >=20
> >   1) To actually have load-balancing based on Call-ID header, you n=
eed to
> >      use one-packet-scheduling mode. But with one-packet-scheduling=
 the
> >      connection is deleted just after packet is forwarded, so SIP r=
esponses
> >      coming from real-servers do not match any connection and SNAT =
is
> >      not applied.
> >=20
> >   2) If you do not use "-o" option, IPVS behaves as normal UDP load
> >      balancer, so different SIP calls (each one identified by a dif=
ferent
> >      Call-ID) coming from the same ip-address/port go to the same
> >      real-server. So basically you don=E2=80=99t have load-balancin=
g based on
> >      Call-ID as intended.
> >=20
> >   3) Call-ID is not learned when a new SIP call is started by a rea=
l-server
> >      (inside-to-outside direction), but only in the outside-to-insi=
de
> >      direction. This would be a general problem for all SIP servers=
 acting
> >      as Back2BackUserAgent.
> >=20
> > This patch aims to solve problems 1) and 3) while keeping OPS mode
> > mandatory for SIP-UDP, so that 2) is not a problem anymore.
> >=20
> > The basic mechanism implemented is to make packets, that do not mat=
ch any
> > existent connection but come from real-servers, create new connecti=
ons
> > instead of let them pass without any effect.
> > When such packets pass through ip_vs_out(), if their source ip addr=
ess and
> > source port match a configured real-server, a new connection is
> > automatically created in the same way as it would have happened if =
the
> > packet had come from outside-to-inside direction. A new connection =
template
> > is created too if the virtual-service is persistent and there is no
> > matching connection template found. The new connection automaticall=
y
> > created, if the service had "-o" option, is an OPS connection that =
lasts
> > only the time to forward the packet, just like it happens on the
> > ingress side.
> >=20
> > The main part of this mechanism is implemented inside a persistent-=
engine
> > specific callback (at the moment only SIP persistent engine exists)=
 and
> > is triggered only for UDP packets, since connection oriented protoc=
ols, by
> > using different set of ports (typically ephemeral ports) to open ne=
w
> > outgoing connections, should not need this feature.
> >=20
> > The following requisites are needed for automatic connection creati=
on; if
> > any is missing the packet simply goes the same way as before.
> > a) virtual-service is not fwmark based (this is because fwmark serv=
ices
> >    do not store address and port of the virtual-service, required t=
o
> >    build the connection data).
> > b) virtual-service and real-servers must not have been configured w=
ith
> >    omitted port (this is again to have all data to create the conne=
ction).
> >=20
> > Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
>=20
> 	Nice addition, thanks! Simon, please apply.
>=20
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
