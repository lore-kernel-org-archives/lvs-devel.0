From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add IPv6 support to LBLC/LBLCR schedulers
Date: Tue, 4 Nov 2008 11:14:52 +1100
Message-ID: <20081104001451.GA18842@verge.net.au>
References: <20081103231712.GA7807@cydonia.lan>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081103231712.GA7807@cydonia.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <julius.volz@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>

On Tue, Nov 04, 2008 at 12:17:12AM +0100, Julius Volz wrote:
> Add IPv6 support to LBLC and LBLCR schedulers. These were the last
> schedulers without IPv6 support, but we might want to keep the
> supports_ipv6 flag in the case of future schedulers without IPv6
> support.

Hi Julius,

this patch looks fine to me.

Acked-by: Simon Horman <horms@verge.net.au>

With regards to supports_ipv6, I think that it would be better
to remove it, now that it is unused, and add it (or something similar)
back if needed as I'm not entirely sure it will ever be needed again.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

