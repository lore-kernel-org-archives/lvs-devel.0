From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] libipvs: Remove redundant CHECK_PE
Date: Tue, 20 Aug 2013 17:54:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308201752370.1698@ja.ssi.bg>
References: <1377008983-23901-1-git-send-email-rohara@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1377008983-23901-1-git-send-email-rohara@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Tue, 20 Aug 2013, Ryan O'Hara wrote:

> Since the CHECK_COMPAT_SVC macro calls CHECK_PE, remove the extra
> CHECK_PE call from ipvs_get_service().
> 
> Signed-off-by: Ryan O'Hara <rohara@redhat.com>

	Thanks, looks good,

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  libipvs/libipvs.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> index ef242db..309ccce 100644
> --- a/libipvs/libipvs.c
> +++ b/libipvs/libipvs.c
> @@ -965,7 +965,6 @@ ipvs_get_service_err2:
>  #endif
>  
>  	CHECK_COMPAT_SVC(svc, NULL);
> -	CHECK_PE(svc, NULL);
>  	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_SERVICE,
>  		       (char *)svc, &len)) {
>  		free(svc);
> -- 
> 1.8.1.4

Regards

--
Julian Anastasov <ja@ssi.bg>
