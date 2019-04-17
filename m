From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipvs:set sock send/receive buffer correctly
Date: Wed, 17 Apr 2019 06:18:29 -0700
Message-ID: <60c11e72-99eb-fcde-e130-a35ecdc1d2d1@gmail.com>
References: <501e5522-1d69-7c67-a1bc-fd8502d3b5d1@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vkoxkn4VZXgP/wvxt6Ouomzj/8M228ZmcfFjY6/Q5YI=;
        b=aiqy09bu+01scWi6ccyj3f7Ql9d46Q86dJDDGdZJ564RgsC2gqUp9eGmownSwhGN8i
         e1GTcv7UHv/0w7iuMNmnj531EFJkHENsPCeoc98PaQiuBuZf4si0LYAK4Ovx+6e8yVr5
         WfMZfiSEVswHYD/mrFBQLPX9WtF9OcZBSV3UaqhqhnTzVbVmziA0fFISvXFvPUepRHW/
         Y8iRDjn7h7RB9mel9n07iXX1w3EKRW79COP6Yc5b/IiNUY7mdfPZID67d0NRGAcfU5on
         ooANrKbgWNcn6VSqiNJHyQIWrK8okWrRwqtQ0I9pACloSurzW+dvFFBL7E8wFQVMCN5M
         ZPyw==
In-Reply-To: <501e5522-1d69-7c67-a1bc-fd8502d3b5d1@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linmiaohe <linmiaohe@huawei.com>, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Mingfangsen <mingfangsen@huawei.com>, liujie165@huawei.com



On 04/17/2019 02:18 AM, linmiaohe wrote:
> From: Jie Liu <liujie165@huawei.com>
> 
> If we set sysctl_wmem_max or sysctl_rmem_max larger than INT_MAX,
> the send/receive buffer of sock will be an negative value. Same as
> when the val is larger than INT_MAX/2.
> 
> Fixes: 1c003b1580e2 ("ipvs: wakeup master thread")
> Reported-by: Qiang Ning <ningqiang1@huawei.com>
> Reviewed-by: Miaohe Lin <linmiaohe@huawei.com>
> Signed-off-by: Jie Liu <liujie165@huawei.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 2526be6b3d90..c0e4cbed6e74 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1278,14 +1278,12 @@ static void set_sock_size(struct sock *sk, int mode, int val)
>  	/* setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val)); */
>  	lock_sock(sk);
>  	if (mode) {
> -		val = clamp_t(int, val, (SOCK_MIN_SNDBUF + 1) / 2,
> -			      sysctl_wmem_max);
> -		sk->sk_sndbuf = val * 2;
> +		val = min_t(u32, val, sysctl_wmem_max);
> +		sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);

What prevents val * 2 to overflow ? 

Code in sock_setsockopt() looks quite different.

>  		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
>  	} else {
> -		val = clamp_t(int, val, (SOCK_MIN_RCVBUF + 1) / 2,
> -			      sysctl_rmem_max);
> -		sk->sk_rcvbuf = val * 2;
> +		val = min_t(u32, val, sysctl_rmem_max);
> +		sk->sk_rcvbuf = max_t(int, val * 2, SOCK_MIN_RCVBUF);
>  		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
>  	}
>  	release_sock(sk);
> 
