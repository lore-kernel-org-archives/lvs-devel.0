From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH] ipvs: remove unnecessary space
Date: Tue, 16 Jul 2019 09:26:44 +0800
Message-ID: <CA+7U5JvJMTjCuxo8Mf7tiXZADe-q4covYxX7NsG8EMCcJh5mtA@mail.gmail.com>
References: <20190710074552.74394-1-xingwu.yang@gmail.com> <20190710080609.smxjqe2d5jyro4hv@verge.net.au>
 <20190715082747.fdlpvekbqyhwx724@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=OJKGfm4zPYEeDJ64R4ToC+PbXLnEzfGrEQo6pdlpNP8=;
        b=Z+iDl3zbbSqm+cZ1DbJoZQ4JVZrZS+3NgT6IUkEHLJYLGXYwGLpulc8+qBb5BZMFMx
         xPbMTzvoEFGE5/p+TG1HXN9HNt5MMfiecWwVQrpA0q8VAssMLnAX/1lr0xHHdr+NxpBg
         Av/GC8PPSRpyiUDPwNs3PKrgquTN7eSZcc5tMJmyENceBnEonRJZAstLHmsUS3huTSvy
         +9gAVtOHgCKcHVpyHFXDIem/J5FR+Hos5iDX33J7ejTKL4cHat6reDmk8g3kWxSoUk+q
         O1dLwAoE2HUNQG9N4PgtU8r6gN6fgdfjWccc4AKPBuzdgEThe5+wpafY1Mr0H3ZfCQlY
         jP2A==
In-Reply-To: <20190715082747.fdlpvekbqyhwx724@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, wensong@linux-vs.org, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

ok

I will remove all unnecessary spaces and send the v2 patch

Thansk Pablo

Pablo Neira Ayuso <pablo@netfilter.org> =E4=BA=8E2019=E5=B9=B47=E6=9C=8815=
=E6=97=A5=E5=91=A8=E4=B8=80 =E4=B8=8B=E5=8D=884:27=E5=86=99=E9=81=93=EF=BC=
=9A
>
> On Wed, Jul 10, 2019 at 10:06:09AM +0200, Simon Horman wrote:
> > On Wed, Jul 10, 2019 at 03:45:52PM +0800, yangxingwu wrote:
> > > ---
> > >  net/netfilter/ipvs/ip_vs_mh.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs=
_mh.c
> > > index 94d9d34..98e358e 100644
> > > --- a/net/netfilter/ipvs/ip_vs_mh.c
> > > +++ b/net/netfilter/ipvs/ip_vs_mh.c
> > > @@ -174,8 +174,8 @@ static int ip_vs_mh_populate(struct ip_vs_mh_stat=
e *s,
> > >             return 0;
> > >     }
> > >
> > > -   table =3D  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> > > -                    sizeof(unsigned long), GFP_KERNEL);
> > > +   table =3D kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> > > +                   sizeof(unsigned long), GFP_KERNEL);
>
> May I ask one thing? :-)
>
> Please, remove all unnecessary spaces in one go, search for:
>
>         git grep "=3D  "
>
> in the netfilter tree, and send a v2 for this one.
>
> Thanks.
