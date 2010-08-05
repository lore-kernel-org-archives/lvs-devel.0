From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [rfc 10/13] [RFC 10/13] IPVS: management of persistence engine
 modules
Date: Thu, 5 Aug 2010 09:29:20 -0700
Message-ID: <20100805092920.7573c96b@nehalam>
References: <20100805114755.118303531@vergenet.net>
	<20100805115241.482096330@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100805115241.482096330@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thu, 05 Aug 2010 20:48:05 +0900
Simon Horman <horms@verge.net.au> wrote:

> +/* lock for service table */
> +static DEFINE_RWLOCK(__ip_vs_pe_lock);

It is already static so why the __?
Reader/writer locks are slower than spinlocks.  Either use
a spinlock, or RCU (if possible)

> +/* Bind a service with a pe */
> +void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
> +{
> +	svc->pe = pe;
> +}
> +
> +/* Unbind a service from its pe */
> +void ip_vs_unbind_pe(struct ip_vs_service *svc)
> +{
> +	svc->pe = NULL;
> +}

What does having these wrappers buy?
