From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/sctp: Refactor SCTP skb checksum
 computation
Date: Sat, 27 Jul 2013 20:07:35 -0700 (PDT)
Message-ID: <20130727.200735.1581680270448959358.davem@davemloft.net>
References: <1374717125-28969-1-git-send-email-joe@wand.net.nz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1374717125-28969-1-git-send-email-joe@wand.net.nz>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: joe@wand.net.nz
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, pablo@netfilter.org, ja@ssi.bg, horms@verge.net.au, jesse@nicira.com

From: Joe Stringer <joe@wand.net.nz>
Date: Thu, 25 Jul 2013 10:52:05 +0900

> This patch consolidates the SCTP checksum calculation code from various
> places to a single new function, sctp_compute_cksum(skb, offset).
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>

Applied, thanks.
