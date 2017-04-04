From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: netfilter: Use seq_puts()/seq_putc() where possible
Date: Tue, 4 Apr 2017 13:59:48 -0400
Message-ID: <20170404175948.GD7257@verge.net.au>
References: <20170328215517.GA18237@singhal-Inspiron-5558>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1491328792; bh=41bNXdofg3KvWg9sXtMhnTONfudYGlaUtLLbGy1yWwU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=g/B8BUm+gN5gIiXDwWzjSzftKK0KlZHUak9iXnyUZTvny0qDhSZeWNqGtCO1qR2ft
         Ie/f/yOs96P5uKT4+pEbDUymSsQNjPSd20/hN5HQk2IGYJEArD4Jo9vVDn8qaYgwJs
         pAaKw6frOAo6kmSnPThdeulS1jgcrGMevuuqjZkU=
Content-Disposition: inline
In-Reply-To: <20170328215517.GA18237@singhal-Inspiron-5558>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: wensong@linux-vs.org, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

On Wed, Mar 29, 2017 at 03:25:17AM +0530, simran singhal wrote:
> For string without format specifiers, use seq_puts(). For
> seq_printf("\n"), use seq_putc('\n').
> 
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c          | 8 ++++----

Simran, I would be happy to pick up the IPVS version if it was posted as a
separate patch.

Alternative, Pablo, if you would like to take this patch feel free to add:

Acked-by: Simon Horman <horms+renesas@verge.net.au>
