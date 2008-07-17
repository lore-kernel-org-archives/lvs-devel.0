From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: More reliable synchronization on connection close
Date: Wed, 16 Jul 2008 20:04:38 -0700 (PDT)
Message-ID: <20080716.200438.07028915.davem@davemloft.net>
References: <20080716063519.GA5144@verge.net.au>
	<20080717024720.GB23699@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080717024720.GB23699@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, rumen@voicecho.com, jmack@wm7d.net

From: Simon Horman <horms@verge.net.au>
Date: Thu, 17 Jul 2008 12:47:22 +1000

> This patch enhances the synchronization of the closing connections
> between the master and the backup director. It prevents the closed
> connections to expire with the 15 min timeout of the ESTABLISHED
> state on the backup and makes them expire as they would do on the
> master with much shorter timeouts.
> 
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
