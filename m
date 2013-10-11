From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net-next] ipvs: avoid rcu_barrier during netns cleanup
Date: Fri, 11 Oct 2013 10:57:13 +0200
Message-ID: <20131011085713.GA4166@localhost>
References: <1381299867-4929-1-git-send-email-ja@ssi.bg>
 <20131011050558.GC4624@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131011050558.GC4624@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Oct 11, 2013 at 02:05:58PM +0900, Simon Horman wrote:
> Thanks Julian.
> 
> Pablo, could you merge net-next into nf-next so that
> I can apply this patch on top of the later?
> 
> In particular I believe I need the following commit
> to allow Julian's patch to apply cleanly (at all).
> 
> bcbde4c ("ipvs: make the service replacement more robust")

Just refreshed my nf-next tree.

Please, let me know if you still need any further action from my side,
it may require pinging David to merge net into net-next.
