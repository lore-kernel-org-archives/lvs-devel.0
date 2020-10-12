From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v8 net-next] ipvs: inspect reply packets from DR/TUN real
 servers
Date: Mon, 12 Oct 2020 02:02:23 +0200
Message-ID: <20201012000223.GA14420@salvia>
References: <20201005201347.13644-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20201005201347.13644-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, "longguang.yue" <bigclouds@163.com>, yuelongguang@gmail.com

On Mon, Oct 05, 2020 at 11:13:47PM +0300, Julian Anastasov wrote:
> From: longguang.yue <bigclouds@163.com>
> 
> Just like for MASQ, inspect the reply packets coming from DR/TUN
> real servers and alter the connection's state and timeout
> according to the protocol.
> 
> It's ipvs's duty to do traffic statistic if packets get hit,
> no matter what mode it is.

Applied, thanks.
