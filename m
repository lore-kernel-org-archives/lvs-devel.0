From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: support more FTP PASV responses
Date: Tue, 31 May 2011 22:27:23 +0900
Message-ID: <20110531132722.GI22140@verge.net.au>
References: <alpine.LFD.2.00.1105292354390.1429@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1105292354390.1429@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Mon, May 30, 2011 at 12:02:23AM +0300, Julian Anastasov wrote:
> 
> 	Change the parsing of FTP commands and responses to
> support skip character. It allows to detect variations in
> the 227 PASV response.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	As this is not exactly a fix, it can be applied to
> ipvs-next-2.6 after the merge window.

Thanks, will do.

> diff -urp v2.6.39/linux/net/netfilter/ipvs/ip_vs_ftp.c linux/net/netfilter/ipvs/ip_vs_ftp.c
> --- v2.6.39/linux/net/netfilter/ipvs/ip_vs_ftp.c	2011-05-20 10:38:08.000000000 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2011-05-29 11:51:50.630247073 +0300
> @@ -44,8 +44,8 @@
>  #include <net/ip_vs.h>
>  
>  
> -#define SERVER_STRING "227 Entering Passive Mode ("
> -#define CLIENT_STRING "PORT "
> +#define SERVER_STRING "227 "
> +#define CLIENT_STRING "PORT"
>  
>  
>  /*
> @@ -79,14 +79,17 @@ ip_vs_ftp_done_conn(struct ip_vs_app *ap
>  
>  /*
>   * Get <addr,port> from the string "xxx.xxx.xxx.xxx,ppp,ppp", started
> - * with the "pattern" and terminated with the "term" character.
> + * with the "pattern", ignoring before "skip" and terminated with
> + * the "term" character.
>   * <addr,port> is in network order.
>   */
>  static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
> -				  const char *pattern, size_t plen, char term,
> +				  const char *pattern, size_t plen,
> +				  char skip, char term,
>  				  __be32 *addr, __be16 *port,
>  				  char **start, char **end)
>  {
> +	char *s, c;
>  	unsigned char p[6];
>  	int i = 0;
>  
> @@ -101,19 +104,38 @@ static int ip_vs_ftp_get_addrport(char *
>  	if (strnicmp(data, pattern, plen) != 0) {
>  		return 0;
>  	}
> -	*start = data + plen;
> +	s = data + plen;
> +	if (skip) {
> +		int found = 0;
> +
> +		for (;; s++) {
> +			if (s == data_limit)
> +				return -1;
> +			if (!found) {
> +				if (*s == skip)
> +					found = 1;
> +			} else if (*s != skip) {
> +				break;
> +			}
> +		}
> +	}
>  
> -	for (data = *start; *data != term; data++) {
> +	for (data = s; ; data++) {
>  		if (data == data_limit)
>  			return -1;
> +		if (*data == term)
> +			break;
>  	}
>  	*end = data;
>  
>  	memset(p, 0, sizeof(p));
> -	for (data = *start; data != *end; data++) {
> -		if (*data >= '0' && *data <= '9') {
> -			p[i] = p[i]*10 + *data - '0';
> -		} else if (*data == ',' && i < 5) {
> +	for (data = s; ; data++) {
> +		c = *data;
> +		if (c == term)
> +			break;
> +		if (c >= '0' && c <= '9') {
> +			p[i] = p[i]*10 + c - '0';
> +		} else if (c == ',' && i < 5) {
>  			i++;
>  		} else {
>  			/* unexpected character */
> @@ -124,8 +146,9 @@ static int ip_vs_ftp_get_addrport(char *
>  	if (i != 5)
>  		return -1;
>  
> -	*addr = get_unaligned((__be32 *)p);
> -	*port = get_unaligned((__be16 *)(p + 4));
> +	*start = s;
> +	*addr = get_unaligned((__be32 *) p);
> +	*port = get_unaligned((__be16 *) (p + 4));
>  	return 1;
>  }
>  
> @@ -185,7 +208,8 @@ static int ip_vs_ftp_out(struct ip_vs_ap
>  
>  		if (ip_vs_ftp_get_addrport(data, data_limit,
>  					   SERVER_STRING,
> -					   sizeof(SERVER_STRING)-1, ')',
> +					   sizeof(SERVER_STRING)-1,
> +					   '(', ')',
>  					   &from.ip, &port,
>  					   &start, &end) != 1)
>  			return 1;
> @@ -345,7 +369,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
>  	 */
>  	if (ip_vs_ftp_get_addrport(data_start, data_limit,
>  				   CLIENT_STRING, sizeof(CLIENT_STRING)-1,
> -				   '\r', &to.ip, &port,
> +				   ' ', '\r', &to.ip, &port,
>  				   &start, &end) != 1)
>  		return 1;
>  
> 
