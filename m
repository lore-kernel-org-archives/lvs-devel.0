From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipvs: get sctphdr by sctphoff in sctp_csum_check
Date: Mon, 25 Feb 2019 22:19:58 +0200 (EET)
Message-ID: <alpine.LFD.2.21.1902252213460.3472@ja.home.ssi.bg>
References: <cd1c829cfd9ee916e57c51f6879947f0f88c1eb1.1551094063.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <cd1c829cfd9ee916e57c51f6879947f0f88c1eb1.1551094063.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xin Long <lucien.xin@gmail.com>
Cc: network dev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Mon, 25 Feb 2019, Xin Long wrote:

> sctp_csum_check() is called by sctp_s/dnat_handler() where it calls
> skb_make_writable() to ensure sctphdr to be linearized.
> 
> So there's no need to get sctphdr by calling skb_header_pointer()
> in sctp_csum_check().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	I guess, it is for the nf-next/net-next tree because it just
eliminates a duplicate check.

> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index b0cd7d0..0ecf241 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -183,7 +183,7 @@ static int
>  sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>  {
>  	unsigned int sctphoff;
> -	struct sctphdr *sh, _sctph;
> +	struct sctphdr *sh;
>  	__le32 cmp, val;
>  
>  #ifdef CONFIG_IP_VS_IPV6
> @@ -193,10 +193,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>  #endif
>  		sctphoff = ip_hdrlen(skb);
>  
> -	sh = skb_header_pointer(skb, sctphoff, sizeof(_sctph), &_sctph);
> -	if (sh == NULL)
> -		return 0;
> -
> +	sh = (struct sctphdr *)(skb->data + sctphoff);
>  	cmp = sh->checksum;
>  	val = sctp_compute_cksum(skb, sctphoff);
>  
> -- 
> 2.1.0

Regards
