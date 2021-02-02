From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net 1/4] ipv6: silence compilation warning for non-IPV6
 builds
Date: Tue, 2 Feb 2021 20:55:28 +0200
Message-ID: <20210202185528.GE3264866@unreal>
References: <20210202135544.3262383-1-leon@kernel.org>
 <20210202135544.3262383-2-leon@kernel.org>
 <20210202082909.7d8f479f@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612292136;
        bh=BjWZCFlqgjdNMZLVU5uAX8s9kz3EWVagnqa51rr2xCA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=gbDEMsrNzRVJHy54V4CeoRSo7RDBd/5xx9QUX370/LxtHhOMIvJjsbHa0ZPKVUfki
         m8VzdOYard7X0Pl1+SQEqTvYUbYFtV593hqXl5k2HYXVswPcW2Gf05fsdTgTXdNta0
         94ZORDd2MWSKbl8itx6SntzxLscatuq9yRpMIQHFZ0R8fcOq7SMZL4EF2ji/ikaeGJ
         Snnxog7I6+TI9Gs9niHYUwXTAVw7XPbxJMV2+nUPab6Ji//XFbnvtxkCTS24YvGOum
         vGuLCrFLsI/DDnhHoYs82M556L4ghubxHDUn1y3u//lS4j9q8kHMYXeCFoXa+2nkXB
         tgpXJVoS/u6mg==
Content-Disposition: inline
In-Reply-To: <20210202082909.7d8f479f@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <kuba@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, coreteam@netfilter.org, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Tue, Feb 02, 2021 at 08:29:09AM -0800, Jakub Kicinski wrote:
> On Tue,  2 Feb 2021 15:55:41 +0200 Leon Romanovsky wrote:
> > From: Leon Romanovsky <leonro@nvidia.com>
> >
> > The W=1 compilation of allmodconfig generates the following warning:
> >
> > net/ipv6/icmp.c:448:6: warning: no previous prototype for 'icmp6_send' [-Wmissing-prototypes]
> >   448 | void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
> >       |      ^~~~~~~~~~
> >
> > In such configuration, the icmp6_send() is not used outside of icmp.c, so close
> > its EXPORT_SYMBOL and add "static" word to limit the scope.
> >
> > Fixes: cc7a21b6fbd9 ("ipv6: icmp6: avoid indirect call for icmpv6_send()")
> > Signed-off-by: Leon Romanovsky <leonro@nvidia.com>
>
> That's a little much ifdefinery, why not move the declaration from
> under the ifdef in the header instead?

We will find ourselves with exported but not used function, it will
increase symbol file, not big deal but not nice, either.

>
> If you repost please target net-next, admittedly these fixes are pretty
> "obviously correct" but they are not urgent either.

I'll do.

Thanks
