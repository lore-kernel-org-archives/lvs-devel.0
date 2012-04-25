From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] ipvs: fix crash in ip_vs_control_net_cleanup on
 unload
Date: Wed, 25 Apr 2012 11:15:29 +0200
Message-ID: <20120425091529.GB15049@1984>
References: <1335186732-16002-1-git-send-email-horms@verge.net.au>
 <1335186732-16002-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335186732-16002-3-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sasha Levin <levinsasha928@gmail.com>, stable@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

On Mon, Apr 23, 2012 at 10:12:12PM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
> ("Add __ip_vs_control_{init,cleanup}_sysctl()")
> introduced regression due to wrong __net_init for
> __ip_vs_control_cleanup_sysctl. This leads to crash when
> the ip_vs module is unloaded.
> 
> 	Fix it by changing __net_init to __net_exit for
> the function that is already renamed to ip_vs_control_net_cleanup_sysctl.
> 
> Cc: stable@vger.kernel.org

Removed this above.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

And applied, thanks Simon.
