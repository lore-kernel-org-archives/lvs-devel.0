From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v4 10/12] IPVS: Allow configuration of persistence
 engines
Date: Mon, 4 Oct 2010 22:41:54 +0900
Message-ID: <20101004134154.GA5469@verge.net.au>
References: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
 <20101004090818.882956490@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101004090818.882956490@akiko.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Mon, Oct 04, 2010 at 06:04:02PM +0900, Simon Horman wrote:
> Allow the persistence engine of a virtual service to be set, edited
> and unset.
> 
> This feature only works with the netlink user-space interface.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> ---
> 
> v2
> * Dereference persistence engine when a service is deleted.
>   This allows persistence modules to be removed from the kernel
>   once they are no longer used.
> * Update for the recent "ipvs: changes related to service usecnt" change
> * Trivial rediff
> 
> v4
> * As suggested by  Julian Anastasov <ja@ssi.bg>
>   - Initialise ip_vs_service_user_kern to zero in ip_vs_copy_usvc_compat()
>     to avoid a crash caused by the pe_name element being uninitialised.

*Red Face*

I forgot to test this change and I had made a typo.
I will repost.

