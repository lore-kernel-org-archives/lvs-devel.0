From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Thu, 12 Jul 2012 17:39:37 +0200
Message-ID: <20120712153937.GB18793@1984>
References: <1341966327-16606-1-git-send-email-horms@verge.net.au>
 <1341966327-16606-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341966327-16606-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Jul 11, 2012 at 09:25:26AM +0900, Simon Horman wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	The FTP application indirectly depends on the
> nf_conntrack_ftp helper for proper NAT support. If the
> module is not loaded, IPVS can resize the packets for the
> command connection, eg. PASV response but the SEQ adjustment
> logic in ipv4_confirm is not called without helper.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
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

If you require FTP NAT support, then this depends on NF_NAT_FTP
instead of NF_CONNTRACK_FTP.
