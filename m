From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix signed integer overflow when setsockopt timeout
Date: Mon, 14 Jan 2019 13:15:13 +0100
Message-ID: <20190114121513.mgj45pt3rrgomrqo@verge.net.au>
References: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1547468116; bh=q0uGdLLES+t5sFUFooZvAywzoTpwU9i4vC/x8D/aPnc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=MwxaTz/bvVd6cWirSr+vrH9EPKmTVdg0hP789z4bJbw5Yq0nwjUrXj7sswSsZyWG2
         Q3RAAPRqh3AkAaZ9BnxjVGBgBzADSQSO3IdfSRVsO2vhSCDiB8FcPyeaTaL3YwBIU/
         B0UEDjHM9GpO+/wZVHoyt5HWkIm7SCa72LomwJlk=
Content-Disposition: inline
In-Reply-To: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Thu, Jan 10, 2019 at 04:39:06PM +0800, ZhangXiaoxu wrote:
> There is a UBSAN bug report as below:
> UBSAN: Undefined behaviour in net/netfilter/ipvs/ip_vs_ctl.c:2227:21
> signed integer overflow:
> -2147483647 * 1000 cannot be represented in type 'int'
> 
> Reproduce program:
> 	#include <stdio.h>
> 	#include <sys/types.h>
> 	#include <sys/socket.h>
> 
> 	#define IPPROTO_IP 0
> 	#define IPPROTO_RAW 255
> 
> 	#define IP_VS_BASE_CTL		(64+1024+64)
> 	#define IP_VS_SO_SET_TIMEOUT	(IP_VS_BASE_CTL+10)
> 
> 	/* The argument to IP_VS_SO_GET_TIMEOUT */
> 	struct ipvs_timeout_t {
> 		int tcp_timeout;
> 		int tcp_fin_timeout;
> 		int udp_timeout;
> 	};
> 
> 	int main() {
> 		int ret = -1;
> 		int sockfd = -1;
> 		struct ipvs_timeout_t to;
> 
> 		sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
> 		if (sockfd == -1) {
> 			printf("socket init error\n");
> 			return -1;
> 		}
> 
> 		to.tcp_timeout = -2147483647;
> 		to.tcp_fin_timeout = -2147483647;
> 		to.udp_timeout = -2147483647;
> 
> 		ret = setsockopt(sockfd,
> 				 IPPROTO_IP,
> 				 IP_VS_SO_SET_TIMEOUT,
> 				 (char *)(&to),
> 				 sizeof(to));
> 
> 		printf("setsockopt return %d\n", ret);
> 		return ret;
> 	}
> 
> Return -EINVAL if the timeout value is negative or max than 'INT_MAX / HZ'.
> 
> Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>

Thanks, this looks good to me.

Pablo, could you consider applying this to nf?

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 432141f..444aaca 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2221,6 +2221,19 @@ static int ip_vs_set_timeout(struct netns_ipvs *ipvs, struct ip_vs_timeout_user
>  		  u->udp_timeout);
>  
>  #ifdef CONFIG_IP_VS_PROTO_TCP
> +	if (u->tcp_timeout < 0 || u->tcp_timeout > (INT_MAX / HZ) ||
> +	    u->tcp_fin_timeout < 0 || u->tcp_fin_timeout > (INT_MAX / HZ)) {
> +		return -EINVAL;
> +	}
> +#endif
> +
> +#ifdef CONFIG_IP_VS_PROTO_UDP
> +	if (u->udp_timeout < 0 || u->udp_timeout > (INT_MAX / HZ)) {
> +		return -EINVAL;
> +	}
> +#endif
> +
> +#ifdef CONFIG_IP_VS_PROTO_TCP
>  	if (u->tcp_timeout) {
>  		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
>  		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
> -- 
> 2.7.4
> 
