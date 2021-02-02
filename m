From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH net 0/4] Fix W=1 compilation warnings in net/* folder
Date: Tue,  2 Feb 2021 15:55:40 +0200
Message-ID: <20210202135544.3262383-1-leon@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612274149;
        bh=keCkanpK2quFyUoP2sx6/rYjvo75AHXrNu1jIcal3Nk=;
        h=From:To:Cc:Subject:Date:From;
        b=BkqNr1X+v2SqOy6cjJ9bc7qgUWfmFxrAWzOXsO57Ko5nkViZYaz9DRIVvzt/6rg+X
         V1/IoxLg98kVAy38RnB5qDcYnkrQkzPYDJDvN/C+fwQPrff6CDBcqiKKe2KA4zgpls
         cAwuFtQ4JzUQxaInNBSnz6xAL/vw6PYbT9rqpyuQ4+Dnk3du/F+8mBNzD7ajHeizaO
         WcLY2pWHY5XUTkrCo9OTZGVufSybf6xW5PIW9l5DTzTuWu5yqRgU34A22XnbGx5nda
         +53ZsdeGnrR18zrE08B6OjVLT+loJBOMo/Tft9e9vLYcgfkld/iOwyZn8b29r9Ec9F
         pqgPtCPIQNVvw==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Leon Romanovsky <leonro@nvidia.com>, coreteam@netfilter.org, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

From: Leon Romanovsky <leonro@nvidia.com>

Hi,

This short series fixes W=1 compilation warnings which I experienced
when tried to compile net/* folder.

Thanks

Leon Romanovsky (4):
  ipv6: silence compilation warning for non-IPV6 builds
  ipv6: move udp declarations to net/udp.h
  net/core: move ipv6 gro function declarations to net/ipv6
  netfilter: move handlers to net/ip_vs.h

 include/net/ip_vs.h             | 11 +++++++++++
 include/net/ipv6.h              |  3 +++
 include/net/udp.h               |  3 +++
 net/core/dev.c                  |  4 +---
 net/ipv6/icmp.c                 |  6 ++++++
 net/ipv6/ip6_input.c            |  3 +--
 net/netfilter/ipvs/ip_vs_core.c | 12 ------------
 7 files changed, 25 insertions(+), 17 deletions(-)

--
2.29.2

