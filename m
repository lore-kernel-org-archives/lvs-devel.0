From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 02/13] [RFC 02/13] netfilter: nf_conntrack_sip: Add
 callid parser
Date: Fri, 6 Aug 2010 23:31:13 +0900
Message-ID: <20100806143113.GB13997@verge.net.au>
References: <20100805114755.118303531@vergenet.net>
 <20100805115239.880722744@vergenet.net>
 <4C5C1591.90108@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C5C1591.90108@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Aug 06, 2010 at 04:00:49PM +0200, Patrick McHardy wrote:
> Am 05.08.2010 13:47, schrieb Simon Horman:
> > diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
> > index 2fd1ea2..715ce54 100644
> > --- a/net/netfilter/nf_conntrack_sip.c
> > +++ b/net/netfilter/nf_conntrack_sip.c
> > @@ -130,6 +130,44 @@ static int digits_len(const struct nf_conn *ct, const char *dptr,
> >  	return len;
> >  }
> >  
> > +static int iswordc(const char c)
> > +{
> > +	if (isalnum(c) || c == '!' || c == '"' || c == '%' ||
> > +	    (c >= '(' && c <= '/') || c == ':' || c == '<' || c == '>' ||
> > +	    c == '?' || (c >= '[' && c <= ']') || c == '_' || c == '`' ||
> > +	    c == '{' || c == '}' || c == '~')
> > +		return 1;
> > +	return 0;
> > +}
> > +
> > +static int word_len(const char *dptr, const char *limit)
> > +{
> > +	int len = 0;
> > +	while (dptr < limit && iswordc(*dptr)) {
> > +		dptr++;
> > +		len++;
> > +	}
> > +	return len;
> > +}
> 
> Since the Call-ID can't contain whitespace, couldn't we simply
> determine the length by looking for the next newline or whitespace
> character?

Well, there are other characters (e.g. '#') it can't contain - unless I
read the RFC incorrectly.  Are you concerned about speed, code complexity,
or something else?

