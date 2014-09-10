From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: do not truncate ipv6 members of v4 services
Date: Wed, 10 Sep 2014 09:38:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409100930500.22206@ja.home.ssi.bg>
References: <1410329806-1840-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1410329806-1840-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: brouer@redhat.com, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com


	Hello,

On Tue, 9 Sep 2014, Alex Gartrell wrote:

> We need to compare to the entry af instead of the service af or else we'll
> pop a nul byte into the middle of a v6 real server address.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

	Jesper, I think you can now push all recent
changes to the ipvsadm tree. This includes:

ipvsadm: specify real server address family to netlink socket
by Alex, from August 29

ipvsadm: restrict different address family
ipvsadm: allow different address family in connection listing
by me, from August 30

and finally this patch.

> ---
>  ipvsadm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index d12070e..ef19091 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -1629,7 +1629,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  			fprintf(stderr, "addrport_to_anyname fails\n");
>  			exit(1);
>  		}
> -		if (!(format & FMT_RULE) && (se->af != AF_INET6))
> +		if (!(format & FMT_RULE) && (e->af != AF_INET6))
>  			dname[28] = '\0';
>  
>  		if (format & FMT_RULE) {
> -- 
> 1.8.1

Regards

--
Julian Anastasov <ja@ssi.bg>
