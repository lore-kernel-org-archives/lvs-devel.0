From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 2/4] IPVS: Backup, Adding structs for new sync format
Date: Sat, 30 Oct 2010 15:38:30 +0900
Message-ID: <20101030063830.GA24530@verge.net.au>
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

[ snip ]

> @@ -113,6 +226,17 @@ struct ip_vs_sync_mesg {
>  	/* ip_vs_sync_conn entries start here */
>  };
>  
> +/* Version 1 header */
> +struct ip_vs_sync_mesg_v2 {
> +	__u8			reserverd;	/* must be zero */

reserverd -> reserved.

> +	__u8                    syncid;
> +	__u16                   size;
> +	__u8                    nr_conns;
> +	__s8                    version;	/* SYNC_PROTO_VER  */
> +	__u16			spare;
> +	/* ip_vs_sync_conn entries start here */
> +};
> +
>  /* the maximum length of sync (sending/receiving) message */
>  static int sync_send_mesg_maxlen;
>  static int sync_recv_mesg_maxlen;

[ snip ]
