From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net 0/4] Fix W=1 compilation warnings in net/* folder
Date: Tue, 2 Feb 2021 17:54:09 +0200
Message-ID: <20210202155409.GB3264866@unreal>
References: <20210202135544.3262383-1-leon@kernel.org>
 <CANn89iL4jGbr_6rr11nsHxmdh7uz=kqXuMhRb0nakWO3rBZwsQ@mail.gmail.com>
 <20210202145724.GA3264866@unreal>
 <CANn89iJ1WYEfS-Pgzvec+54+3JQHCPSNdCfYaFkGYAEk3sGwmA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612281253;
        bh=tTSJ6G+PI+xlH2RyCUwOWa9GfU59ob6JOGgyGyJE9sw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=o5BVmYjm39/e/jNOOkOycCC7U3mmvdIGvFgpAQbXVOb3+fxRR2qxg1DszNJ+v4845
         FHzTHCJRSz2GukZKc2iGH9X+ifok5xqA/yaQYpV/IX+gkHEKRGTWLo/uSZJgWM6/Ff
         SiPm4vECoGC79qEmse7uAeR/aHNNeWuSUcRG5RFDbf9AmmOVIkb/kOcQ+WTMJm9rYU
         loq+oVF5QDBjexBJepGPQkjrm8Oj16fXm5KUtgQBS4x/2RktW88S57zI1UEJ0V1hPX
         RKDfhi7Kx4mO1KwNqz+Fmd+9A4kX2xN3ruQFm0ZnYUxIwg1VOEVQkOPRS0xevZzQbZ
         Aw0g2YBRC17eg==
Content-Disposition: inline
In-Reply-To: <CANn89iJ1WYEfS-Pgzvec+54+3JQHCPSNdCfYaFkGYAEk3sGwmA@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <edumazet@google.com>
Cc: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Tue, Feb 02, 2021 at 03:59:38PM +0100, Eric Dumazet wrote:
> On Tue, Feb 2, 2021 at 3:57 PM Leon Romanovsky <leon@kernel.org> wrote:
> >
> > On Tue, Feb 02, 2021 at 03:34:37PM +0100, Eric Dumazet wrote:
> > > On Tue, Feb 2, 2021 at 2:55 PM Leon Romanovsky <leon@kernel.org> wrote:
> > > >
> > > > From: Leon Romanovsky <leonro@nvidia.com>
> > > >
> > > > Hi,
> > > >
> > > > This short series fixes W=1 compilation warnings which I experienced
> > > > when tried to compile net/* folder.
> > > >
> > >
> > > Ok, but we never had a strong requirement about W=1, so adding Fixes:
> > > tag is adding
> >
> > I added because Jakub has checker that looks for Fixes lines in "net"
> > patches.
>
> Send this to net-next

No problem.

>
> As I stated, we never enforce W=1 compilation rule.
>
> I understand we might want that for _future_ kernels.
>
> >
> > > unnecessary burden to stable teams all around the world.
> >
> > It is automatic.
>
> I do receive a copy of all backports in my mailbox, whenever I am tagged.
>
> I can tell you there is a lot of pollution.

I'm receiving them either.

>
> >
> > Thanks
