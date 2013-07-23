From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next] net/sctp: Refactor SCTP skb checksum computation
Date: Tue, 23 Jul 2013 10:14:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1307230948590.1676@ja.ssi.bg>
References: <1374553858-9963-1-git-send-email-joe@wand.net.nz>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1374553858-9963-1-git-send-email-joe@wand.net.nz>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Stringer <joe@wand.net.nz>
Cc: davem@davemloft.net, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, pablo@netfilter.org, horms@verge.net.au, jesse@nicira.com


	Hello,

On Tue, 23 Jul 2013, Joe Stringer wrote:

> This patch consolidates the SCTP checksum calculation code from various
> places to a single new function, sctp_compute_cksum(skb, offset).
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> ---
>  include/net/sctp/checksum.h           |   15 +++++++++++++++
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |   23 ++++-------------------
>  net/netfilter/nf_nat_proto_sctp.c     |    8 +-------
>  net/sctp/input.c                      |   10 +---------
>  4 files changed, 21 insertions(+), 35 deletions(-)
> 
> diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> index 0cb08e6..8675564 100644
> --- a/include/net/sctp/checksum.h
> +++ b/include/net/sctp/checksum.h
> @@ -85,4 +85,19 @@ static inline __le32 sctp_end_cksum(__u32 crc32)
>  	return cpu_to_le32(~crc32);
>  }
>  
> +/* Calculate the CRC32C checksum of an SCTP packet.  */
> +static inline __le32 sctp_compute_cksum(const struct sk_buff *skb,
> +					unsigned int offset)
> +{
> +	const struct sk_buff *iter;
> +
> +	__u32 crc32 = sctp_start_cksum((__u8 *)sctp_hdr(skb),
> +				       skb_headlen(skb) - offset);

	sctp_hdr() is valid in INPUT hook after commit
21d1196a35f5686c4323e42a62fdb4b23b0ab4a3 (ipv4: set transport header
earlier) but I'm not sure for the OUTPUT hook where
IPVS is working. I guess the same is valid for Netfilter.

	IPVS uses skb_network_header(skb) + offset but
I guess it can work with skb->data, just like Netfilter:

	__u32 crc32 = sctp_start_cksum(skb->data + offset,

	This should work also in SCTP where skb->data points
to the SCTP header when sctp_rcv_checksum() is called.

> +	skb_walk_frags(skb, iter)
> +		crc32 = sctp_update_cksum((__u8 *) iter->data,
> +					  skb_headlen(iter), crc32);
> +
> +	return sctp_end_cksum(crc32);
> +}
> +
>  #endif /* __sctp_checksum_h__ */
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 3c0da87..b2e422d 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -66,15 +66,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
>  			  unsigned int sctphoff)
>  {
> -	__u32 crc32;
> -	struct sk_buff *iter;
> -
> -	crc32 = sctp_start_cksum((__u8 *)sctph, skb_headlen(skb) - sctphoff);
> -	skb_walk_frags(skb, iter)
> -		crc32 = sctp_update_cksum((u8 *) iter->data,
> -					  skb_headlen(iter), crc32);
> -	sctph->checksum = sctp_end_cksum(crc32);
> +	__le32 crc32 = sctp_compute_cksum(skb, sctphoff);

	crc32 var is not needed anymore, eg:

	sctph->checksum = sctp_compute_cksum(skb, sctphoff);

> +	sctph->checksum = crc32;
>  	skb->ip_summed = CHECKSUM_UNNECESSARY;
>  }
>  
> @@ -151,10 +145,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>  {
>  	unsigned int sctphoff;
>  	struct sctphdr *sh, _sctph;
> -	struct sk_buff *iter;
> -	__le32 cmp;
> -	__le32 val;
> -	__u32 tmp;
> +	__le32 cmp, val;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (af == AF_INET6)
> @@ -168,13 +159,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
>  		return 0;
>  
>  	cmp = sh->checksum;
> -
> -	tmp = sctp_start_cksum((__u8 *) sh, skb_headlen(skb));
> -	skb_walk_frags(skb, iter)
> -		tmp = sctp_update_cksum((__u8 *) iter->data,
> -					skb_headlen(iter), tmp);
> -
> -	val = sctp_end_cksum(tmp);
> +	val = sctp_compute_cksum(skb, 0);

	The original code has bug here, still the code
was never used because there are no IPVS apps with
SCTP support. You can safely use sctphoff here, not 0, eg:

	val = sctp_compute_cksum(skb, sctphoff);

>  	if (val != cmp) {
>  		/* CRC failure, dump it. */

Regards

--
Julian Anastasov <ja@ssi.bg>
