From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 01/15] net: add skb_dst_set_unref
Date: Sun, 10 Mar 2013 05:17:35 -0400 (EDT)
Message-ID: <20130310.051735.1281635372029510938.davem@davemloft.net>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg>
	<1362863815-5898-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362863815-5898-2-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Sat,  9 Mar 2013 23:16:41 +0200

> 	skb_dst_set_unref will use noref version even for
> DST_NOCACHE entries because DST_NOCACHE means dst is not
> cached in routing structures, still dst could be cached
> by routing users and used to produce noref instances.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I'm fine with this approach, but I think the name of this
interface could be better.

In fact you could do something like:

1) Rename skb_dst_set_noref() to __skb_dst_set_noref() and add
   a new "bool force" parameter.  DST_NOCACHE check is overriden
   when 'force' is true.

2) skb_dst_set_noref() is an inline that passes 'force' as false.

3) New interface skb_dst_set_noref_force() passes 'force' as true
   and will be used by your IPVS changes.

Then all of the RCU checks etc. happen in one shared function.
