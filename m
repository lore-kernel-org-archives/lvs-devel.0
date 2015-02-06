From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix inability to remove a mixed-family RS
Date: Fri, 6 Feb 2015 22:27:52 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502062217360.4440@ja.home.ssi.bg>
References: <54D516C4.8080504@al-an.info>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54D516C4.8080504@al-an.info>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexey Andriyanov <alan@al-an.info>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Alex Gartrell <agartrell@fb.com>


	Hello,

On Fri, 6 Feb 2015, Alexey Andriyanov wrote:

> The current code prevents any operation with a mixed-family dest
> unless IP_VS_CONN_F_TUNNEL flag is set. The problem is that it's impossible
> for the client to follow this rule, because ip_vs_genl_parse_dest does
> not even read the destination conn_flags when cmd = IPVS_CMD_DEL_DEST
> (need_full_dest = 0).
> 
> Also, not every client can pass this flag when removing a dest. ipvsadm,
> for example, does not support the "-i" command line option together with
> the "-d" option.
> 
> This change disables any checks for mixed-family on IPVS_CMD_DEL_DEST command.
> 
> Signed-off-by: Alexey Andriyanov <alan@al-an.info>

	Good catch.

Fixes: bc18d37f676f ("ipvs: Allow heterogeneous pools now that we support them")
Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply this bug fix.

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ac7ba68..5b373c3 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3400,7 +3400,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
>                 if (udest.af == 0)
>                         udest.af = svc->af;
>  
> -               if (udest.af != svc->af) {
> +               if (udest.af != svc->af && cmd != IPVS_CMD_DEL_DEST) {
>                         /* The synchronization protocol is incompatible
>                          * with mixed family services
>                          */
> -- 
> 1.7.9.5
> 

Regards

--
Julian Anastasov <ja@ssi.bg>
