From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/2] netfilter: allow tab character in SIP headers
Date: Wed, 7 Sep 2016 13:56:54 +0200
Message-ID: <20160907115654.GA4460@salvia>
References: <20160830165222.pAgDVdNXQ%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160830165222.pAgDVdNXQ%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Aug 30, 2016 at 06:52:22PM +0200, Marco Angaroni wrote:
> Current parsing methods for SIP headers do not allow the presence of
> tab characters between header name and header value. As a result Call-ID
> SIP headers like the following are discarded by IPVS SIP persistence
> engine:
> 
> "Call-ID\t: mycallid@abcde"
> "Call-ID:\tmycallid@abcde"
> 
> In above examples Call-IDs are represented as strings in C language.
> Obviously in real message we have byte "09" before/after colon (":").
> 
> Proposed fix is in nf_conntrack_sip module.
> Function sip_skip_whitespace() should skip tabs in addition to spaces,
> since in SIP grammar whitespace (WSP) corresponds to space or tab.
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

Applied this one too. I got confused because patch 0/x is usually the
cover letter, I suggest you don't use 0/x for patch series in the future.

Thanks!
