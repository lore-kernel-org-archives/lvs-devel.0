From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: ipvs oops in 3.0-rc7
Date: Thu, 21 Jul 2011 10:26:57 -0700
Message-ID: <20110721102657.1c696e6b.rdunlap@xenotime.net>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
	<20110721054033.GA8299@verge.net.au>
	<CA+v9cxYJtrpUSHWY5Z2R14kZjX1c5nd2yYrvTx2URLJz26d_Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <CA+v9cxYJtrpUSHWY5Z2R14kZjX1c5nd2yYrvTx2URLJz26d_Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Huajun Li <huajun.li.lee@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, 21 Jul 2011 16:42:17 +0800 Huajun Li wrote:

> Hi Randy and Simon,
>     I happened to meet the issue too, loading and unloading module of
> ip_vs, then loading it again will cause Oops, the root cause may be
> ip_vs_dst_notifier is not unregistered. Please try following patch, i=
t
> works for me.
>=20
>=20
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_v=
s_ctl.c
> index 699c79a..a178cb3 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3771,6 +3771,7 @@ err_sock:
>  void ip_vs_control_cleanup(void)
>  {
>  	EnterFunction(2);
> +	unregister_netdevice_notifier(&ip_vs_dst_notifier);
>  	ip_vs_genl_unregister();
>  	nf_unregister_sockopt(&ip_vs_sockopts);
>  	LeaveFunction(2);
> --=20

Yes, this patch or the one here:  http://www.spinics.net/lists/lvs-deve=
l/msg02051.html

works.  Thanks.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Acked-by: Randy Dunlap <rdunlap@xenotime.net>


> 2011/7/21 Simon Horman <horms@verge.net.au>:
> > On Wed, Jul 20, 2011 at 08:50:19PM -0700, Randy Dunlap wrote:
> >> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading a=
nd unloading
> >> modules. =A0Any chance this is already fixed? =A0I can test curren=
t git, but I
> >> wanted to ask first.
> >>
> >> Looks like it is on the second module load of ip_vs (i.e.,
> >> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).
> >
> > Hi Randy,
> >
> > I don't believe that this problem has been resolved (or observed be=
fore).



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
