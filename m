From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: specify real server address family to netlink
 socket
Date: Sat, 30 Aug 2014 14:26:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408301420540.1671@ja.home.ssi.bg>
References: <1409347657-6489-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1409347657-6489-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team@fb.com, Jesper Dangaard Brouer <brouer@redhat.com>


	Hello,

On Fri, 29 Aug 2014, Alex Gartrell wrote:

> This is necessary for supporting heterogeneous pools (v4 and v6 mixed
> pools).
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

	Looks good to me. Jesper, please apply.
It does not hurt even if kernel has no support yet.
I'm even preparing 2 related patches...

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  ipvsadm.c         | 2 +-
>  libipvs/ip_vs.h   | 3 +++
>  libipvs/libipvs.c | 8 +++++++-
>  3 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 602bcf6..d12070e 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1624,7 +1624,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  		char *dname;
>  		ipvs_dest_entry_t *e = &d->entrytable[i];
>  
> -		if (!(dname = addrport_to_anyname(se->af, &(e->addr), ntohs(e->port),
> +		if (!(dname = addrport_to_anyname(e->af, &(e->addr), ntohs(e->port),
>  						  se->protocol, format))) {
>  			fprintf(stderr, "addrport_to_anyname fails\n");
>  			exit(1);
> diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
> index 4db14ff..5a42a0c 100644
> --- a/libipvs/ip_vs.h
> +++ b/libipvs/ip_vs.h
> @@ -470,6 +470,9 @@ enum {
>  	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */
>  
>  	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
> +
> +	IPVS_DEST_ATTR_ADDR_FAMILY,	/* Address family of address */
> +
>  	__IPVS_DEST_ATTR_MAX,
>  };
>  
> diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
> index 8baafed..0bfb428 100644
> --- a/libipvs/libipvs.c
> +++ b/libipvs/libipvs.c
> @@ -350,6 +350,7 @@ static int ipvs_nl_fill_dest_attr(struct nl_msg *msg, ipvs_dest_t *dst)
>  	if (!nl_dest)
>  		return -1;
>  
> +	NLA_PUT_U16(msg, IPVS_DEST_ATTR_ADDR_FAMILY, dst->af);
>  	NLA_PUT(msg, IPVS_DEST_ATTR_ADDR, sizeof(dst->addr), &(dst->addr));
>  	NLA_PUT_U16(msg, IPVS_DEST_ATTR_PORT, dst->port);
>  	NLA_PUT_U32(msg, IPVS_DEST_ATTR_FWD_METHOD, dst->conn_flags & IP_VS_CONN_F_FWD_MASK);
> @@ -751,6 +752,7 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
>  	struct nlmsghdr *nlh = nlmsg_hdr(msg);
>  	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
>  	struct nlattr *dest_attrs[IPVS_DEST_ATTR_MAX + 1];
> +	struct nlattr *attr_addr_family = NULL;
>  	struct ip_vs_get_dests **dp = (struct ip_vs_get_dests **)arg;
>  	struct ip_vs_get_dests *d = (struct ip_vs_get_dests *)*dp;
>  	int i = d->num_dests;
> @@ -788,7 +790,11 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
>  	d->entrytable[i].activeconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_ACTIVE_CONNS]);
>  	d->entrytable[i].inactconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_INACT_CONNS]);
>  	d->entrytable[i].persistconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_PERSIST_CONNS]);
> -	d->entrytable[i].af = d->af;
> +	attr_addr_family = dest_attrs[IPVS_DEST_ATTR_ADDR_FAMILY];
> +	if (attr_addr_family)
> +		d->entrytable[i].af = nla_get_u16(attr_addr_family);
> +	else
> +		d->entrytable[i].af = d->af;
>  
>  	if (ipvs_parse_stats(&(d->entrytable[i].stats),
>  			     dest_attrs[IPVS_DEST_ATTR_STATS]) != 0)
> -- 
> 1.8.1

Regards

--
Julian Anastasov <ja@ssi.bg>
