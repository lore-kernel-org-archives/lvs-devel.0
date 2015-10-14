From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next 1/2] ipvs: Remove possibly unused variable from
 ip_vs_out
Date: Wed, 14 Oct 2015 11:10:09 +0900
Message-ID: <20151014021007.GA2932@verge.net.au>
References: <1444195403-4288-1-git-send-email-horms@verge.net.au>
 <1444195403-4288-2-git-send-email-horms@verge.net.au>
 <56152517.6020807@cogentembedded.com>
 <20151012154349.GA22589@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1444788610; bh=y1pAwF7sDw4iB2IZ9lESjI2Qef5Lq2jjPz1WcF4XDoo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=kjO+JHWznMYiVwewPFWcENFMtW9oxC900TLUtTgKaVeWBc1OBf+j2yO67a+iWYp2/
	 7B52dTr/VV/Iiaw78fo3oq2UvlSZPHmTdFL5i6zgEW/bFCPpiiUR7SMqM+qfEszcOt
	 j6oC4/c73AUIhKI7jy97X9tBn/KnRTEcv+7Hggkc=
Content-Disposition: inline
In-Reply-To: <20151012154349.GA22589@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsa@cumulusnetworks.com>

On Mon, Oct 12, 2015 at 05:43:49PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Oct 07, 2015 at 04:58:47PM +0300, Sergei Shtylyov wrote:
> > Hello.
> >=20
> > On 10/7/2015 8:23 AM, Simon Horman wrote:
> >=20
> > >From: David Ahern <dsa@cumulusnetworks.com>
> > >
> > >Eric's net namespace changes in 1b75097dd7a26 leaves net unreferen=
ced if
> > >CONFIG_IP_VS_IPV6 is not enabled:
> > >
> > >../net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=
=E2=80=99:
> > >../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variab=
le =E2=80=98net=E2=80=99 [-Wunused-variable]
> > >
> > >After the net refactoring there is only 1 user; push the reference=
 to the
> > >1 user. While the line length slightly exceeds 80 it seems to be t=
he
> > >best change.
> > >
> > >Fixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
> >=20
> >    Minor nit: missing space before (. Could be probbably fixed whil=
e applying...
>=20
> I have pulled this anyway, I don't want to keep this back for this
> minor style problem.
>=20
> But please Simon, run checkpatch.pl before submitting next time.

Sorry about that, I will try to be more careful.
