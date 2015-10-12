From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 1/2] ipvs: Remove possibly unused variable from
 ip_vs_out
Date: Mon, 12 Oct 2015 17:43:49 +0200
Message-ID: <20151012154349.GA22589@salvia>
References: <1444195403-4288-1-git-send-email-horms@verge.net.au>
 <1444195403-4288-2-git-send-email-horms@verge.net.au>
 <56152517.6020807@cogentembedded.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56152517.6020807@cogentembedded.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsa@cumulusnetworks.com>

On Wed, Oct 07, 2015 at 04:58:47PM +0300, Sergei Shtylyov wrote:
> Hello.
>=20
> On 10/7/2015 8:23 AM, Simon Horman wrote:
>=20
> >From: David Ahern <dsa@cumulusnetworks.com>
> >
> >Eric's net namespace changes in 1b75097dd7a26 leaves net unreference=
d if
> >CONFIG_IP_VS_IPV6 is not enabled:
> >
> >../net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=E2=
=80=99:
> >../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable=
 =E2=80=98net=E2=80=99 [-Wunused-variable]
> >
> >After the net refactoring there is only 1 user; push the reference t=
o the
> >1 user. While the line length slightly exceeds 80 it seems to be the
> >best change.
> >
> >Fixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
>=20
>    Minor nit: missing space before (. Could be probbably fixed while =
applying...

I have pulled this anyway, I don't want to keep this back for this
minor style problem.

But please Simon, run checkpatch.pl before submitting next time.

Thanks!
