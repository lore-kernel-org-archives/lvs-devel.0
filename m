From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch nf] ipvs: initialize tbl->entries in
 ip_vs_lblc_init_svc()
Date: Tue, 24 Apr 2018 08:17:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1804240816210.2470@ja.home.ssi.bg>
References: <20180423210445.18336-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180423210445.18336-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Mon, 23 Apr 2018, Cong Wang wrote:

> Similarly, tbl->entries is not initialized after kmalloc(),
> therefore causes an uninit-value warning in ip_vs_lblc_check_expire(),
> as reported by syzbot.
> 
> Reported-by: <syzbot+3e9695f147fb529aa9bc@syzkaller.appspotmail.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

	Thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_lblc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index 3057e453bf31..83918119ceb8 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -371,6 +371,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
>  	tbl->counter = 1;
>  	tbl->dead = false;
>  	tbl->svc = svc;
> +	atomic_set(&tbl->entries, 0);
>  
>  	/*
>  	 *    Hook periodic timer for garbage collection
> -- 
> 2.13.0

Regards
