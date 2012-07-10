From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Tue, 10 Jul 2012 17:57:56 +0900
Message-ID: <20120710085756.GA12776@verge.net.au>
References: <1341682332-4809-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341682332-4809-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sat, Jul 07, 2012 at 08:32:12PM +0300, Julian Anastasov wrote:
> 	The FTP application indirectly depends on the
> nf_conntrack_ftp helper for proper NAT support. If the
> module is not loaded, IPVS can resize the packets for the
> command connection, eg. PASV response but the SEQ adjustment
> logic in ipv4_confirm is not called without helper.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have added this to my ipvs-next tree
for inclusion in 3.6.

> ---
>  net/netfilter/ipvs/Kconfig |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index f987138..8b2cffd 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -250,7 +250,8 @@ comment 'IPVS application helper'
>  
>  config	IP_VS_FTP
>    	tristate "FTP protocol helper"
> -        depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT
> +	depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT && \
> +		NF_CONNTRACK_FTP
>  	select IP_VS_NFCT
>  	---help---
>  	  FTP is a protocol that transfers IP address and/or port number in
> -- 
> 1.7.3.4
> 
