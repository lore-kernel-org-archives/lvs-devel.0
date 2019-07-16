From: yangxingwu <xingwu.yang@gmail.com>
Subject: Re: [PATCH] ipvs: remove unnecessary space
Date: Tue, 16 Jul 2019 10:18:01 +0800
Message-ID: <CA+7U5JsvP5gyO_xRboPsF+m4Zg5g9XCsZwpjqAs4OZqmUqAbeg@mail.gmail.com>
References: <20190710074552.74394-1-xingwu.yang@gmail.com> <20190710080609.smxjqe2d5jyro4hv@verge.net.au>
 <20190715082747.fdlpvekbqyhwx724@salvia>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Tn8Q62o1MgY48Mx+DllWlgBdVj6RmFfgXYsNBaQSZ5o=;
        b=V46i+hrPbWUvgvrzDR/9EzpLX1v1cyAkGkD91Mjz/c9J+pPQpFGu4D+rS+dUFZag+f
         0hQm+etps2AyanmliTDyA3hkJc/VMkmYtBIaUbogLnh2A5ma0prtiUfI3/a0SpD7tAsh
         UuZ1TdkZjkhhHc3ypMtJJmt1XKWLVhkCe3L4NFWlXOWoNy0OXbuPnVVdlfs9g0QEB44Q
         a0I1AeAQ4y5h86sqW6QoMcIo4po3Dp23IgyunOq+ybsBaiS55wWlGv5s/p0fVJpO+DXW
         5hkTRCN/2p0HAqGjQUIwnmnsoncJ7Q3MhoqEyiF77RoTnJjT7EUHmAdq2/zlDGary92v
         dKOQ==
In-Reply-To: <20190715082747.fdlpvekbqyhwx724@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, wensong@linux-vs.org, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Pablo

v2 has been sent

I made the following changes:

1. remove all unnecessary spaces in one go
2. revert bitmap_alloc ( since it's irrelevant to this subject)
3. chenge subject to "net/netfiler:remove unnecessary space"

thanks

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
