From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 net-next 01/15] net: add skb_dst_set_unref
Date: Mon, 11 Mar 2013 00:05:56 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303102352460.1608@ja.ssi.bg>
References: <1362863815-5898-2-git-send-email-ja@ssi.bg> <20130310.051735.1281635372029510938.davem@davemloft.net> <alpine.LFD.2.00.1303101527530.1608@ja.ssi.bg> <20130310.170004.2239870728229481365.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130310.170004.2239870728229481365.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Sun, 10 Mar 2013, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sun, 10 Mar 2013 15:37:34 +0200 (EET)
> 
> > 	The idea looks good, here is the implementation.
> > Can I use it in this form for next patchset versions?
> 
> Yes, but with one minor change:
> 
> > -	if (unlikely(dst->flags & DST_NOCACHE)) {
> > +	if (unlikely(dst->flags & DST_NOCACHE && !force)) {
> 
> I keep forgetting the && vs. & operator precedence, and so
> do many other people, so please put parenthesis around
> the "dst->flags & DST_NOCACHE" expression, thanks.

	Done, I'll wait a week for more feedback...

Regards

--
Julian Anastasov <ja@ssi.bg>
