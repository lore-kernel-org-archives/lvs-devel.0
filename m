From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Add IPv6 support to SH and DH schedulers
Date: Sun, 02 Nov 2008 23:53:10 -0800 (PST)
Message-ID: <20081102.235310.35348053.davem@davemloft.net>
References: <20081101231319.GA12150@cydonia.lan>
	<20081103001551.GI11409@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20081103001551.GI11409@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: julius.volz@gmail.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Mon, 3 Nov 2008 11:15:51 +1100

> On Sun, Nov 02, 2008 at 12:13:19AM +0100, Julius Volz wrote:
> > Add IPv6 support to SH and DH schedulers. I hope this simple IPv6 address
> > hashing is good enough. The 128 bit are just XORed into 32 before hashing
> > them like an IPv4 address.
> > 
> > Signed-off-by: Julius Volz <julius.volz@gmail.com>
> 
> At the very least this seems like a reasonable start to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Patch applied to net-next-2.6, thanks.
