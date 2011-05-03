From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [GIT PULL nf-2.6] IPVS (Take II)
Date: Tue, 3 May 2011 15:33:44 +0200 (CEST)
Message-ID: <t9h34u8.2f81b788a5829200fb85fb52402dbb66@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Hi Patrick & Simon
Please drop this patch / pull request.
I need to take a way 2 rows, 
I.e. the new feature that disables ipvs when last service is removed,
it doesn't work since it's not the last service.

>Sent: Tue, May 3, 2011, 9:06 AM
>Subject: [GIT PULL nf-2.6] IPVS (Take II)
>
>Hi Patrick,
>
>please consider pulling
>git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git for-patrick
>to get the following fix from Hans. They resolve some problems related
>to his netns for IPVS work which was incorporated into 2.6.39-rc1.
>
>The pull request is based on nf-2.6/master.
>
>There are other less-pressing changes from Hans which
>I plan to get you to pull into nf-next-2.6 once these
>changes make it there (presumably via net-2.6 and then net-next-2.6).
>
>Hans Schillstrom (2):
>      IPVS: Change of socket usage to enable name space exit.
>      IPVS: init and cleanup restructuring.
>
> include/net/ip_vs.h              |   17 +++++
> net/netfilter/ipvs/ip_vs_app.c   |   15 +----
> net/netfilter/ipvs/ip_vs_conn.c  |   12 +---
> net/netfilter/ipvs/ip_vs_core.c  |  102 ++++++++++++++++++++++++++++---
> net/netfilter/ipvs/ip_vs_ctl.c   |  123 ++++++++++++++++++++++++++++++++------
> net/netfilter/ipvs/ip_vs_est.c   |   14 +----
> net/netfilter/ipvs/ip_vs_proto.c |   11 +---
> net/netfilter/ipvs/ip_vs_sync.c  |   65 +++++++++++---------
> 8 files changed, 260 insertions(+), 99 deletions(-)
>--

Regards
Hans Schillstrom 


