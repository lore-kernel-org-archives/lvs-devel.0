From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 10/13] [RFC 10/13] IPVS: management of persistence engine
 modules
Date: Fri, 6 Aug 2010 10:48:44 +0900
Message-ID: <20100806014843.GE12311@verge.net.au>
References: <20100805114755.118303531@vergenet.net>
 <20100805115241.482096330@vergenet.net>
 <20100805092920.7573c96b@nehalam>
Mime-Version: 1.0
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100805092920.7573c96b@nehalam>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thu, Aug 05, 2010 at 09:29:20AM -0700, Stephen Hemminger wrote:
> On Thu, 05 Aug 2010 20:48:05 +0900
> Simon Horman <horms@verge.net.au> wrote:
> 
> > +/* lock for service table */
> > +static DEFINE_RWLOCK(__ip_vs_pe_lock);
> 
> It is already static so why the __?
> Reader/writer locks are slower than spinlocks.  Either use
> a spinlock, or RCU (if possible)

No good reason, other than I copied the code from elsewhere.
I'll fix both this and the code that I copied.

> > +/* Bind a service with a pe */
> > +void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
> > +{
> > +	svc->pe = pe;
> > +}
> > +
> > +/* Unbind a service from its pe */
> > +void ip_vs_unbind_pe(struct ip_vs_service *svc)
> > +{
> > +	svc->pe = NULL;
> > +}
> 
> What does having these wrappers buy?

Again, I copied the code from elsewhere, where the wrappers did more.  As
it happens, I think that these do make some sense as they are called along
side other bind and unbind calls. But if you have a strong aversion to them
then I am happy to remove these wrappers.
