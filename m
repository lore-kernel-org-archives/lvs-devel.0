From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netfilter: correct parsing of continuation lines in
 SIP headers
Date: Mon, 5 Sep 2016 18:12:26 +0200
Message-ID: <20160905161226.GA14958@salvia>
References: <20160830164819.A6zYgiNs5%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160830164819.A6zYgiNs5%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Aug 30, 2016 at 06:48:19PM +0200, Marco Angaroni wrote:
> Current parsing methods for SIP headers do not properly manage
> continuation lines: in case of Call-ID header the first character of
> Call-ID header value is truncated. As a result IPVS SIP persistence
> engine hashes over a call-id that is not exactly the one present in
> the originale message.
> 
> Example: "Call-ID: \r\n abcdeABCDE1234"
> results in extracted call-id equal to "bcdeABCDE1234".
> 
> In above example Call-ID is represented as a string in C language.
> Obviously in real message the first bytes after colon (":") are
> "20 0d 0a 20".
> 
> Proposed fix is in nf_conntrack_sip module.
> Since sip_follow_continuation() function walks past the leading
> spaces or tabs of the continuation line, sip_skip_whitespace()
> should simply return the ouput of sip_follow_continuation().
> Otherwise another iteration of the for loop is done and dptr
> is incremented by one pointing to the second character of the
> first word in the header.
> 
> Below is an extract of relevant SIP ABNF syntax.
> 
> Call-ID  =  ( "Call-ID" / "i" ) HCOLON callid
> callid   =  word [ "@" word ]
> 
> HCOLON  =  *( SP / HTAB ) ":" SWS
> SWS     =  [LWS] ; sep whitespace
> LWS     =  [*WSP CRLF] 1*WSP ; linear whitespace
> WSP     =  SP / HTAB
> word    =  1*(alphanum / "-" / "." / "!" / "%" / "*" /
>            "_" / "+" / "`" / "'" / "~" /
>            "(" / ")" / "<" / ">" /
>            ":" / "\" / DQUOTE /
>            "/" / "[" / "]" / "?" /
>            "{" / "}" )
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> ---
>  net/netfilter/nf_conntrack_sip.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
> index 8971109..c23249e 100644
> --- a/net/netfilter/nf_conntrack_sip.c
> +++ b/net/netfilter/nf_conntrack_sip.c
> @@ -335,8 +335,7 @@ static const char *sip_skip_whitespace(const char *dptr, const char *limit)
>  		if (*dptr != '\r' && *dptr != '\n')
>  			break;
>  		dptr = sip_follow_continuation(dptr, limit);
> -		if (dptr == NULL)
> -			return NULL;
> +		return dptr;

I'd suggest you use the break statement here instead, ie.

-		if (dptr == NULL)
-			return NULL;
+		break;

>  	}
>  	return dptr;
>  }
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
