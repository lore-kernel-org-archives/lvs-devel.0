From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg
 size
Date: Fri, 19 Apr 2013 22:35:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304192228380.1788@ja.ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg> <1366231850-22188-5-git-send-email-ja@ssi.bg> <20130418114325.GA11486@verge.net.au> <alpine.LFD.2.00.1304182215060.1842@ja.ssi.bg> <20130419014952.GA25718@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130419014952.GA25718@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Fri, 19 Apr 2013, Simon Horman wrote:

> My idea is as follows:
> 
> From: Simon Horman <horms@verge.net.au>
> 
> ipvs: Use network byte order for sync message size
> 
> struct ip_vs_sync_mesg is both sent across the wire and
> used internally to store IPVS synchronisation messages.
> 
> Up until now the scheme used has been to convert the size field
> to network byte order before sending a message on the wire and
> convert it to host byte order when sending a message.
> 
> This patch changes that scheme to always treat the field
> as being network byte order. This seems appropriate as
> the structure is sent across the wire. And by consistently
> treating the field has network byte order it is now possible
> to take advantage of sparse to flag any future miss-use.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c |   15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 8e57077..c73778a 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
>  struct ip_vs_sync_mesg {
>  	__u8			reserved;	/* must be zero */
>  	__u8			syncid;
> -	__u16			size;
> +	__be16			size;

	It seems v0 should be changed too,
ip_vs_send_sync_msg() handles both versions in sb->mesg.

> @@ -1544,10 +1542,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
>  	int msize;
>  	int ret;
>  
> -	msize = msg->size;
> -
> -	/* Put size in network byte order */
> -	msg->size = htons(msg->size);
> +	msize = ntohs(msg->size);
>  
>  	ret = ip_vs_send_async(sock, (char *)msg, msize);
>  	if (ret >= 0 || ret == -EAGAIN)

Regards

--
Julian Anastasov <ja@ssi.bg>
