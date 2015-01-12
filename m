From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: Enable to work display host name of IPv6
Date: Mon, 12 Jan 2015 22:05:13 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501122159020.2636@ja.home.ssi.bg>
References: <54AF9439.8040409@lab.ntt.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54AF9439.8040409@lab.ntt.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hibari Michiro <hibari.michiro@lab.ntt.co.jp>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>


	Hello,

On Fri, 9 Jan 2015, Hibari Michiro wrote:

> So far ipvsadm can not display host name of IPv6.
> This patch add process in the case of IPv6 for
> addr_to_host function.
> 
> Signed-off-by: Michiro Hibari <hibari.michiro@lab.ntt.co.jp>

	Looks good to me. Still, comment could be
better. Jesper, please apply!

Acked-by: Julian Anastasov <ja@ssi.bg>

	One day we should convert it to getnameinfo()

> ---
>  ipvsadm.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 72ddc8a..162d4a2 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1770,8 +1770,14 @@ static char * addr_to_host(int af, const void *addr)
>  {
>  	struct hostent *host;
> -	if ((host = gethostbyaddr((char *) addr,
> -				  sizeof(struct in_addr), af)) != NULL)
> +	if (af == AF_INET)
> +		host = gethostbyaddr((char *) addr,
> +				     sizeof(struct in_addr), af);
> +	else
> +		host = gethostbyaddr((char *) addr,
> +				     sizeof(struct in6_addr), af);
> +
> +	if (host != NULL)
>  		return (char *) host->h_name;
>  	else
>  		return (char *) NULL;
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
