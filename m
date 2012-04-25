From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH v2 2/2] ipvs: add check in ftp for initialized core
Date: Wed, 25 Apr 2012 09:49:37 +0200
Message-ID: <201204250949.38101.hans.schillstrom@ericsson.com>
References: <1335302999-10702-1-git-send-email-ja@ssi.bg> <1335302999-10702-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335302999-10702-3-git-send-email-ja@ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

On Tuesday 24 April 2012 23:29:59 Julian Anastasov wrote:
> 	Avoid crash when registering ip_vs_ftp after
> the IPVS core initialization for netns fails. Do this by
> checking for present core (net->ipvs).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/netfilter/ipvs/ip_vs_ftp.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 538d74e..e39f693 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -439,6 +439,8 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>  	struct ip_vs_app *app;
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	if (!ipvs)
> +		return -ENOENT;
>  	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
>  	if (!app)
>  		return -ENOMEM;

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
