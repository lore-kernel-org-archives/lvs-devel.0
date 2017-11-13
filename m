From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] netfilter: mark expected switch fall-throughs
Date: Mon, 13 Nov 2017 08:59:50 +0100
Message-ID: <20171113075950.csqwxld3i42updiz@verge.net.au>
References: <20171107073045.Horde.fHvUlYL1jmnkY_bpuXRFqCR@gator4166.hostgator.com>
 <20171107141929.GA24483@embeddedor.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1510559992; bh=Jyn1k/b8a1cEi0rgsMU5cV/NRDugbew9n87hQimHRcU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=rnlIPXhVMN/U3ZJ1mlrjOwFWz+Fx7gekU4b3Ydfi+Tuu6aVj3Dzneain5zmEe/J51
         yCWodk9FnPq4FG7b/T3KfnORQIl7UcAx5iWUu3gfMrGYB+S/q88XK2K9eKPYanXUm5
         XxM+6RMHzfG5IJR89ugExmyZKY3VGD6UC9v2iP8E=
Content-Disposition: inline
In-Reply-To: <20171107141929.GA24483@embeddedor.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Tue, Nov 07, 2017 at 08:19:29AM -0600, Gustavo A. R. Silva wrote:
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Addresses-Coverity-ID: 1128839
> Addresses-Coverity-ID: 1128840
> Addresses-Coverity-ID: 115120
> Addresses-Coverity-ID: 115121
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Pablo, could you take this one directly?
