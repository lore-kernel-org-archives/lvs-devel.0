From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] IPVS netns shutdown/startup dead-lock
Date: Wed, 12 Oct 2011 18:33:42 +0200
Message-ID: <20111012163342.GB14338@1984>
References: <1318298075-23501-1-git-send-email-horms@verge.net.au>
 <1318298075-23501-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318298075-23501-2-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>, Hans Schillstrom <hans@schillstrom.com>

On Tue, Oct 11, 2011 at 10:54:35AM +0900, Simon Horman wrote:
> From: Hans Schillstrom <hans@schillstrom.com>
> 
> ip_vs_mutext is used by both netns shutdown code and startup
> and both implicit uses sk_lock-AF_INET mutex.
> 
> cleanup CPU-1         startup CPU-2
> ip_vs_dst_event()     ip_vs_genl_set_cmd()
>  sk_lock-AF_INET     __ip_vs_mutex
>                      sk_lock-AF_INET
> __ip_vs_mutex
> * DEAD LOCK *
> 
> A new mutex placed in ip_vs netns struct called sync_mutex is added.
> 
> Comments from Julian and Simon added.
> This patch has been running for more than 3 month now and it seems to work.
> 
> Ver. 3
>     IP_VS_SO_GET_DAEMON in do_ip_vs_get_ctl protected by sync_mutex
>     instead of __ip_vs_mutex as sugested by Julian.

Applied, thanks Simon.

http://1984.lsi.us.es/git/?p=net/.git;a=shortlog;h=refs/heads/nf
