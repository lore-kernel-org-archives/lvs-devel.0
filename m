From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL net] IPVS
Date: Mon, 30 Apr 2012 11:27:22 +0200
Message-ID: <20120430092722.GA6866@1984>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Apr 27, 2012 at 09:53:54AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider the following 5 changes for 3.4, they are all bug fixes.
> I would also like these changes considered for stable.

Please, ping me again once these have hit Linus tree to ask for
-stable submission.

> The following changes since commit 8f9b9a2fad47af27e14b037395e03cd8278d96d7:
> 
>   ipvs: fix crash in ip_vs_control_net_cleanup on unload (2012-04-25 11:16:30 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master
> 
> for you to fetch changes up to 1c3dc0f92d127d3fdefa84c7ef629b070bf8d32c:
> 
>   ipvs: kernel oops - do_ip_vs_get_ctl (2012-04-26 18:04:31 +0900)

Pulled and pushed out, thanks Simon et al!
