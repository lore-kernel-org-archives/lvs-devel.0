From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL] Third Round of IPVS Fixes for v3.16
Date: Fri, 25 Jul 2014 14:45:25 +0200
Message-ID: <20140725124525.GA6738@salvia>
References: <1406013952-18522-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406013952-18522-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Jul 22, 2014 at 04:25:51PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this third round of IPVS fixes for v3.16.
> 
> It includes one change from Alex Gartrell to:
> 
> * Maintain all DSCP and ECN bits for IPv6 tun forwarding
>   This resolves an inconsistency between IPv4 and IPv6 behaviour.
>   This behaviour was added when IPv6 support was added to IPVS
>   in v2.6.27.
> 
> This pull request is for an unsigned, unannotated tag.
> Please let me know if this doesn't work with your work flow.
> 
> The following changes since commit 2627b7e15c5064ddd5e578e4efd948d48d531a3f:
> 
>   ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack (2014-07-16 09:39:28 +0900)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes3-for-v3.16

Pulled, thanks Simon.
