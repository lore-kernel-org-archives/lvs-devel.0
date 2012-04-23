From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] netfilter: ipvs: use GFP_KERNEL allocation where
 possible
Date: Mon, 23 Apr 2012 07:23:27 -0700
Message-ID: <20120423142327.GB32269@kroah.com>
References: <1335183428-2585-1-git-send-email-horms@verge.net.au>
 <1335183428-2585-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335183428-2585-3-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sasha Levin <levinsasha928@gmail.com>, stable@vger.kernel.org

On Mon, Apr 23, 2012 at 09:17:08PM +0900, Simon Horman wrote:
> From: Sasha Levin <levinsasha928@gmail.com>
> 
> Use GFP_KERNEL instead of GFP_ATOMIC when registering an ipvs protocol.
> 
> This is safe since it will always run from a process context.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_proto.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

How does this patch meet the Documentation/stable_kernel_rules.txt
requirements?

