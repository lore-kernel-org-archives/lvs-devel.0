From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Fri, 21 Jan 2011 17:50:03 +0100
Message-ID: <4D39B93B.2000408@trash.net>
References: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1295604133-6869-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Changli Gao <xiaosuo@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 21.01.2011 11:02, schrieb Changli Gao:
> Fix compiler warnings when no transport protocol load balancing support
> is configured.

Thanks Changli, I'll apply your patch once one of the IPVS developers
ACKs this.
