From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [PATCH] ipvs: A couple of fixes and cleanups
Date: Mon, 11 Aug 2008 14:19:47 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808111416350.12259@titan.stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, 10 Aug 2008, Sven Wegener wrote:

> On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:
> 
> > Hi guys,
> > 
> > here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
> > possible deadlock fixes. One introduced by my last sync daemon work, which
> > hasn't hit any stable kernel yet. The other one is in the estimator code and
> > goes back to at leat since we started working with git for the kernel. The
> > latter I think qualifies for -stable.
> > 
> > I've pushed the changes (8123b42..2e45552) based on davem's net tree here
> > 
> > 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem
> 
> I've included the register_ip_vs_protocol() annotation. Changes are now 
> 8123b42..7ead17b. Diffstat has changed slightly, but is probably not worth 
> posting again.

OK, this should be final now. I've pushed the changes 8123b42..e93615d to

	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem

Simon, as you see I've included your patch and added your acked-by onto 
the other patches.

Simon Horman (1):
      ipvs: Explictly clear ip_vs_stats members

Sven Wegener (9):
      ipvs: Fix possible deadlock in sync code
      ipvs: Fix possible deadlock in estimator code
      ipvs: Use ARRAY_SIZE()
      ipvs: Use list_empty() instead of open-coding the same functionality
      ipvs: Initialize schedulers' struct list_head at compile time
      ipvs: Annotate init functions with __init
      ipvs: Mark net_vs_ctl_path const
      ipvs: Embed estimator object into stats object
      ipvs: No need to zero out ip_vs_stats during initialization

 include/net/ip_vs.h         |   32 ++++++++++--
 net/ipv4/ipvs/ip_vs_app.c   |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |   27 +++++++---
 net/ipv4/ipvs/ip_vs_dh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_est.c   |  116 ++++++++++++++----------------------------
 net/ipv4/ipvs/ip_vs_lblc.c  |    2 +-
 net/ipv4/ipvs/ip_vs_lblcr.c |    2 +-
 net/ipv4/ipvs/ip_vs_lc.c    |    2 +-
 net/ipv4/ipvs/ip_vs_nq.c    |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c |    4 +-
 net/ipv4/ipvs/ip_vs_rr.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sched.c |    4 +-
 net/ipv4/ipvs/ip_vs_sed.c   |    2 +-
 net/ipv4/ipvs/ip_vs_sh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sync.c  |    4 +-
 net/ipv4/ipvs/ip_vs_wlc.c   |    2 +-
 net/ipv4/ipvs/ip_vs_wrr.c   |    2 +-
 18 files changed, 105 insertions(+), 106 deletions(-)
