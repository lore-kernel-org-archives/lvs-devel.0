From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS fix for v3.10
Date: Thu, 20 Jun 2013 11:47:36 +0200
Message-ID: <20130620094736.GA18950@localhost>
References: <1371606963-30548-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371606963-30548-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Jun 19, 2013 at 10:56:01AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> I realise this is rather late in the cycle, so please feel free
> to push back on this. We can add it to v3.11 and then -stable.
> 
> This fix appears to resolve a long-standing problem that has
> existed since SCTP support was added to IPVS in v2.6.32.
> I believe it is relevant to -stable all the way back until then.
> 
> The following changes since commit b396966c4688522863572927cb30aa874b3ec504:
> 
>   netfilter: xt_TCPMSS: Fix missing fragmentation handling (2013-06-12 11:06:19 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.10
> 
> for you to fetch changes up to 06f3d7f973ec04290d86b7dd91b48d38d90433dc:
> 
>   ipvs: SCTP ports should be writable in ICMP packets (2013-06-19 09:53:52 +0900)

Pulled, thanks Simon.
