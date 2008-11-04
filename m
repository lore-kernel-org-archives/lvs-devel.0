From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Remove supports_ipv6 scheduler flag
Date: Tue, 4 Nov 2008 12:16:26 +1100
Message-ID: <20081104011624.GA23712@verge.net.au>
References: <20081104005826.GA28967@cydonia.lan> <20081103.170913.161467814.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081103.170913.161467814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Mon, Nov 03, 2008 at 05:09:13PM -0800, David Miller wrote:
> From: Julius Volz <julius.volz@gmail.com>
> Date: Tue, 4 Nov 2008 01:58:26 +0100
> 
> > Remove the 'supports_ipv6' scheduler flag since all schedulers now
> > support IPv6.
> > 
> > Signed-off-by: Julius Volz <julius.volz@gmail.com>
> 
> Since Simon explicitly asked for this patch, I've applied
> it :-)

Thanks :-)

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

