From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net 0/4] Fix W=1 compilation warnings in net/* folder
Date: Tue, 2 Feb 2021 15:59:38 +0100
Message-ID: <CANn89iJ1WYEfS-Pgzvec+54+3JQHCPSNdCfYaFkGYAEk3sGwmA@mail.gmail.com>
References: <20210202135544.3262383-1-leon@kernel.org> <CANn89iL4jGbr_6rr11nsHxmdh7uz=kqXuMhRb0nakWO3rBZwsQ@mail.gmail.com>
 <20210202145724.GA3264866@unreal>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cKDGkdAH6hnP9LDv3OSd/rUwsKO2Hnsk5XLdUyUcTiA=;
        b=ZTxCza8R+qKMO5AULHOV6aqYudyKoCq1ldvPSstkJUe++vlUm6kwA0NSIjetUWvwOr
         hIFujVH9L2DNpz8drDLj/rv4R4u7/hc79IUf6YfKXT6oZXygc3b2U9r28iB6aIcPKEjU
         PILiKxbjOVyXEJwzZKbfzJfSBRqk0rHMk6V4WuCLHeuzEPuLwDeEHN/zVlefRb0vETXR
         hW8Uu2zuCqz/lC+Q8toxwcmf3CL8x+lwD9JbTbxDiMoadqfik9UFDkpZy21GupRbKIe+
         iNCoDj7W3qVQOFdsx9vI9u+OjevzmoDAl7NZHeeCimBgM3KOBcgEhJEXekuXfSA5WJvC
         EY3Q==
In-Reply-To: <20210202145724.GA3264866@unreal>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leon Romanovsky <leon@kernel.org>
Cc: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Tue, Feb 2, 2021 at 3:57 PM Leon Romanovsky <leon@kernel.org> wrote:
>
> On Tue, Feb 02, 2021 at 03:34:37PM +0100, Eric Dumazet wrote:
> > On Tue, Feb 2, 2021 at 2:55 PM Leon Romanovsky <leon@kernel.org> wrote:
> > >
> > > From: Leon Romanovsky <leonro@nvidia.com>
> > >
> > > Hi,
> > >
> > > This short series fixes W=1 compilation warnings which I experienced
> > > when tried to compile net/* folder.
> > >
> >
> > Ok, but we never had a strong requirement about W=1, so adding Fixes:
> > tag is adding
>
> I added because Jakub has checker that looks for Fixes lines in "net"
> patches.

Send this to net-next

As I stated, we never enforce W=1 compilation rule.

I understand we might want that for _future_ kernels.

>
> > unnecessary burden to stable teams all around the world.
>
> It is automatic.

I do receive a copy of all backports in my mailbox, whenever I am tagged.

I can tell you there is a lot of pollution.

>
> Thanks
