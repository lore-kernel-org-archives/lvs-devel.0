From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] netfilter: correct allowed characters in Call-ID SIP
 header
Date: Wed, 7 Sep 2016 10:31:34 +0200
Message-ID: <20160907083134.GB2276@salvia>
References: <20160830164824._3CVoDOGb%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160830164824._3CVoDOGb%marcoangaroni@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Aug 30, 2016 at 06:48:24PM +0200, Marco Angaroni wrote:
> Current parsing methods for SIP header Call-ID do not check correctly all
> characters allowed by RFC 3261. In particular "," character is allowed 
> instead of "'" character. As a result Call-ID headers like the following
> are discarded by IPVS SIP persistence engine.
> 
> Call-ID: -.!%*_+`'~()<>:\"/[]?{}
> 
> Above example is composed using all non-alphanumeric characters listed
> in RFC 3261 for Call-ID header syntax.
> 
> Proposed fix is in nf_conntrack_sip module; function iswordc() checks this
> range: (c >= '(' && c <= '/') which includes these characters: ()*+,-./
> They are all allowed except ",". Instead "'" is not included in the list.
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

Also applied, thanks.
