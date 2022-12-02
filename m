From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri, 2 Dec 2022 11:02:04 +0100
Message-ID: <Y4nNHHfIY7iEvMgr@vergenet.net>
References: <20221202032511.1435-1-liqiong@nfschina.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20221202032511.1435-1-liqiong@nfschina.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Qiong <liqiong@nfschina.com>
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>

On Fri, Dec 02, 2022 at 11:25:11AM +0800, Li Qiong wrote:
> The 'ret' should need to be initialized to 0, in case
> return a uninitialized value because no default process
> for "switch (cmd)".
> 
> Signed-off-by: Li Qiong <liqiong@nfschina.com>

Thanks,

I agree there seems to be a problem here.  But perhaps it's nicer to solve
it by adding a default case to the switch statement?

Also, if we update the declaration of ret, perhaps we could also move it to
the bottom of the declaration of local variables, to move more towards
reverse xmas tree order.

But to be honest, I don't feel strongly about either of these issues.

So if someone wants to take this patch as-is then feel free to add.

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 988222fff9f0..4b20db86077c 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2456,7 +2456,7 @@ static int
>  do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
>  {
>  	struct net *net = sock_net(sk);
> -	int ret;
> +	int ret = 0;
>  	unsigned char arg[MAX_SET_ARGLEN];
>  	struct ip_vs_service_user *usvc_compat;
>  	struct ip_vs_service_user_kern usvc;
> -- 
> 2.11.0
> 
