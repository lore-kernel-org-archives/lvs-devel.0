From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net 0/4] Fix W=1 compilation warnings in net/* folder
Date: Tue, 2 Feb 2021 15:34:37 +0100
Message-ID: <CANn89iL4jGbr_6rr11nsHxmdh7uz=kqXuMhRb0nakWO3rBZwsQ@mail.gmail.com>
References: <20210202135544.3262383-1-leon@kernel.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bxl73venaa9cWERoVp0VscHZS3/IH5lSgUJLT8Av3Oc=;
        b=d5yDUwK8kbyroVDcNrW9Bed9kahFje2ZIU0BDehuW5DzhPmTw6AKATlvIgrv3J4sup
         aIo/FiNf8JoT4Hc5Hak+mLJocFm+sU/u992MZHifR/Vk1Vy162sQeLOaHALCaNiJbGRo
         OML/GI0PIO+UdFLcZ8smRhAhPEB81uhDI1ArrGScpj4MY6sy6aHAFWoy7FYSsBM4zZ8y
         BasAXhEgwWcGYwtGMAoiGGjfmc51b8AlNJGIgeBrkF+i00WuUU55rrkEzAbaCoaooN1y
         L9wDlcTrJVC2mJ9uCebXrUMygqRdWMyoY4OOn+vTf+7KKYGSCcbjpUs1+bjIJQtN65xg
         Nfyw==
In-Reply-To: <20210202135544.3262383-1-leon@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leon Romanovsky <leon@kernel.org>
Cc: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Leon Romanovsky <leonro@nvidia.com>, coreteam@netfilter.org, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, LKML <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

On Tue, Feb 2, 2021 at 2:55 PM Leon Romanovsky <leon@kernel.org> wrote:
>
> From: Leon Romanovsky <leonro@nvidia.com>
>
> Hi,
>
> This short series fixes W=1 compilation warnings which I experienced
> when tried to compile net/* folder.
>

Ok, but we never had a strong requirement about W=1, so adding Fixes:
tag is adding
unnecessary burden to stable teams all around the world.
