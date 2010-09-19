From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 13/13] [RFC 13/13] IPVS: sip persistence engine
Date: Sun, 19 Sep 2010 10:03:49 +0900
Message-ID: <20100919010349.GB794@verge.net.au>
References: <20100805114755.118303531@vergenet.net>
 <20100805115242.056724322@vergenet.net>
 <Pine.LNX.4.58.1009181731240.8887@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009181731240.8887@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>

On Sat, Sep 18, 2010 at 06:09:28PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 5 Aug 2010, Simon Horman wrote:
> 
> > Add the SIP callid as a key for persistence.
> 
> ...
> 
> > +static bool ip_vs_sip_ct_match(const struct ip_vs_conn_param *p,
> > +				  struct ip_vs_conn *ct)
> > +
> > +{
> > +	bool ret = 0;
> > +
> > +	if (ct->af == p->af &&
> > +	    ip_vs_addr_equal(p->af, p->caddr, &ct->caddr) &&
> > +	    /* protocol should only be IPPROTO_IP if
> > +	     * d_addr is a fwmark */
> > +	    ip_vs_addr_equal(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
> > +			     p->vaddr, &ct->vaddr) &&
> > +	    ct->vport == p->vport &&
> > +	    ct->flags & IP_VS_CONN_F_TEMPLATE &&
> > +	    ct->protocol == p->protocol &&
> > +	    ct->pe_data && ct->pe_data_len == p->pe_data_len &&
> > +	    !strnicmp(ct->pe_data, p->pe_data, p->pe_data_len))
> 
> 	According to RFC 3261 8.1.1.4 Call-ID,
> "Call-IDs are case-sensitive and are simply compared byte-by-byte",
> so may be memcmp should be used.
> 
> 	Also, may be ip_vs_sip_fill_param uses GFP_KERNEL in wrong 
> context.

Thanks, I'll fix up both of those problems.

