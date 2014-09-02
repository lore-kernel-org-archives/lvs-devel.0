From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] ipvs: reduce stack usage for sockopt data
Date: Tue, 2 Sep 2014 13:31:40 +0200
Message-ID: <20140902113140.GA11323@salvia>
References: <1409120443-978-1-git-send-email-horms@verge.net.au>
 <1409120443-978-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409120443-978-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Andrey Utkin <andrey.krieger.utkin@gmail.com>, David Binderman <dcb314@hotmail.com>

Hi Simon, Julian,

On Wed, Aug 27, 2014 at 03:20:43PM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> Use macros and union to reserve the required stack space for
> sockopt data. Now the tables for commands should be more safe
> to extend. The checks added for readability are optimized by
> compiler, others warn at compile time if command uses too much
> stack or exceeds the storage of set_arglen and get_arglen.
> 
> As Dan Carpenter points out, we can run for unprivileged user,
> so we can silent some error messages.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> CC: Dan Carpenter <dan.carpenter@oracle.com>
> CC: Andrey Utkin <andrey.krieger.utkin@gmail.com>
> CC: David Binderman <dcb314@hotmail.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 102 +++++++++++++++++++++++------------------
>  1 file changed, 57 insertions(+), 45 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index fd3f444..0140e09 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2180,28 +2180,34 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
>  }
>  
>  
> -#define SET_CMDID(cmd)		(cmd - IP_VS_BASE_CTL)
> -#define SERVICE_ARG_LEN		(sizeof(struct ip_vs_service_user))
> -#define SVCDEST_ARG_LEN		(sizeof(struct ip_vs_service_user) +	\
> -				 sizeof(struct ip_vs_dest_user))
> -#define TIMEOUT_ARG_LEN		(sizeof(struct ip_vs_timeout_user))
> -#define DAEMON_ARG_LEN		(sizeof(struct ip_vs_daemon_user))
> -#define MAX_ARG_LEN		SVCDEST_ARG_LEN
> +#define SET_CMDID(cmd)			(cmd - IP_VS_BASE_CTL)
> +#define IP_VS_SET_CMDID(c, t)		[SET_CMDID(c)] = sizeof(t),
> +#define IP_VS_SET_CMDID_LEN(c, t)	t field_ ## c;
> +
> +struct ip_vs_svcdest_user {
> +	struct ip_vs_service_user	s;
> +	struct ip_vs_dest_user		d;
> +};
> +
> +#define IP_VS_SET_CMDID_TABLE(e)					\
> +	e(IP_VS_SO_SET_ADD,		struct ip_vs_service_user)	\
> +	e(IP_VS_SO_SET_EDIT,		struct ip_vs_service_user)	\
> +	e(IP_VS_SO_SET_DEL,		struct ip_vs_service_user)	\
> +	e(IP_VS_SO_SET_ADDDEST,		struct ip_vs_svcdest_user)	\
> +	e(IP_VS_SO_SET_DELDEST,		struct ip_vs_svcdest_user)	\
> +	e(IP_VS_SO_SET_EDITDEST,	struct ip_vs_svcdest_user)	\
> +	e(IP_VS_SO_SET_TIMEOUT,		struct ip_vs_timeout_user)	\
> +	e(IP_VS_SO_SET_STARTDAEMON,	struct ip_vs_daemon_user)	\
> +	e(IP_VS_SO_SET_STOPDAEMON,	struct ip_vs_daemon_user)	\
> +	e(IP_VS_SO_SET_ZERO,		struct ip_vs_service_user)
>  
>  static const unsigned char set_arglen[SET_CMDID(IP_VS_SO_SET_MAX)+1] = {
> -	[SET_CMDID(IP_VS_SO_SET_ADD)]		= SERVICE_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_EDIT)]		= SERVICE_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_DEL)]		= SERVICE_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_FLUSH)]		= 0,
> -	[SET_CMDID(IP_VS_SO_SET_ADDDEST)]	= SVCDEST_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_DELDEST)]	= SVCDEST_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_EDITDEST)]	= SVCDEST_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_TIMEOUT)]	= TIMEOUT_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_STARTDAEMON)]	= DAEMON_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_STOPDAEMON)]	= DAEMON_ARG_LEN,
> -	[SET_CMDID(IP_VS_SO_SET_ZERO)]		= SERVICE_ARG_LEN,
> +	IP_VS_SET_CMDID_TABLE(IP_VS_SET_CMDID)
>  };
>  
> +union ip_vs_set_arglen { IP_VS_SET_CMDID_TABLE(IP_VS_SET_CMDID_LEN) };

I see, basically, ip_vs_set_arglen expands to:

union ip_vs_set_arglen {
        struct struct ip_vs_service_user field_IP_VS_SO_SET_ADD;
        ...
};

> +#define MAX_SET_ARGLEN	sizeof(union ip_vs_set_arglen)

So MAX_SET_ARGLEN is set accordingly to allocate the maximum data size
that you can get from userspace in the stack, this seems correct to me.

I guess the target of these macros is to avoid code duplication, since
without the macros you also need:

static const unsigned char set_arglen[...] = {
        [SET_CMDID(IP_VS_SO_SET_ADD)] = sizeof(struct ip_vs_service_user),
        ...
};

which is quite similar to union ip_vs_set_arglen in the sense that
they relate the commands and the structure size in different ways.

However, unless this is saving us from more hassle that I'm
overlooking, I think it's better (in terms of readability) IMO to keep
the explicit definitions.

Let me know, thanks!
