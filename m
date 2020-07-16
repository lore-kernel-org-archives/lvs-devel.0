From: Suraj Upadhyay <usuraj35@gmail.com>
Subject: Re: [PATCH v2] ipvs: clean code for ip_vs_sync.c
Date: Thu, 16 Jul 2020 08:16:27 +0530
Message-ID: <20200716024627.GC14742@blackclown>
References: <1594864671-31512-1-git-send-email-zhouxudong8@huawei.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Uzn9PWVj4WS08RyvZ3rZ6i+MQl/MospPRV6X8a72+XI=;
        b=ZjtkaWExqHD3WVnf7gYkKwcr4vEObP3tgfFu0uQsBRxgqDT0wK5JARW8jmVqa7nIi6
         E/HT8vc4Wyx6XT5wVQU09+x9Qirns7pDI/FXdH7W+6wBR6j/BvI6V8wxYtlW7BqIDyKe
         D7l38H/sNQEdo8gj0hzrMnS1Mew4mJYrVzsIq7OrHr1DtX0uo6oxgNGaUsEhLBxHinOr
         nlXXW/dB0lULwFzdg1Qdc9blWk2ZDKdvAZ8UA/4RD+gVx4kmT11MjIEAkzYx5OvTDuhC
         Vamj59kUqK8EJnLphUKN/Kh/Q+9Pnq8SBHAfa9Axb1w82du1UbrNOOKkYCXtJwFOjl5v
         KCFw==
Content-Disposition: inline
In-Reply-To: <1594864671-31512-1-git-send-email-zhouxudong8@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: zhouxudong199 <zhouxudong8@huawei.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, rose.chen@huawei.com, zhaowei23@huawei.com

On Thu, Jul 16, 2020 at 01:57:51AM +0000, zhouxudong199 wrote:
> v1 -> v2:
> add missing spaces after Signed-off-by and ipvs: in the subject. 
> i=0 changed to i = 0.  
>

You should write the version changes after "---" and before the first
diff.

Also, looking at your patch I think your commit message should be
something like this :

"Use appropriate spaces around operators."

> Signed-off-by: zhouxudong199 <zhouxudong8@huawei.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 605e0f6..885bab4 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1077,10 +1077,10 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  	struct ip_vs_protocol *pp;
>  	struct ip_vs_conn_param param;
>  	__u32 flags;
> -	unsigned int af, state, pe_data_len=0, pe_name_len=0;
> -	__u8 *pe_data=NULL, *pe_name=NULL;
> -	__u32 opt_flags=0;
> -	int retc=0;
> +	unsigned int af, state, pe_data_len = 0, pe_name_len = 0;
> +	__u8 *pe_data = NULL, *pe_name = NULL;
> +	__u32 opt_flags = 0;
> +	int retc = 0;
>  
>  	s = (union ip_vs_sync_conn *) p;
>  
> @@ -1089,7 +1089,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  		af = AF_INET6;
>  		p += sizeof(struct ip_vs_sync_v6);
>  #else
> -		IP_VS_DBG(3,"BACKUP, IPv6 msg received, and IPVS is not compiled for IPv6\n");
> +		IP_VS_DBG(3, "BACKUP, IPv6 msg received, and IPVS is not compiled for IPv6\n");
>  		retc = 10;
>  		goto out;
>  #endif
> @@ -1129,7 +1129,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  			break;
>  
>  		case IPVS_OPT_PE_NAME:
> -			if (ip_vs_proc_str(p, plen,&pe_name_len, &pe_name,
> +			if (ip_vs_proc_str(p, plen, &pe_name_len, &pe_name,
>  					   IP_VS_PENAME_MAXLEN, &opt_flags,
>  					   IPVS_OPT_F_PE_NAME))
>  				return -70;
> @@ -1155,7 +1155,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
>  		pp = ip_vs_proto_get(s->v4.protocol);
>  		if (!pp) {
> -			IP_VS_DBG(3,"BACKUP, Unsupported protocol %u\n",
> +			IP_VS_DBG(3, "BACKUP, Unsupported protocol %u\n",
>  				s->v4.protocol);
>  			retc = 30;
>  			goto out;
> @@ -1232,7 +1232,7 @@ static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
>  		msg_end = buffer + sizeof(struct ip_vs_sync_mesg);
>  		nr_conns = m2->nr_conns;
>  
> -		for (i=0; i<nr_conns; i++) {
> +		for (i = 0; i < nr_conns; i++) {
>  			union ip_vs_sync_conn *s;
>  			unsigned int size;
>  			int retc;
> @@ -1444,7 +1444,7 @@ static int bind_mcastif_addr(struct socket *sock, struct net_device *dev)
>  	sin.sin_addr.s_addr  = addr;
>  	sin.sin_port         = 0;

I think you missed this one.
should be
-        sin.sin_port         = 0;
+	 sin.sin_port = 0

Thanks and Cheers,
Suraj Upadhyay.

> -	return sock->ops->bind(sock, (struct sockaddr*)&sin, sizeof(sin));
> +	return sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
>  }
>  
>  static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
> -- 
> 2.6.1.windows.1
> 
> 
