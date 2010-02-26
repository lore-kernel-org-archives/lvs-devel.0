From: David Miller <davem@davemloft.net>
Subject: Re: [patch] IPVS: ip_vs_lblcr: use list head
Date: Thu, 25 Feb 2010 21:55:40 -0800 (PST)
Message-ID: <20100225.215540.94527171.davem@davemloft.net>
References: <20100226030211.GB6111@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100226030211.GB6111@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net

From: Simon Horman <horms@verge.net.au>
Date: Fri, 26 Feb 2010 14:02:11 +1100

> Use list_head rather than a custom list implementation.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Thanks for doing this, I'm sure Patrick will integrate this
patch for you.
