From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-2.6] IPVS
Date: Mon, 2 May 2011 22:03:14 +0900
Message-ID: <20110502130310.GA23752@verge.net.au>
References: <1304340447-21857-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304340447-21857-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, May 02, 2011 at 09:47:25PM +0900, Simon Horman wrote:
> 
> Hi Patrick,
> 
> please consider pulling
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git master
> to get the following fix from Hans. They resolve some problems related
> to his netns for IPVS work which was incorporated into 2.6.39-rc1.

Sorry, please ignore this.
The second patch is one of the non-pressing ones.
I'll fix things up and repost.

> The pull request is based on nf-2.6/master.
> 
> There are other less-pressing changes from Hans which
> I plan to get you to pull into nf-next-2.6 once these
> changes make it there (presumably via net-2.6 and then net-next-2.6).
> 
> Hans Schillstrom (2):
>       IPVS: Change of socket usage to enable name space exit.
>       IPVS: labels at pos 0
> 
>  net/netfilter/ipvs/ip_vs_core.c |   12 ++++----
>  net/netfilter/ipvs/ip_vs_ctl.c  |    8 +++---
>  net/netfilter/ipvs/ip_vs_sync.c |   58 +++++++++++++++++++++++++--------------
>  3 files changed, 47 insertions(+), 31 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
