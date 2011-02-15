From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: remove extra lookups for ICMP packets
Date: Wed, 16 Feb 2011 07:32:57 +0900
Message-ID: <20110215223257.GP8703@verge.net.au>
References: <alpine.LFD.2.00.1102090222020.3494@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1102090222020.3494@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Feb 09, 2011 at 02:26:38AM +0200, Julian Anastasov wrote:
> 
> 	Remove code that should not be called anymore.
> Now when ip_vs_out handles replies for local clients at
> LOCAL_IN hook we do not need to call conn_out_get and
> handle_response_icmp from ip_vs_in_icmp* because such
> lookups were already performed for the ICMP packet and no
> connection was found.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Patch is against lvs-test-2.6 from 09-FEB-2011
> but should apply cleanly to net-next.

Thanks, I have pushed this change into the master branch of lvs-test-2.6.
I am waiting for one or two more patches to settle down before
sending my next pull request to Patrick.

