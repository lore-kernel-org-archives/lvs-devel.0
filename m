From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Restrict sync message to 255 connections
Date: Mon, 22 Sep 2008 09:56:28 +1000
Message-ID: <20080921235627.GB1342@verge.net.au>
References: <alpine.LNX.2.00.0809192040250.22510@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809192040250.22510@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>

On Fri, Sep 19, 2008 at 08:41:56PM +0200, Sven Wegener wrote:
> The nr_conns variable in the sync message header is only eight bits wide
> and will overflow on interfaces with a large MTU. As a result the backup
> won't parse all connections contained in the sync buffer. On regular
> ethernet with an MTU of 1500 this isn't a problem, because we can't
> overflow the value, but consider jumbo frames being used on a cross-over
> connection between both directors.
> 
> We now restrict the size of the sync buffer, so that we never put more
> than 255 connections into a single sync buffer.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

Thanks Sven, applied.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

