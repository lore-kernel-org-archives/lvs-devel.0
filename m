From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: ipv6_find_hdr restore prev functionality
Date: Thu, 27 Feb 2014 18:28:03 -0500 (EST)
Message-ID: <20140227.182803.2159868180417685841.davem@davemloft.net>
References: <1393502278-32297-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1393502278-32297-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: hans@schillstrom.com
Cc: netdev@vger.kernel.org, ja@ssi.bg, aatteka@nicira.com, kaber@trash.net, ard@telegraafnet.nl, lvs-devel@vger.kernel.org

From: Hans Schillstrom <hans@schillstrom.com>
Date: Thu, 27 Feb 2014 12:57:58 +0100

> The commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8 ("ipv6: improve 
> ipv6_find_hdr() to skip empty routing headers") broke ipv6_find_hdr().
> 
> When a target is specified like IPPROTO_ICMPV6 ipv6_find_hdr()
> returns -ENOENT when it's found, not the header as expected.
> 
> A part of IPVS is broken and possible also nft_exthdr_eval().
> When target is -1 which it is most cases, it works.
> 
> This patch exits the do while loop if the specific header is found
> so the nexthdr could be returned as expected.
> 
> Reported-by: Art -kwaak- van Breemen <ard@telegraafnet.nl>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> CC:Ansis Atteka <aatteka@nicira.com>

Looks good, applied and queued up for -stable, thanks!
