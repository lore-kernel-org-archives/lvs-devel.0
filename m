From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ipv6: use rt6i_gateway as nexthop
Date: Mon, 21 Oct 2013 18:40:57 -0400 (EDT)
Message-ID: <20131021.184057.328665907625927061.davem@davemloft.net>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, yoshfuji@linux-ipv6.org

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 20 Oct 2013 15:43:02 +0300

> 	I see the following two alternatives for applying these
> patches:
> 
> 1. Linger patch 2 in net-next to avoid surprises in the upcoming
> release. In this case patch 3 can be reworked not to depend on
> the new rt6_nexthop() definition in patch 2. I guess this is a
> better option, so that patch 2 can be reviewed and tested for
> longer time.
> 
> 2. Include all 3 patches in net tree - more risky because this
> is my first attempt to change IPv6.

I have decided to merge all three patches into -net right now.
I've reviewed these patches several times and they look good
to me.

I'll let them cook upstream for at least a week before submitting them
to -stable to let any last minute errors show themselves and
subsequently get resolved.

Thanks!
