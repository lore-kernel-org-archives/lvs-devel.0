From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] ipvs: fix oops on NAT reply in br_nf context
Date: Tue, 17 Jul 2012 12:08:33 +0200
Message-ID: <20120717100833.GA3812@1984>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
 <1341965963-7275-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341965963-7275-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Lin Ming <mlin@ss.pku.edu.cn>

On Wed, Jul 11, 2012 at 09:19:21AM +0900, Simon Horman wrote:
> From: Lin Ming <mlin@ss.pku.edu.cn>
> 
> IPVS should not reset skb->nf_bridge in FORWARD hook
> by calling nf_reset for NAT replies. It triggers oops in
> br_nf_forward_finish.

Applied, thanks.
