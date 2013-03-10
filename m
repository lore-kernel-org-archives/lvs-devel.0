From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 01/15] net: add skb_dst_set_unref
Date: Sun, 10 Mar 2013 17:00:04 -0400 (EDT)
Message-ID: <20130310.170004.2239870728229481365.davem@davemloft.net>
References: <1362863815-5898-2-git-send-email-ja@ssi.bg>
	<20130310.051735.1281635372029510938.davem@davemloft.net>
	<alpine.LFD.2.00.1303101527530.1608@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1303101527530.1608@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 10 Mar 2013 15:37:34 +0200 (EET)

> 	The idea looks good, here is the implementation.
> Can I use it in this form for next patchset versions?

Yes, but with one minor change:

> -	if (unlikely(dst->flags & DST_NOCACHE)) {
> +	if (unlikely(dst->flags & DST_NOCACHE && !force)) {

I keep forgetting the && vs. & operator precedence, and so
do many other people, so please put parenthesis around
the "dst->flags & DST_NOCACHE" expression, thanks.
