From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/4] IPVS: Add documentation for new sysctl entries
Date: Tue, 27 Sep 2011 07:07:48 +0900
Message-ID: <20110926220748.GB5314@verge.net.au>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
 <1317000233-11169-2-git-send-email-horms@verge.net.au>
 <4E80B379.2040701@xenotime.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E80B379.2040701@xenotime.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Mon, Sep 26, 2011 at 10:16:41AM -0700, Randy Dunlap wrote:
> On 09/25/2011 06:23 PM, Simon Horman wrote:
> > Add missing documentation for conntrack, snat_reroute and sync_version.
> > 
> > Also fix up a typo, IPVS_DEBUG should be IP_VS_DEBUG.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > conntrack
> > ---
> >  Documentation/networking/ipvs-sysctl.txt |   53 +++++++++++++++++++++++++++++-
> >  1 files changed, 52 insertions(+), 1 deletions(-)
> > 
> > diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
> > index 4ccdbca..5214339 100644
> > --- a/Documentation/networking/ipvs-sysctl.txt
> > +++ b/Documentation/networking/ipvs-sysctl.txt
> > @@ -15,6 +15,23 @@ amemthresh - INTEGER
> >          enabled and the variable is automatically set to 2, otherwise
> >          the strategy is disabled and the variable is  set  to 1.
> >  
> > +conntrack - BOOLEAN
> > +	0 - disabled (default)
> > +	not 0 - enabled
> > +
> > +	If set, maintain connection tracking entries for
> > +	connections handled by IPVS.
> > +
> > +	This should be enabled if connections handled by IPVS are to be
> > +	also handled by stateful firewall rules. That is, iptables rules
> > +	that make use of connection tracking.  It is a performance
> > +	optimisation to disable this setting otherwise.
> > +
> > +	Connections handled by the IPVS FTP application module
> > +	will have connection tracking entries regardless of this setting.
> > +
> > +	Only available when IPVS is compiled with the CONFIG_IP_VS_NFCT
> 
> seems to be missing something.  Maybe
> 
> 	Only available when IPVS is compiled with CONFIG_IP_VS_NFCT enabled.
> or
> 	Only available when IPVS is compiled with the CONFIG_IP_VS_NFCT
> 	symbol enabled.
> 
> > +
> >  cache_bypass - BOOLEAN
> >          0 - disabled (default)
> >          not 0 - enabled
> > @@ -39,7 +56,7 @@ debug_level - INTEGER
> >  	11         - IPVS packet handling (ip_vs_in/ip_vs_out)
> >  	12 or more - packet traversal
> >  
> > -	Only available when IPVS is compiled with the CONFIG_IPVS_DEBUG
> > +	Only available when IPVS is compiled with the CONFIG_IP_VS_DEBUG
> 
> 	                                     with CONFIG_IP_VS_DEBUG enabled.
> 
> >  
> >  	Higher debugging levels include the messages for lower debugging
> >  	levels, so setting debug level 2, includes level 0, 1 and 2

Thanks Randy,

I was just blindly copying the existing language.
I'll make a follow up patch which incorporates your suggestions.

