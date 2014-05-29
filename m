From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] Fixes for v3.15
Date: Thu, 29 May 2014 23:00:43 +0200
Message-ID: <20140529210043.GA5730@localhost>
References: <1401068235-6730-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401068235-6730-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Mon, May 26, 2014 at 10:37:14AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> I realise this is extremely late in the v3.15 cycle so please don't hesitate
> to push it back to v3.16. I am more than happy to rebase/resubmit if that
> is what you decided on.
> 
> This fix resolves a panic due to non-linear skb.
> 
> It has been present since v3.6-rc1.
> 
> I would like this fix considered for -stable and I have checked that it
> applies cleanly on top of v3.10.40, v3.12.20 and v3.14.4.
> 
> 
> The following changes since commit 3b084e99a3fabaeb0f9c65a0806cde30f0b2835e:
> 
>   netfilter: nf_tables: fix trace of matching non-terminal rule (2014-05-15 19:44:20 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.15

Pulled, thanks Simon.
