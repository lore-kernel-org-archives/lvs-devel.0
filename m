From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvsadm: Fix svc->pe_name conditional
Date: Mon, 19 Aug 2013 18:17:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308191816010.1606@ja.ssi.bg>
References: <1376924188-14556-1-git-send-email-rohara@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1376924188-14556-1-git-send-email-rohara@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Mon, 19 Aug 2013, Ryan O'Hara wrote:

> The pe_name in ipvs_service_t is an array, so comparing it NULL has no
> effect. Check first byte of pe_name.
> 
> Signed-off-by: Ryan O'Hara <rohara@redhat.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  libipvs/libipvs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> index 2b066d2..89f26b9 100644
> --- a/libipvs/libipvs.c
> +++ b/libipvs/libipvs.c
> @@ -45,7 +45,7 @@ static int family, try_nl = 1;
>  	{ errno = EAFNOSUPPORT; return ret; }			\
>  	s->__addr_v4 = s->addr.ip;				\
>  
> -#define CHECK_PE(s, ret) if (s->pe_name)			\
> +#define CHECK_PE(s, ret) if (s->pe_name[0])			\
>  	{ errno = EAFNOSUPPORT; return ret; }
>  
>  #define CHECK_COMPAT_DEST(s, ret) CHECK_IPV4(s, ret)
> @@ -234,7 +234,7 @@ static int ipvs_nl_fill_service_attr(struct nl_msg *msg, ipvs_service_t *svc)
>  	}
>  
>  	NLA_PUT_STRING(msg, IPVS_SVC_ATTR_SCHED_NAME, svc->sched_name);
> -	if (svc->pe_name)
> +	if (svc->pe_name[0])
>  		NLA_PUT_STRING(msg, IPVS_SVC_ATTR_PE_NAME, svc->pe_name);
>  	NLA_PUT(msg, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
>  	NLA_PUT_U32(msg, IPVS_SVC_ATTR_TIMEOUT, svc->timeout);
> -- 
> 1.8.1.4

Regards

--
Julian Anastasov <ja@ssi.bg>
