From: "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
Subject: Re: [PATCH] ipvs: Fix signed integer overflow when setsockopt timeout
Date: Mon, 14 Jan 2019 15:34:15 +0800
Message-ID: <184c4ac2-039a-a689-4408-f425c62e5897@huawei.com>
References: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

ping?

On 1/10/2019 4:39 PM, ZhangXiaoxu wrote:
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
> ---
>   net/netfilter/ipvs/ip_vs_ctl.c | 13 +++++++++++++
>   1 file changed, 13 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 432141f..444aaca 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2221,6 +2221,19 @@ static int ip_vs_set_timeout(struct netns_ipvs *ipvs, struct ip_vs_timeout_user
>   		  u->udp_timeout);
>   
>   #ifdef CONFIG_IP_VS_PROTO_TCP
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
>   	if (u->tcp_timeout) {
>   		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
>   		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
> 

