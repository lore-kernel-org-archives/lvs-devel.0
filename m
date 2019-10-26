From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL] IPVS fixes for v5.4
Date: Sat, 26 Oct 2019 12:48:24 +0200
Message-ID: <20191026104824.kareh25qmgfp4tuk@salvia>
References: <20191025111205.30555-1-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20191025111205.30555-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Oct 25, 2019 at 01:12:03PM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS fixes for v5.4.
> 
> * Eric Dumazet resolves a race condition in switching the defense level
> 
> * Davide Caratti resolves a race condition in module removal
> 
> This pull request is based on nf.
> 
> 
> The following changes since commit 085461c8976e6cb4d5b608a7b7062f394c51a253:
> 
>   netfilter: nf_tables_offload: restore basechain deletion (2019-10-23 13:14:50 +0200)
> 
> are available in the Git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v5.4

Pulled, thanks Simon.
