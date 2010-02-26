From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] IPVS: ip_vs_lblcr: use list head
Date: Fri, 26 Feb 2010 17:45:41 +0100
Message-ID: <4B87FAB5.3070505@trash.net>
References: <20100226030211.GB6111@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100226030211.GB6111@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>

Simon Horman wrote:
> Use list_head rather than a custom list implementation.

Looks good, applied.
