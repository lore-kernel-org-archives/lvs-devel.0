From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 3/4] IPVS: Backup, Adding Version 1 receive
 capability
Date: Sat, 30 Oct 2010 15:47:10 +0900
Message-ID: <20101030064710.GJ26727@verge.net.au>
References: <1288354599-10919-3-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288354599-10919-3-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 29, 2010 at 02:16:38PM +0200, Hans Schillstrom wrote:
> Functionality improvements
>  * flags  changed from 16 to 32 bits
>  * fwmark added (32 bits)
>  * timeout in sec. added (32 bits)
>  * pe data added (Variable length)
>  * IPv6 capabilities (3x16 bytes for addr.)
>  * Version and type in every conn msg.
> 
> ip_vs_process_message() now handles Version 1 messages
> and will call ip_vs_process_message_v0() for version 0 messages.
> 
> ip_vs_proc_conn() is common for both version, and handles the update of
> connection hash.
> 
> ip_vs_conn_fill_param_sync()    - Version 1 messages only

Perhaps ip_vs_conn_fill_param_sync_v1() would be a better name?

> ip_vs_conn_fill_param_sync_v0() - Version 0 messages only
> 
> *v2
>  A new option format added as with opt,opt-len,data
>  as a general way to add options to a conn entry.
>  timeout is now in seconds
>  fwmark is not in ip_vs_conn_param any more.
>  Mask for flags received by backup.
>  Basically all changes implements Julians comments.


I think that you need the patch
"IPVS: Add persistence engine to connection entry" that I posted,
or something similar in your series in order for connection
templates with created by synchronisation to have the correct
persistence engine associated with them.

> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/linux/ip_vs.h           |    8 +
>  net/netfilter/ipvs/ip_vs_sync.c |  468 +++++++++++++++++++++++++++++----------
>  2 files changed, 358 insertions(+), 118 deletions(-)
> 
> diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
> index 5f43a3b..4deb383 100644
> --- a/include/linux/ip_vs.h
> +++ b/include/linux/ip_vs.h
> @@ -89,6 +89,14 @@
>  #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
>  #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
>  
> +#define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
> +				  IP_VS_CONN_F_NOOUTPUT | \
> +				  IP_VS_CONN_F_INACTIVE | \
> +				  IP_VS_CONN_F_SEQ_MASK | \
> +				  IP_VS_CONN_F_NO_CPORT | \
> +				  IP_VS_CONN_F_TEMPLATE \
> +				 )
> +
>  /* Flags that are not sent to backup server start from bit 16 */
>  #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
>  
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index f7f115d..5aa8e04 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -15,6 +15,7 @@
>   *	Alexandre Cassen	:	Added SyncID support for incoming sync
>   *					messages filtering.
>   *	Justin Ossevoort	:	Fix endian problem on sync message size.
> +  *	Hans Schillstrom	: 	Added IPv6 and Persistence support

There is an extra leading space and a trailing space after the :
on the line above.

>   */
>  
>  #define KMSG_COMPONENT "IPVS"
> @@ -412,53 +413,173 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
>  		ip_vs_sync_conn(cp->control);
>  }
>  
> +/*
> + * fill_param used for proto version 0
> + */
>  static inline int
> -ip_vs_conn_fill_param_sync(int af, int protocol,
> -			   const union nf_inet_addr *caddr, __be16 cport,
> -			   const union nf_inet_addr *vaddr, __be16 vport,
> +ip_vs_conn_fill_param_sync_v0(int af, struct ip_vs_sync_conn_v0 *sc,
>  			   struct ip_vs_conn_param *p)
>  {
> -	/* XXX: Need to take into account persistence engine */
> -	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
> +	ip_vs_conn_fill_param(af, sc->protocol,
> +			   (const union nf_inet_addr *)&sc->caddr,
> +			   sc->cport,
> +			   (const union nf_inet_addr *)&sc->vaddr,
> +			   sc->vport, p);

Please align line-wrapped parameters against the opening (

	ip_vs_conn_fill_param(af, sc->protocol,
			      (const union nf_inet_addr *)&sc->caddr,
			      sc->cport,
			      (const union nf_inet_addr *)&sc->vaddr,
			      sc->vport, p);

Also several more times below.
This also applies to function definitions.

Actually, I think p_vs_conn_fill_param_sync_v0() can be
replaced by a direct call to ip_vs_conn_fill_param(). But
my comments regarding formatting still apply elsewhere.

>  	return 0;
>  }
>  
>  /*
> - *      Process received multicast message and create the corresponding
> - *      ip_vs_conn entries.
> + *  fill_param used by version 1
>   */

I realise that the commenting syntax used throughout IPVS
is a) inconsistent and b) for the most part does not comply with
any variant of the style guidelines. However, for the record
I believe that the preferred commenting style for code in net/
and thus IPVS is:

/* This is a one line comment */

/* This is a
 * multi-line comment
 */

									
> -static void ip_vs_process_message(const char *buffer, const size_t buflen)
> +static inline int
> +ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
> +			   struct ip_vs_conn_param *p, char *pe_data,
> +			   int pe_data_len, char *pe_name, int pe_name_len )
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if ( af == AF_INET6 )
> +		ip_vs_conn_fill_param(af, sc->v6.protocol,
> +				   (const union nf_inet_addr *)&sc->v6.caddr,
> +				   sc->v6.cport,
> +				   (const union nf_inet_addr *)&sc->v6.vaddr,
> +				   sc->v6.vport, p);

I'm ok with not aligning to the opening ( in order to avoid
going over 80 columns here. Though I suspect others would disagree.

> +	else
> +#endif
> +		ip_vs_conn_fill_param(af, sc->v4.protocol,
> +				   (const union nf_inet_addr *)&sc->v4.caddr,
> +				   sc->v4.cport,
> +				   (const union nf_inet_addr *)&sc->v4.vaddr,
> +				   sc->v4.vport, p);
> +	/* Handle pe data */
> +	if (pe_data_len && pe_data ) {
> +		IP_VS_DBG(10, "%s() pe_data=%s\n", __func__, pe_data);
> +		p->pe_data = kmalloc(pe_data_len, GFP_ATOMIC);
> +		if (!p->pe_data)
> +			return -ENOMEM;
> +		memcpy(p->pe_data, pe_data, pe_data_len);
> +		p->pe_data_len = pe_data_len;
> +		if (pe_name && pe_name_len) {
> +			p->pe = ip_vs_pe_get(pe_name);
> +			IP_VS_DBG(10, "%s() pe_name=%s\n", __func__, pe_name);
> +		}
> +	}
> +	return 0;
> +}
> +
> +/*
> + *  Connection Add / Update.
> + *  Common for version 0 and 1 reception of backup messages.
> + *  Param: ...
> + *         timeout is in sec.
> + */
> +static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
> +		            unsigned state, unsigned protocol, unsigned type,
> +		            const union nf_inet_addr *daddr, __be16 dport,
> +		            unsigned long timeout, __u32 fwmark,
> +		            struct ip_vs_sync_conn_options *opt,
> +		            struct ip_vs_protocol *pp )
> +{
> +	struct ip_vs_dest *dest;
> +	struct ip_vs_conn *cp;
> +
> +
> +	if (!(flags & IP_VS_CONN_F_TEMPLATE))
> +		cp = ip_vs_conn_in_get(param);
> +	else
> +		cp = ip_vs_ct_in_get(param);
> +	if (!cp) {
> +		/*
> +		 * Find the appropriate destination for the connection.
> +		 * If it is not found the connection will remain unbound
> +		 * but still handled.
> +		 */
> +		dest = ip_vs_find_dest(type, daddr, dport, param->vaddr,
> +				       param->vport, protocol, fwmark);
> +		/*  Set the approprite ativity flag */
> +		if (protocol == IPPROTO_TCP) {
> +			if (state != IP_VS_TCP_S_ESTABLISHED)
> +				flags |= IP_VS_CONN_F_INACTIVE;
> +			else
> +				flags &= ~IP_VS_CONN_F_INACTIVE;
> +		} else if (protocol == IPPROTO_SCTP) {
> +			if (state != IP_VS_SCTP_S_ESTABLISHED)
> +				flags |= IP_VS_CONN_F_INACTIVE;
> +			else
> +				flags &= ~IP_VS_CONN_F_INACTIVE;
> +		}
> +		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
> +		if (dest)
> +			atomic_dec(&dest->refcnt);
> +		if (!cp) {
> +			pr_err("ip_vs_conn_new failed\n");
> +			return;
> +		}
> +	} else if (!cp->dest) {
> +		dest = ip_vs_try_bind_dest(cp);
> +		if (dest)
> +			atomic_dec(&dest->refcnt);
> +	} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
> +		   (cp->state != state)) {
> +		/* update active/inactive flag for the connection */
> +		dest = cp->dest;
> +		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +			(state != IP_VS_TCP_S_ESTABLISHED)) {
> +			atomic_dec(&dest->activeconns);
> +			atomic_inc(&dest->inactconns);
> +			cp->flags |= IP_VS_CONN_F_INACTIVE;
> +		} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +			(state == IP_VS_TCP_S_ESTABLISHED)) {
> +			atomic_inc(&dest->activeconns);
> +			atomic_dec(&dest->inactconns);
> +			cp->flags &= ~IP_VS_CONN_F_INACTIVE;
> +		}
> +	} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
> +		   (cp->state != state)) {
> +		dest = cp->dest;
> +		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +		     (state != IP_VS_SCTP_S_ESTABLISHED)) {
> +		    atomic_dec(&dest->activeconns);
> +		    atomic_inc(&dest->inactconns);
> +		    cp->flags &= ~IP_VS_CONN_F_INACTIVE;
> +		}
> +	}
> +
> +	if (opt)
> +		memcpy(&cp->in_seq, opt, sizeof(*opt));
> +	atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
> +	cp->state = state;
> +	cp->old_state = cp->state;
> +	/*
> +	 * For old messages style
> +	 *  - Not possible to recover the right timeout for templates
> +	 *  - can not find the right fwmark
> +	 *    virtual service. If needed, we can do it for
> +	 *    non-fwmark persistent services.
> +	 * New messages style
> +	 *  - No problem.
> +	 */
> +	if (timeout)
> +		cp->timeout = timeout*HZ;
> +	else if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
> +		cp->timeout = pp->timeout_table[state];
> +	else
> +		cp->timeout = (3*60*HZ);
> +	ip_vs_conn_put(cp);
> +}
> +
> +/*
> + *  Process received multicast message for Version 0
> + */
> +static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
>  {
>  	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
>  	struct ip_vs_sync_conn_v0 *s;
>  	struct ip_vs_sync_conn_options *opt;
> -	struct ip_vs_conn *cp;
>  	struct ip_vs_protocol *pp;
> -	struct ip_vs_dest *dest;
>  	struct ip_vs_conn_param param;
>  	char *p;
>  	int i;
>  
> -	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
> -		IP_VS_ERR_RL("sync message header too short\n");
> -		return;
> -	}
> -
> -	/* Convert size back to host byte order */
> -	m->size = ntohs(m->size);
> -
> -	if (buflen != m->size) {
> -		IP_VS_ERR_RL("bogus sync message size\n");
> -		return;
> -	}
> -
> -	/* SyncID sanity check */
> -	if (ip_vs_backup_syncid != 0 && m->syncid != ip_vs_backup_syncid) {
> -		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
> -			  m->syncid);
> -		return;
> -	}
> -
>  	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
>  	for (i=0; i<m->nr_conns; i++) {
>  		unsigned flags, state;
> @@ -505,103 +626,214 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
>  			}
>  		}
>  
> -		{
> -			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> -					      (union nf_inet_addr *)&s->caddr,
> -					      s->cport,
> -					      (union nf_inet_addr *)&s->vaddr,
> -					      s->vport, &param)) {
> -				pr_err("ip_vs_conn_fill_param_sync failed");
> -				return;
> -			}
> -			if (!(flags & IP_VS_CONN_F_TEMPLATE))
> -				cp = ip_vs_conn_in_get(&param);
> -			else
> -				cp = ip_vs_ct_in_get(&param);
> +		if (ip_vs_conn_fill_param_sync_v0(AF_INET, s, &param)) {
> +			pr_err("ip_vs_conn_fill_param_sync failed");
> +			return;
>  		}

I think we can just replace this with a direct call to
ip_vs_conn_fill_param() and avoid the need for error checking.

The idea of the existing ip_vs_conn_fill_param_sync() was as a place holder.
But this patch fills in the relevant bits in the v1 version of that function.

> -		if (!cp) {
> -			/*
> -			 * Find the appropriate destination for the connection.
> -			 * If it is not found the connection will remain unbound
> -			 * but still handled.
> -			 */
> -			dest = ip_vs_find_dest(AF_INET,
> -					       (union nf_inet_addr *)&s->daddr,
> -					       s->dport,
> -					       (union nf_inet_addr *)&s->vaddr,
> -					       s->vport,
> -					       s->protocol, 0);
> -			/*  Set the approprite ativity flag */
> -			if (s->protocol == IPPROTO_TCP) {
> -				if (state != IP_VS_TCP_S_ESTABLISHED)
> -					flags |= IP_VS_CONN_F_INACTIVE;
> -				else
> -					flags &= ~IP_VS_CONN_F_INACTIVE;
> -			} else if (s->protocol == IPPROTO_SCTP) {
> -				if (state != IP_VS_SCTP_S_ESTABLISHED)
> -					flags |= IP_VS_CONN_F_INACTIVE;
> -				else
> -					flags &= ~IP_VS_CONN_F_INACTIVE;
> +		/* Send timeout as Zero */
> +		ip_vs_proc_conn(&param, flags, state, s-> protocol, AF_INET,
> +				(union nf_inet_addr *)&s->daddr, s->dport,
> +				0, 0, opt, pp );
> +
> +	}
> +}
> +
> +/*
> + *      Process received multicast message and create the corresponding
> + *      ip_vs_conn entries.
> + *      Handles Version 0 & 1
> + */
> +static void ip_vs_process_message(const char *buffer, const size_t buflen)
> +{
> +	struct ip_vs_sync_mesg_v2 *m2 = (struct ip_vs_sync_mesg_v2 *)buffer;
> +	union  ip_vs_sync_conn *s;
> +	struct ip_vs_protocol *pp;
> +	struct ip_vs_conn_param param;
> +	char *p;
> +	int i, af, nr_conns;
> +
> +	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
> +		IP_VS_ERR_RL("sync message header too short\n");
> +		return;
> +	}
> +
> +	/* Convert size back to host byte order */
> +	m2->size = ntohs(m2->size);
> +
> +	if (buflen != m2->size) {
> +		IP_VS_ERR_RL("bogus sync message size\n");
> +		return;
> +	}
> +
> +	/* SyncID sanity check */
> +	if (ip_vs_backup_syncid != 0 && m2->syncid != ip_vs_backup_syncid) {
> +		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
> +			  m2->syncid);
> +		return;
> +	}
> +	/* Prepare ptrs for version 1 or 2 message */
> +	if ( m2->version==SYNC_PROTO_VER && m2->reserverd==0 && m2->spare==0) {

There shouldn't be a space between '(' and 'm2'.
There should be a space either side of each '=='.

> +	       p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v2);

This cast seems nasty to me. Is it there to un-const buffer?
If so I think it would be better just remove the const qualification
from the parameter, as its clearly not being used in a const way.

The patch "IPVS: buffer argument to ip_vs_process_message() should not be const"
from my prototype series was my attempt to address this.

> +	       nr_conns = m2->nr_conns;
> +	       IP_VS_DBG(7, "%s Message v 1, %d bytes with %d conns\n",
> +			 __func__, m2->size & SVER_MASK, m2->nr_conns);
> +	} else {
> +		/* Old type of message */
> +		ip_vs_process_message_v0(buffer, buflen);
> +		return;
> +	}
> +
> +	for (i=0; i<nr_conns; i++) {
> +		char *msgEnd;
> +		__u32 flags;
> +		unsigned state, size, opt_flags=0;
> +		struct ip_vs_sync_conn_options opt;
> +		char *pe_data=NULL, *pe_name=NULL;
> +		unsigned pe_data_len=0, pe_name_len=0;
> +		unsigned unknownOpt=0;

Please don't use camelCaps.

> +
> +		s = (union ip_vs_sync_conn *) p;
> +		size = ntohs(s->v4.ver_size) & SVER_MASK;
> +		msgEnd = p + size;
> +
> +		if (msgEnd  > buffer+buflen) {
> +			IP_VS_ERR_RL("bogus conn/size in sync message\n");
> +			return;
> +		}
> +		if (ntohs( s->v4.ver_size) >> SVER_SHIFT) {
> +			IP_VS_ERR_RL("Unknown version %d in sync message\n",
> +					ntohs( s->v4.ver_size) >> SVER_SHIFT);
> +			return;
> +		}
> +
> +		if (s->v6.type & STYPE_INET6  ) {
> +#ifdef CONFIG_IP_VS_IPV6
> +			af = AF_INET6;
> +			p += sizeof(struct ip_vs_sync_v6);
> +#else
> +			IP_VS_DBG(2,"IPv6 sync message received, and IPVS is not compiled for IPv6\n");
> +			p = (char *)s + size;		

There is trailing whitespace on the line above.

> +			continue;
> +#endif
> +		} else {
> +			af = AF_INET;
> +			p += sizeof(struct ip_vs_sync_v4);
> +		}
> +		/* Mask off unsupported flags */
> +		flags  = ntohl(s->v4.flags) & IP_VS_CONN_F_BACKUP_MASK;
> +		flags |= IP_VS_CONN_F_SYNC;
> +		state = ntohs(s->v4.state);
> +
> +		if (p > buffer+buflen) {
> +			IP_VS_ERR_RL("bogus conn in sync message\n");
> +			return;
> +		}
> +		/* Process options check optType & optLen
> +		 *      *p = opt type
> +		 *   *(p+1)= opt len
> +		 */
> +		while ( p< msgEnd && *p && *(p+1) && p + *(p+1) < msgEnd ) {
> +			switch (*(p++) & 0x7f) {
> +			/* Handle seq option  *p = opt len */
> +			case IPVS_OPT_SEQ_DATA:
> +				if(*p != sizeof(struct ip_vs_sync_conn_options)) {
> +					IP_VS_ERR_RL("bogus conn options in sync message\n");
> +					return;
> +				}
> +				memcpy((void*)&opt, p+1, *p);
> +				opt_flags |= IPVS_OPT_F_SEQ_DATA;
> +				break;
> +
> +			case IPVS_OPT_PE_DATA:
> +				if (*p > IP_VS_PEDATA_MAXLEN) {
> +					IP_VS_ERR_RL("bogus pe_data len in sync message\n");
> +					return;
> +				}
> +				pe_data_len = *p;
> +				pe_data = p+1;
> +				opt_flags |= IPVS_OPT_F_PE_DATA;
> +				break;
> +			case IPVS_OPT_PE_NAME:
> +				if (*p > (IP_VS_PENAME_MAXLEN+1)) {
> +					IP_VS_ERR_RL("bogus pe_name len in sync message\n");
> +					return;
> +				}
> +				pe_name_len = *p;
> +				pe_name = p+1;
> +				if (*(p+pe_name_len)) {
> +					IP_VS_ERR_RL("bogus pe_name no trailing null in sync message\n");
> +					return;
> +				}
> +				opt_flags |= IPVS_OPT_F_PE_NAME;
> +				break;
> +			default:
> +				/* Optional data ? */
> +				if( !(*(p-1) & STYPE_OPT_DATA)) {
> +					IP_VS_ERR_RL("Unknown mandatory option found %d in sync message\n", *(p-1));
> +					return;
> +				}
> +				IP_VS_DBG(2,"Unknown option found %d in sync message\n",
> +					     *(p-1));
> +				unknownOpt = 1;
>  			}
> -			cp = ip_vs_conn_new(&param,
> -					    (union nf_inet_addr *)&s->daddr,
> -					    s->dport, flags, dest, 0);
> -			if (dest)
> -				atomic_dec(&dest->refcnt);
> -			if (!cp) {
> -				pr_err("ip_vs_conn_new failed\n");
> -				return;
> +			p += (*p) + 1;  /* Next option */
> +		}
> +		if (unknownOpt)
> +			continue;	/* Skip this take next */
> +
> +
> +		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
> +			pp = ip_vs_proto_get(s->v4.protocol);
> +			if (!pp) {
> +				IP_VS_ERR_RL("Unsupported protocol %u in sync msg\n",
> +					s->v4.protocol);
> +				continue;
>  			}
> -		} else if (!cp->dest) {
> -			dest = ip_vs_try_bind_dest(cp);
> -			if (dest)
> -				atomic_dec(&dest->refcnt);
> -		} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
> -			   (cp->state != state)) {
> -			/* update active/inactive flag for the connection */
> -			dest = cp->dest;
> -			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> -				(state != IP_VS_TCP_S_ESTABLISHED)) {
> -				atomic_dec(&dest->activeconns);
> -				atomic_inc(&dest->inactconns);
> -				cp->flags |= IP_VS_CONN_F_INACTIVE;
> -			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
> -				(state == IP_VS_TCP_S_ESTABLISHED)) {
> -				atomic_inc(&dest->activeconns);
> -				atomic_dec(&dest->inactconns);
> -				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
> +			if (state >= pp->num_states) {
> +				IP_VS_DBG(2, "Invalid %s state %u in sync msg\n",
> +					pp->name, state);
> +				continue;
>  			}
> -		} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
> -			   (cp->state != state)) {
> -			dest = cp->dest;
> -			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> -			     (state != IP_VS_SCTP_S_ESTABLISHED)) {
> -			    atomic_dec(&dest->activeconns);
> -			    atomic_inc(&dest->inactconns);
> -			    cp->flags &= ~IP_VS_CONN_F_INACTIVE;
> +		} else {
> +			/* protocol in templates is not used for state/timeout */
> +			pp = NULL;
> +			if (state > 0) {
> +				IP_VS_DBG(2, "Invalid template state %u in sync msg\n",
> +					state);
> +				state = 0;
>  			}
>  		}
> -
> -		if (opt)
> -			memcpy(&cp->in_seq, opt, sizeof(*opt));
> -		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
> -		cp->state = state;
> -		cp->old_state = cp->state;
> -		/*
> -		 * We can not recover the right timeout for templates
> -		 * in all cases, we can not find the right fwmark
> -		 * virtual service. If needed, we can do it for
> -		 * non-fwmark persistent services.
> -		 */
> -		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
> -			cp->timeout = pp->timeout_table[state];
> +		if (ip_vs_conn_fill_param_sync(af, s, &param,
> +				               pe_data, pe_data_len,
> +				               pe_name, pe_name_len)) {
> +			pr_err("ip_vs_conn_fill_param_sync failed");
> +			return;
> +		}
> +		/* If only IPv4, just silent skip IPv6 */
> +		if ( af == AF_INET )
> +			ip_vs_proc_conn(&param, flags, state, s->v4.protocol,
> +					af,
> +					(union nf_inet_addr *)&s->v4.daddr,
> +				        s->v4.dport, ntohl(s->v4.timeout),
> +				        ntohl(s->v4.fwmark),
> +				        (opt_flags & IPVS_OPT_F_SEQ_DATA
> +				         ? &opt : NULL),
> +				        pp);
> +#ifdef CONFIG_IP_VS_IPV6
>  		else
> -			cp->timeout = (3*60*HZ);
> -		ip_vs_conn_put(cp);
> -	}
> +			ip_vs_proc_conn(&param, flags, state, s->v6.protocol,
> +					af,
> +					(union nf_inet_addr *)&s->v6.daddr,
> +					s->v6.dport, ntohl(s->v6.timeout),
> +					ntohl(s->v6.fwmark),
> +				        (opt_flags & IPVS_OPT_F_SEQ_DATA
> +				          ? &opt : NULL),
> +				        pp);
> +#endif

I am very happy to see the timeout issue addressed :-)

> +		p = (char *)s + size;
> +	} /* End of for(...) */
>  }
>  
> -

This change is spurious.

>  /*
>   *      Setup loopback of outgoing multicasts on a sending socket
>   */
> -- 
> 1.7.0.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
