From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipvs: Remove stray file left over from ipvs move
Date: Wed, 08 Oct 2008 14:42:05 -0700 (PDT)
Message-ID: <20081008.144205.159292498.davem@davemloft.net>
References: <20081007001707.GA12647@verge.net.au>
	<20081008.143029.113654430.davem@davemloft.net>
	<alpine.LNX.2.00.0810082334130.21027@titan.stealer.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.0810082334130.21027@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: sven.wegener@stealer.net
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kaber@trash.net, juliusv@google.com, wensong@linux-vs.org, ja@ssi.bg

From: Sven Wegener <sven.wegener@stealer.net>
Date: Wed, 8 Oct 2008 23:40:12 +0200 (CEST)

> Commit cb7f6a7b716e801097b564dec3ccb58d330aef56 ("IPVS: Move IPVS to
> net/netfilter/ipvs") has left a stray file in the old location of ipvs.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  net/ipv4/ipvs/ip_vs_dh.c |  261 ----------------------------------------------
>  1 files changed, 0 insertions(+), 261 deletions(-)
> 
> Dave, please apply this on top of your net-next tree.

Done, thanks Sven.
