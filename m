From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: avoid expiring many connections from timer
Date: Wed, 1 Jul 2020 10:17:47 +0200
Message-ID: <20200701081746.GA26945@salvia>
References: <20200620100355.4364-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200620100355.4364-1-ja@ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Andrew Sy Kim <kim.andrewsy@gmail.com>

On Sat, Jun 20, 2020 at 01:03:55PM +0300, Julian Anastasov wrote:
> Add new functions ip_vs_conn_del() and ip_vs_conn_del_put()
> to release many IPVS connections in process context.
> They are suitable for connections found in table
> when we do not want to overload the timers.
> 
> Currently, the change is useful for the dropentry delayed
> work but it will be used also in following patch
> when flushing connections to failed destinations.

Applied, thanks.
