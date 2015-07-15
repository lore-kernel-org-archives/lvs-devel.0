From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] net-ipvs: Delete an unnecessary check before the
 function call "module_put"
Date: Wed, 15 Jul 2015 19:00:00 +0200
Message-ID: <20150715170000.GA4304@salvia>
References: <1436510569-10752-1-git-send-email-horms@verge.net.au>
 <1436510569-10752-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436510569-10752-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Markus Elfring <elfring@users.sourceforge.net>

On Fri, Jul 10, 2015 at 03:42:49PM +0900, Simon Horman wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> 
> The module_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks Simon.
