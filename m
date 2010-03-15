From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/netfilter/ipvs/ip_vs_ftp.c: Remove use of NIPQUAD
Date: Mon, 15 Mar 2010 17:20:19 +0100
Message-ID: <4B9E5E43.9060206@trash.net>
References: <1268094699.1617.5.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1268094699.1617.5.camel@Joe-Laptop.home>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joe Perches <joe@perches.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel <lvs-devel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Joe Perches wrote:
> NIPQUAD has very few uses left.
> 
> Remove this use and make the code have the identical form of the only
> other use of "%u,%u,%u,%u,%u,%u" in net/ipv4/netfilter/nf_nat_ftp.c

Are we trying to remove NIPQUAD? In my opinion the current code is
preferrable to open-coding NIPQUAD.
