From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Linux-kernel-mentees] [PATCH net-next v2] ipvs: Fix uninit-value
 in do_ip_vs_set_ctl()
Date: Tue, 11 Aug 2020 13:29:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2008111324570.7428@ja.home.ssi.bg>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com> <20200811074640.841693-1-yepeilin.cs@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20200811074640.841693-1-yepeilin.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peilin Ye <yepeilin.cs@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Cong Wang <xiyou.wangcong@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org


	Hello,

On Tue, 11 Aug 2020, Peilin Ye wrote:

> do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> zero. Fix it.
> 
> Reported-by: syzbot+23b5f9e7caf61d9a3898@syzkaller.appspotmail.com
> Link: https://syzkaller.appspot.com/bug?id=46ebfb92a8a812621a001ef04d90dfa459520fe2
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Peilin Ye <yepeilin.cs@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> Changes in v2:
>     - Target net-next tree. (Suggested by Julian Anastasov <ja@ssi.bg>)
>     - Reject all `len == 0` requests except `IP_VS_SO_SET_FLUSH`, instead
>       of initializing `arg`. (Suggested by Cong Wang
>       <xiyou.wangcong@gmail.com>, Julian Anastasov <ja@ssi.bg>)
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 412656c34f20..beeafa42aad7 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2471,6 +2471,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  		/* Set timeout values for (tcp tcpfin udp) */
>  		ret = ip_vs_set_timeout(ipvs, (struct ip_vs_timeout_user *)arg);
>  		goto out_unlock;
> +	} else if (!len) {
> +		/* No more commands with len == 0 below */
> +		ret = -EINVAL;
> +		goto out_unlock;
>  	}
>  
>  	usvc_compat = (struct ip_vs_service_user *)arg;
> @@ -2547,9 +2551,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  		break;
>  	case IP_VS_SO_SET_DELDEST:
>  		ret = ip_vs_del_dest(svc, &udest);
> -		break;
> -	default:
> -		ret = -EINVAL;
>  	}
>  
>    out_unlock:
> -- 
> 2.25.1

Regards
