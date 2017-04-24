From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] ipvs: explicitly forbid ipv6 service/dest creation if
 ipv6 mod is disabled
Date: Mon, 24 Apr 2017 08:50:51 +0200
Message-ID: <1493016651.5744.1.camel@redhat.com>
References: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>
         <alpine.LFD.2.20.1704221355290.1974@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mx1.redhat.com 8163667ECD
In-Reply-To: <alpine.LFD.2.20.1704221355290.1974@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org

Hi,

On Sat, 2017-04-22 at 14:16 +0300, Julian Anastasov wrote:
> On Thu, 20 Apr 2017, Paolo Abeni wrote:
>=20
> > When creating a new ipvs service, ipv6 addresses are always accepted
> > if CONFIG_IP_VS_IPV6 is enabled. On dest creation the address family
> > is not explicitly checked.
> >=20
> > This allows the user-space to configure ipvs services even if the
> > system is booted with ipv6.disable=3D1. On specific configuration, ipvs
> > can try to call ipv6 routing code at setup time, causing the kernel to
> > oops due to fib6_rules_ops being NULL.
> >=20
> > This change addresses the issue adding a check for the ipv6
> > module being enabled while validating ipv6 service operations and
> > adding the same validation for dest operations.
> >=20
> > According to git history, this issue is apparently present since
> > the introduction of ipv6 support, and the oops can be triggered
> > since commit 09571c7ae30865ad ("IPVS: Add function to determine
> > if IPv6 address is local")
> >=20
> > Fixes: 09571c7ae30865ad ("IPVS: Add function to determine if IPv6 addre=
ss is local")
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>=20
> 	Looks good to me but I see two places that can benefit
> from such check:

I'm sorry for the lag, I was delayed by other notorious issues ;-)
I'm unable to trigger any crash with the patched kernel.

> - in ip_vs_genl_new_daemon() if we do not want to create IPv6 sockets
> for the sync protocol in make_send_sock() and make_receive_sock().
> Not sure if this can lead to crashes.

This one is, AFAICS, safe, because=C2=A0ip_vs_genl_new_daemon() calls
start_sync_thread(), which tries to create a socket of the specified
address family before doing any real action. Such operation will fail
gracefully, and overall we will get an - expected - error to userspace.

> - in ip_vs_proc_sync_conn() if we do not want backup server to accept=20
> IPv6 conns because they may be created even when dests are missing.
> We may use retc =3D 10 there. Not fatal but may eat memory for
> conns that will not be used.

If I read the above correct correctly, even that should be safe, for
the same reason: ipv6 socket creation will fail if ipv6 is disabled.

The problem with the patched code is that it tries to resolve ipv6
addresses that are not created/validated by the kernel.

Cheers,

Paolo
