From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Add IPv6 support to LBLC/LBLCR schedulers
Date: Mon, 03 Nov 2008 17:08:36 -0800 (PST)
Message-ID: <20081103.170836.22224897.davem@davemloft.net>
References: <20081103231712.GA7807@cydonia.lan>
	<20081104001451.GA18842@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20081104001451.GA18842@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: julius.volz@gmail.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Tue, 4 Nov 2008 11:14:52 +1100

> On Tue, Nov 04, 2008 at 12:17:12AM +0100, Julius Volz wrote:
> > Add IPv6 support to LBLC and LBLCR schedulers. These were the last
> > schedulers without IPv6 support, but we might want to keep the
> > supports_ipv6 flag in the case of future schedulers without IPv6
> > support.
> 
> Hi Julius,
> 
> this patch looks fine to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied to net-next-2.6
