From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Sat, 11 May 2013 16:23:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
References: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg> <1368264745-15242-1-git-send-email-grzegorz.lyczba@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="280144257-605301336-1368278614=:1612"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1368264745-15242-1-git-send-email-grzegorz.lyczba@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: =?UTF-8?Q?Grzegorz_=C5=81yczba?= <grzegorz.lyczba@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--280144257-605301336-1368278614=:1612
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Sat, 11 May 2013, Grzegorz Łyczba wrote:

> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> 
> Expire cached connection for new TCP/SCTP connection if real server is down
> 
> Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

	The change looks correct but you have to fix some
coding style issues. Otherwise, patch will be rejected.
You can also check Documentation/CodingStyle

# scripts/checkpatch.pl /tmp/patch.diff
WARNING: braces {} are not necessary for single statement blocks
#25: FILE: net/netfilter/ipvs/ip_vs_core.c:1012:
+               if (th == NULL) {
+                       return false;
+               }

WARNING: braces {} are not necessary for single statement blocks
#34: FILE: net/netfilter/ipvs/ip_vs_core.c:1021:
+               if (sch == NULL) {
+                       return false;
+               }

total: 0 errors, 2 warnings, 48 lines checked

> ---
>  net/netfilter/ipvs/ip_vs_core.c |   36 ++++++++++++++++++++++++++++++++++++
>  1 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 47edf5a..9ee8b70 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1002,6 +1002,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
>  	return th->rst;
>  }
>  
> +static inline bool is_new_conn(const struct sk_buff *skb,
> +	    struct ip_vs_iphdr *iph)

	Above "struct" should be at the same column as "const"
in first argument, like this:

static inline bool is_new_conn(const struct sk_buff *skb,
			       struct ip_vs_iphdr *iph)

> +{
> +	switch (iph->protocol) {

	I'm still not sure if this construct is allowed:

	case ...: {
	}

	May be it should be:

	case ...:
		{
		}
	case ...

	but CodingStyle does not include rules about it.
If in doubt, you can use 'if' instead of 'switch' without
adding new indentation.

> +	case IPPROTO_TCP: {
> +		struct tcphdr _tcph, *th;

	empty line is needed here

> +		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> +		if (th == NULL) {
> +			return false;

	extra braces

> +		}
> +		return th->syn;
> +	}
> +	case IPPROTO_SCTP: {
> +		sctp_chunkhdr_t *sch, schunk;

	empty line is needed here

> +		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
> +				sizeof(schunk), &schunk);
> +		if (sch == NULL) {
> +			return false;

	extra braces

> +		}
> +		return (sch->type == SCTP_CID_INIT);
> +	}
> +	default:
> +		return false;
> +	}
> +}
> +
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1627,6 +1654,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 * Check if the packet belongs to an existing connection entry
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
> +
> +	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
> +	    !iph.fragoffs && unlikely(!atomic_read(&cp->dest->weight)) &&

	Lets move '!iph.fragoffs' after the
'unlikely(!atomic_read(&cp->dest->weight))' because fragoffs
is usually 0. Only IPv6 can see fragments at that point.

> +	    is_new_conn(skb, &iph)) {
> +		ip_vs_conn_expire_now(cp);
> +		__ip_vs_conn_put(cp);
> +		cp = NULL;
> +	}
> +
>  	if (unlikely(!cp) && !iph.fragoffs) {
>  		/* No (second) fragments need to enter here, as nf_defrag_ipv6
>  		 * replayed fragment zero will already have created the cp
> -- 
> 1.7.5.4

Regards

--
Julian Anastasov <ja@ssi.bg>
--280144257-605301336-1368278614=:1612--
