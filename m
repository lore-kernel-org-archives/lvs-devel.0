From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS fixes for v3.17
Date: Sat, 30 Aug 2014 13:07:59 +0200
Message-ID: <20140830110759.GA4601@salvia>
References: <1409120115-32053-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409120115-32053-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Aug 27, 2014 at 03:15:14PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this IPVS fix for v3.17.
> 
> It allows CHECKSUM_PARTIAL to work in conjunction with
> TCP/UDP csum offlad and the tunnel forwarding mechanism
> provided by IPVS.
> 
> I suspect that this problem has existed for as long
> has IPVS has been present in the kernel: some time before
> git epoch of the git history in Linus's tree.
>
> I would like this change considered for -stable.

The generic iptunnel infrastructure is quite recent. For example,
iptunnel_handle_offloads() is available since 3.13. You'll need to
prepare a backport of this for -stable kernels.

[...]
> The following changes since commit d1c85c2ebe7ffe1f1b27846bd1ba0944c513d822:
> 
>   netfilter: HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL (2014-08-25 10:45:28 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.17

Pulled, thanks.
