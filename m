From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg
 size
Date: Mon, 22 Apr 2013 08:39:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304220838030.1626@ja.ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg> <1366231850-22188-5-git-send-email-ja@ssi.bg> <20130418114325.GA11486@verge.net.au> <alpine.LFD.2.00.1304182215060.1842@ja.ssi.bg> <20130419014952.GA25718@verge.net.au> <alpine.LFD.2.00.1304192228380.1788@ja.ssi.bg>
 <20130422040520.GK15680@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130422040520.GK15680@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Mon, 22 Apr 2013, Simon Horman wrote:

> > 	It seems v0 should be changed too,
> > ip_vs_send_sync_msg() handles both versions in sb->mesg.
> 
> Thanks and sorry for missing that.
> How about this?
> 
> From: Simon Horman <horms@verge.net.au>
> 
> ipvs: Use network byte order for sync message size
> 
> struct ip_vs_sync_mesg and ip_vs_sync_mesg_v0 are both sent across the wire
> and used internally to store IPVS synchronisation messages.
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
> 
> ---
> 
> v2
> * As suggested by Julian Anastasov,
>   update struct ip_vs_sync_mesg_v0  as well as struct ip_vs_sync_mesg.

	v2 looks good,

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 8e57077..f6046d9 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -246,7 +246,7 @@ struct ip_vs_sync_thread_data {
>  struct ip_vs_sync_mesg_v0 {
>  	__u8                    nr_conns;
>  	__u8                    syncid;
> -	__u16                   size;
> +	__be16                  size;
>  
>  	/* ip_vs_sync_conn entries start here */
>  };
> @@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
>  struct ip_vs_sync_mesg {
>  	__u8			reserved;	/* must be zero */
>  	__u8			syncid;
> -	__u16			size;
> +	__be16			size;
>  	__u8			nr_conns;
>  	__s8			version;	/* SYNC_PROTO_VER  */
>  	__u16			spare;
> @@ -335,7 +335,7 @@ ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
>  	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zero now */
>  	sb->mesg->version = SYNC_PROTO_VER;
>  	sb->mesg->syncid = ipvs->master_syncid;
> -	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
> +	sb->mesg->size = htons(sizeof(struct ip_vs_sync_mesg));
>  	sb->mesg->nr_conns = 0;
>  	sb->mesg->spare = 0;
>  	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg);
> @@ -418,7 +418,7 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
>  	mesg = (struct ip_vs_sync_mesg_v0 *)sb->mesg;
>  	mesg->nr_conns = 0;
>  	mesg->syncid = ipvs->master_syncid;
> -	mesg->size = sizeof(struct ip_vs_sync_mesg_v0);
> +	mesg->size = htons(sizeof(struct ip_vs_sync_mesg_v0));
>  	sb->head = (unsigned char *)mesg + sizeof(struct ip_vs_sync_mesg_v0);
>  	sb->end = (unsigned char *)mesg + ipvs->send_mesg_maxlen;
>  	sb->firstuse = jiffies;
> @@ -582,7 +582,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
>  	}
>  
>  	m->nr_conns++;
> -	m->size += len;
> +	m->size = htons(ntohs(m->size) + len);
>  	buff->head += len;
>  
>  	/* check if there is a space for next one */
> @@ -693,7 +693,7 @@ sloop:
>  
>  	p = buff->head;
>  	buff->head += pad + len;
> -	m->size += pad + len;
> +	m->size = htons(ntohs(m->size) + pad + len);
>  	/* Add ev. padding from prev. sync_conn */
>  	while (pad--)
>  		*(p++) = 0;
> @@ -1175,10 +1175,8 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
>  		IP_VS_DBG(2, "BACKUP, message header too short\n");
>  		return;
>  	}
> -	/* Convert size back to host byte order */
> -	m2->size = ntohs(m2->size);
>  
> -	if (buflen != m2->size) {
> +	if (buflen != ntohs(m2->size)) {
>  		IP_VS_DBG(2, "BACKUP, bogus message size\n");
>  		return;
>  	}
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
> -- 
> 1.8.2.1

Regards

--
Julian Anastasov <ja@ssi.bg>
