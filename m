From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH stable] ipvs: sctp: fix checksumming on snat and dnat
 handlers
Date: Thu, 21 Feb 2013 10:14:51 -0500
Message-ID: <20130221151451.GB2730@shamino.rdu.redhat.com>
References: <cover.1361451476.git.dborkman@redhat.com>
 <f904dab20914b562ad9c0baf0727971dc5a4b549.1361451476.git.dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f904dab20914b562ad9c0baf0727971dc5a4b549.1361451476.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>

On Thu, Feb 21, 2013 at 02:05:39PM +0100, Daniel Borkmann wrote:
> In our test lab, we have a simple SCTP client connecting to a SCTP
> server via an IPVS load balancer. On some machines, load balancing
> works, but on others the initial handshake just fails, thus no
> SCTP connection whatsoever can be established!
> 
> We observed that the SCTP INIT-ACK handshake reply from the IPVS
> machine to the client had a correct IP checksum, but corrupt SCTP
> checksum when forwarded, thus on the client-side the packet was
> dropped and an intial handshake retriggered until all attempts
> run into the void.
> 
> To fix this issue, this patch i) adds a missing CHECKSUM_UNNECESSARY
> after the full checksum (re-)calculation (as done in IPVS TCP and UDP
> code as well), and ii) calculates the checksum in little-endian format
> (as fixed with the SCTP code in commit 4458f04c: sctp: Clean up sctp
> checksumming code). Stable backport of upstream commit 4b47bc9a.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 9f3fb75..94bb367 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -70,7 +70,7 @@ sctp_snat_handler(struct sk_buff *skb,
>  	sctp_sctphdr_t *sctph;
>  	unsigned int sctphoff;
>  	struct sk_buff *iter;
> -	__be32 crc32;
> +	__u32 crc32;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (cp->af == AF_INET6)
> @@ -101,8 +101,9 @@ sctp_snat_handler(struct sk_buff *skb,
>  	skb_walk_frags(skb, iter)
>  		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
>  				          crc32);
> -	crc32 = sctp_end_cksum(crc32);
> -	sctph->checksum = crc32;
> +	sctph->checksum = sctp_end_cksum(crc32);
> +
> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
>  	return 1;
>  }
> @@ -114,7 +115,7 @@ sctp_dnat_handler(struct sk_buff *skb,
>  	sctp_sctphdr_t *sctph;
>  	unsigned int sctphoff;
>  	struct sk_buff *iter;
> -	__be32 crc32;
> +	__u32 crc32;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (cp->af == AF_INET6)
> @@ -145,8 +146,9 @@ sctp_dnat_handler(struct sk_buff *skb,
>  	skb_walk_frags(skb, iter)
>  		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
>  					  crc32);
> -	crc32 = sctp_end_cksum(crc32);
> -	sctph->checksum = crc32;
> +	sctph->checksum = sctp_end_cksum(crc32);
> +
> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
>  	return 1;
>  }
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

