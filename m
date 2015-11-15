From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvs: use skb_to_full_sk() helper
Date: Sun, 15 Nov 2015 18:40:22 -0500 (EST)
Message-ID: <20151115.184022.199593714221031833.davem@davemloft.net>
References: <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
	<1447348452.22599.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447348452.22599.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: eric.dumazet@gmail.com
Cc: linux@eikelenboom.it, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2015 09:14:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> SYNACK packets might be attached to request sockets.
> 
> Use skb_to_full_sk() helper to avoid illegal accesses to
> inet_sk(skb->sk)
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>

I'll apply this directly, thanks.
