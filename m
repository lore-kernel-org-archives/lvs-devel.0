From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg size
Date: Thu, 18 Apr 2013 20:43:30 +0900
Message-ID: <20130418114325.GA11486@verge.net.au>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
 <1366231850-22188-5-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366231850-22188-5-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Wed, Apr 17, 2013 at 11:50:48PM +0300, Julian Anastasov wrote:
> 	Fix sparse warnings while changing the
> size between host and network order:
> 
> net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> net/netfilter/ipvs/ip_vs_sync.c:1550:19: warning: incorrect type in
> 	assignment (different base types)
> net/netfilter/ipvs/ip_vs_sync.c:1550:19:    expected unsigned short
> 	[unsigned] [usertype] size
> net/netfilter/ipvs/ip_vs_sync.c:1550:19:    got restricted __be16
> 	[usertype] <noident>
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I'm not very excited by the use of __force.
Can't we change the type of the size element
of struct ip_vs_sync_mesg and use the sparse annotations
to our advantage?

> ---
>  net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 8e57077..ff7f2ad 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1176,7 +1176,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
>  		return;
>  	}
>  	/* Convert size back to host byte order */
> -	m2->size = ntohs(m2->size);
> +	m2->size = ntohs((__force __be16) m2->size);
>  
>  	if (buflen != m2->size) {
>  		IP_VS_DBG(2, "BACKUP, bogus message size\n");
> @@ -1547,7 +1547,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
>  	msize = msg->size;
>  
>  	/* Put size in network byte order */
> -	msg->size = htons(msg->size);
> +	msg->size = (__force __u16) htons(msg->size);
>  
>  	ret = ip_vs_send_async(sock, (char *)msg, msize);
>  	if (ret >= 0 || ret == -EAGAIN)
> -- 
> 1.7.3.4
> 
