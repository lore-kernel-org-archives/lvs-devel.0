From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-2.6] IPVS (Take II)
Date: Wed, 4 May 2011 07:12:15 +0900
Message-ID: <20110503221213.GA28540@verge.net.au>
References: <1304406316-15636-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304406316-15636-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, May 03, 2011 at 04:05:14PM +0900, Simon Horman wrote:
> Hi Patrick,
> 
> please consider pulling
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git for-patrick
> to get the following fix from Hans. They resolve some problems related
> to his netns for IPVS work which was incorporated into 2.6.39-rc1.

Sorry for all the messing about.
A fresh version of these patches has been provided by Hans,
and I'm looking into weather they should replace this pull request.

So please ignore this for now (again!).

> 
> The pull request is based on nf-2.6/master.
> 
> There are other less-pressing changes from Hans which
> I plan to get you to pull into nf-next-2.6 once these
> changes make it there (presumably via net-2.6 and then net-next-2.6).
> 
> Hans Schillstrom (2):
>       IPVS: Change of socket usage to enable name space exit.
>       IPVS: init and cleanup restructuring.
> 
>  include/net/ip_vs.h              |   17 +++++
>  net/netfilter/ipvs/ip_vs_app.c   |   15 +----
>  net/netfilter/ipvs/ip_vs_conn.c  |   12 +---
>  net/netfilter/ipvs/ip_vs_core.c  |  102 ++++++++++++++++++++++++++++---
>  net/netfilter/ipvs/ip_vs_ctl.c   |  123 ++++++++++++++++++++++++++++++++------
>  net/netfilter/ipvs/ip_vs_est.c   |   14 +----
>  net/netfilter/ipvs/ip_vs_proto.c |   11 +---
>  net/netfilter/ipvs/ip_vs_sync.c  |   65 +++++++++++---------
>  8 files changed, 260 insertions(+), 99 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
