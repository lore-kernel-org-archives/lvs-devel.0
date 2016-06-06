From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL] IPVS Fixes for v4.7
Date: Mon, 6 Jun 2016 13:20:20 +0200
Message-ID: <20160606112020.GA3555@salvia>
References: <1465205077-15139-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465205077-15139-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>

On Mon, Jun 06, 2016 at 06:24:36PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider this IPVS fix for v4.7.
> 
> The fix from Marco corrects the handling of outgoing connections
> which use the SIP-pe such that the binding of a real-server
> is updated when needed. This was an omission from changes
> introduced by Marco in v4.7 to allow handling of outgoing connections
> by the SIP-pe.
> 
> The following changes since commit 7b7eba0f3515fca3296b8881d583f7c1042f5226:
> 
>   netfilter: x_tables: don't reject valid target size on some architectures (2016-06-02 14:09:33 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.7

Pulled, thanks Simon.
