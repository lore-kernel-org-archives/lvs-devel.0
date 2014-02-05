From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf] IPVS Fixes for v3.14
Date: Wed, 5 Feb 2014 23:58:15 +0100
Message-ID: <20140205225815.GA3755@localhost>
References: <1391517261-27222-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391517261-27222-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Feb 04, 2014 at 09:34:20PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following fixes for IPVS for v3.14.
> 
> It consists of a fix for AF assingment by Michal Kubecek.
> 
> I believe this problem is present all the way back to v2.6.30, however, the
> change only applies as far back as v3.10.  Please let me know if you would
> like me to make some patches for older -stable versions.
> 
> 
> The following changes since commit d922e1cb1ea17ac7f0a5c3c2be98d4bd80d055b8:
> 
>   net: Document promote_secondaries (2014-01-27 20:39:21 -0800)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.14

Pulled, thanks Simon.
