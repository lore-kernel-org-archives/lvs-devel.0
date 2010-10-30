From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 2/4] IPVS: Backup, Adding structs for new sync format
Date: Sat, 30 Oct 2010 14:55:55 +0900
Message-ID: <20101030055555.GI26727@verge.net.au>
References: <1288354599-10919-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288354599-10919-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 29, 2010 at 02:16:37PM +0200, Hans Schillstrom wrote:
> New structs defined for version 1 of sync.
> 
>  * ip_vs_sync_v4       Ipv4 base format struct
>  * ip_vs_sync_v6       Ipv6 base format struct
> 
> *v2
>   ip_vs_sync_pe_opt removed due to new option/param handling.
>   Julians comments with options casus this change
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c |  144 ++++++++++++++++++++++++++++++++++++---
>  1 files changed, 134 insertions(+), 10 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 90ed9b3..f7f115d 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -43,11 +43,13 @@
>  #define IP_VS_SYNC_GROUP 0xe0000051    /* multicast addr - 224.0.0.81 */
>  #define IP_VS_SYNC_PORT  8848          /* multicast port */
>  
> +#define SYNC_PROTO_VER  1		/* Protocol version in header */
>  
>  /*
>   *	IPVS sync connection entry
> + *	Version 0, i.e. original version.
>   */
> -struct ip_vs_sync_conn {
> +struct ip_vs_sync_conn_v0 {
>  	__u8			reserved;
>  
>  	/* Protocol, addresses and port numbers */
> @@ -71,40 +73,151 @@ struct ip_vs_sync_conn_options {
>  	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
>  };
>  
> +/*
> +     Connection Message format
> +
> +       0                   1                   2                   3
> +       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |    Type       |    Protocol   | Ver.  |        Size           |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                         Flags                                 |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |            State              |         cport                 |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |            vport              |         dport                 |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                             fwmark                            |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                             timeout  (in sec.)                |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                              ...                              |
> +      |                        IP-Addresses  (v4 or v6)               |
> +      |                              ...                              |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      | Option Type   | Option Length |   Option data 16 bit aligned  |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               |
> +      |                              ...                              |
> +      |                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                               | Option Type   | Option Length |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                           Option data                         |
> +      | Last Option data should be 32 bit aligned                     |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +
> + * Type 1 messages IPv4
> + *
> + */
> +struct ip_vs_sync_v4 {
> +	__u8			type;
> +	__u8			protocol;       /* Which protocol (TCP/UDP) */
> +	__be16			ver_size;	/* Version msb 4 bits */
> +	/* Flags and state transition */
> +	__be32                  flags;          /* status flags */
> +	__be16                  state;          /* state info 	*/
> +	/* Protocol, addresses and port numbers */
> +	__be16			cport;
> +	__be16          	vport;
> +	__be16          	dport;
> +	__be32			fwmark;		/* Firewall mark from skb */
> +	__be32			timeout;	/* cp timeout */
> +	__be32	        	caddr;          /* client address */
> +	__be32		    	vaddr;          /* virtual address */
> +	__be32		        daddr;          /* destination address */
> +	/* The sequence options start here */
> +	/* PE data padded to 32bit alignment after seq. options */
> +};
> +/*
> + * Type 2 messages IPv6
> + */
> +struct ip_vs_sync_v6 {
> +	__u8			type;
> +	__u8			protocol;       /* Which protocol (TCP/UDP) */
> +	__be16			ver_size;	/* Version msb 4 bits */
> +	/* Flags and state transition */
> +	__be32                  flags;          /* status flags */
> +	__be16                  state;          /* state info 	*/
> +	/* Protocol, addresses and port numbers */
> +	__be16			cport;
> +	__be16          	vport;
> +	__be16          	dport;
> +	__be32			fwmark;		/* Firewall mark from skb */
> +	__be32			timeout;	/* cp timeout */
> +	struct in6_addr        	caddr;          /* client address */
> +	struct in6_addr    	vaddr;          /* virtual address */
> +	struct in6_addr         daddr;          /* destination address */
> +	/* The sequence options start here */
> +	/* PE data padded to 32bit alignment after seq. options */
> +};
> +
> +union ip_vs_sync_conn {
> +	struct ip_vs_sync_v4	v4;
> +	struct ip_vs_sync_v6	v6;
> +};
> +
> +/* Bits in Type field in above */
> +#define STYPE_INET6	 1
> +#define STYPE_INET6_PACK 2
> +#define STYPE_OPT_DATA 	 7
> +
> +#define SVER_SHIFT	12	/* Shift to get version */
> +#define SVER_MASK	0x0fff	/* Mask to strip version */
> +
> +#define IPVS_OPT_SEQ_DATA 	1
> +#define IPVS_OPT_PE_DATA	2
> +#define IPVS_OPT_PE_NAME	3
> +
> +#define IPVS_OPT_F_SEQ_DATA	(1 << (IPVS_OPT_SEQ_DATA-1))
> +#define IPVS_OPT_F_PE_DATA	(1 << (IPVS_OPT_PE_DATA))
> +#define IPVS_OPT_F_PE_NAME	(1 << (IPVS_OPT_PE_NAME))
> +
>  struct ip_vs_sync_thread_data {
>  	struct socket *sock;
>  	char *buf;
>  };
>  
> -#define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
> +#define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn_v0))
>  #define FULL_CONN_SIZE  \
> -(sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
> +(sizeof(struct ip_vs_sync_conn_v0) + sizeof(struct ip_vs_sync_conn_options))
>  
>  
>  /*
>    The master mulitcasts messages to the backup load balancers in the
>    following format.
>  
> + Versrion 1:

Versrion -> Version

>         0                   1                   2                   3
>         0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> -      |  Count Conns  |    SyncID     |            Size               |
> +      |      0        |    Syncid     |            Size               |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

The capitialisation of SyncID is inconsistent with
version 0 below.

> +      |  Count Conns  |   Version     | Spare set to Zero             |

I think that reserved is commonly used in these situations.
So, perhaps "Reserved, set to zero.

Also, if we use zero then it would be nice to do so for the first octet
of the message. Or use 0 in both cases.

It may also be worth noting that the first octet of the message,
the old count cons field, is set to zero in so that old v0-only
code will drop the message as being invalid.

>        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>        |                                                               |
>        |                    IPVS Sync Connection (1)                   |
>        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>        |                            .                                  |
> -      |                            .                                  |
> +      ~                            .                                  ~
>        |                            .                                  |
>        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>        |                                                               |
>        |                    IPVS Sync Connection (n)                   |
>        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +
> + Version 0 Header
> +       0                   1                   2                   3
> +       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |  Count Conns  |    SyncID     |            Size               |
> +      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> +      |                    IPVS Sync Connection (1)                   |
>  */
>  
>  #define SYNC_MESG_HEADER_LEN	4
>  #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
>  
> +/* Version 0 header */
>  struct ip_vs_sync_mesg {
>  	__u8                    nr_conns;
>  	__u8                    syncid;

[ snip ]
