From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next 0/3] IPVS Updates for v4.6
Date: Mon, 25 Apr 2016 14:57:57 +0200
Message-ID: <20160425125757.GA4050@salvia>
References: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Apr 20, 2016 at 12:46:31PM +1000, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS. They allow SIP connections
> originating from real-servers to be load balanced by the SIP psersitence
> engine as is already implemented in the other direction. And for better one
> packet scheduling (OPS) performance.
> 
> The following changes since commit 4a96300cec88729415683db8a2b909563b09fbaa:
> 
>   netfilter: ctnetlink: restore inlining for netlink message size calculation (2016-04-18 22:14:40 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.7

Pulled, thanks Simon.
