From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add IPv6 support to SH and DH schedulers
Date: Mon, 3 Nov 2008 11:15:51 +1100
Message-ID: <20081103001551.GI11409@verge.net.au>
References: <20081101231319.GA12150@cydonia.lan>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081101231319.GA12150@cydonia.lan>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <julius.volz@gmail.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>

On Sun, Nov 02, 2008 at 12:13:19AM +0100, Julius Volz wrote:
> Add IPv6 support to SH and DH schedulers. I hope this simple IPv6 address
> hashing is good enough. The 128 bit are just XORed into 32 before hashing
> them like an IPv4 address.
> 
> Signed-off-by: Julius Volz <julius.volz@gmail.com>

At the very least this seems like a reasonable start to me.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

