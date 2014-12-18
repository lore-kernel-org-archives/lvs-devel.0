From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] Second round of IPVS Updates for v3.19
Date: Thu, 18 Dec 2014 21:11:29 +0100
Message-ID: <20141218201129.GA5429@salvia>
References: <1418201201-19257-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418201201-19257-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Dec 10, 2014 at 05:46:40PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS updates for v3.19 or alternatively v3.20.
> 
> The single patch in this series fixes a long standing bug that
> has not caused any trouble and thus is not being prioritised as a fix.
> 
> 
> The following changes since commit d6b00fec5dbbe976904b4d77e7d4f9493df5c2ec:
> 
>   macvlan: play well with ipvlan device (2014-12-09 16:10:06 -0500)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.19

Pulled, thanks Simon.

This applies cleanly to:

3.2.x
3.4.x
3.10.x
3.14.x
3.17.x
3.18.x

Please, let me know if this patch has some non obvious dependencies
that needs to be fulfilled before passing it to -stable or it's plain
fine to pass it on.
