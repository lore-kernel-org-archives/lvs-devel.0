From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next] IPVS
Date: Mon, 7 Nov 2011 12:07:01 +0900
Message-ID: <20111107030659.GA24405@verge.net.au>
References: <1319160783-28422-1-git-send-email-horms@verge.net.au>
 <20111021072715.GA842@1984>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111021072715.GA842@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

On Fri, Oct 21, 2011 at 09:27:15AM +0200, Pablo Neira Ayuso wrote:
> On Fri, Oct 21, 2011 at 10:33:01AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider pulling the following to get compile fix
> > and cleanup patches from Krzysztof Wilczynski.
> > 
> > The following changes since commit 2ca5b853f1dd81c605ddc8a55e06bdad85636597:
> > 
> >   netfilter: export NAT definitions through linux/netfilter_ipv4/nf_nat.h (2011-10-11 03:32:34 +0200)
> > 
> > are available in the git repository at:
> >   git://github.com/horms/ipvs-next.git master
> 
> Pulled, thanks.
> 
> http://1984.lsi.us.es/git/?p=net-next/.git;a=shortlog;h=refs/heads/nf-next
> 
> > Krzysztof Wilczynski (2):
> >       ipvs: Remove unused variable "cs" from ip_vs_leave function.
> >       ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.
> 
> Strange, I have all IPVS configs enabled here and I didn't hit this error.

Hi Pablo,

I am a little confused. The nf-next branch seems to have disappeared.

Could you consider pulling git://github.com/horms/ipvs-next.git master
to get the following changes that were in your nf-next branch. Or would
you like me to rebase the ipvs patches (9 or the 11 changes below) on
top of git://1984.lsi.us.es/net-next/.git master ?

------

The following changes since commit a9e9fd7182332d0cf5f3e601df3e71dd431b70d7:

  skge: handle irq better on single port card (2011-09-27 13:41:37 -0400)

are available in the git repository at:
  git://github.com/horms/ipvs-next.git master

Joe Perches (1):
      netfilter: Remove unnecessary OOM logging messages

Krzysztof Wilczynski (3):
      ipvs: Expose ip_vs_ftp module parameters via sysfs.
      ipvs: Remove unused variable "cs" from ip_vs_leave function.
      ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.

Pablo Neira Ayuso (1):
      netfilter: export NAT definitions through linux/netfilter_ipv4/nf_nat.h

Simon Horman (6):
      ipvs: Add documentation for new sysctl entries
      ipvs: Remove unused parameter from ip_vs_confirm_conntrack()
      ipvs: Remove unused return value of protocol state transitions
      ipvs: Removed unused variables
      ipvs: secure_tcp does provide alternate state timeouts
      ipvs: Enhance grammar used to refer to Kconfig options

 Documentation/networking/ipvs-sysctl.txt   |   62 ++++++++++++++++++++++++---
 include/linux/netfilter_ipv4/Kbuild        |    1 +
 include/linux/netfilter_ipv4/nf_nat.h      |   58 ++++++++++++++++++++++++++
 include/net/ip_vs.h                        |   11 ++---
 include/net/netfilter/nf_conntrack_tuple.h |   27 +------------
 include/net/netfilter/nf_nat.h             |   26 +-----------
 net/bridge/netfilter/ebt_ulog.c            |    7 +--
 net/ipv4/netfilter/ipt_CLUSTERIP.c         |    1 -
 net/ipv4/netfilter/ipt_ULOG.c              |    4 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c     |   22 +---------
 net/ipv6/netfilter/nf_conntrack_reasm.c    |    7 +--
 net/netfilter/ipset/ip_set_core.c          |    4 +-
 net/netfilter/ipvs/ip_vs_core.c            |   20 ++++-----
 net/netfilter/ipvs/ip_vs_ctl.c             |   22 +++-------
 net/netfilter/ipvs/ip_vs_dh.c              |    5 +-
 net/netfilter/ipvs/ip_vs_ftp.c             |    5 +-
 net/netfilter/ipvs/ip_vs_lblc.c            |    9 +---
 net/netfilter/ipvs/ip_vs_lblcr.c           |   13 ++----
 net/netfilter/ipvs/ip_vs_nfct.c            |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c           |    5 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c      |   14 ++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c       |    6 +--
 net/netfilter/ipvs/ip_vs_proto_udp.c       |    5 +-
 net/netfilter/ipvs/ip_vs_sh.c              |    5 +-
 net/netfilter/ipvs/ip_vs_wrr.c             |    5 +-
 net/netfilter/ipvs/ip_vs_xmit.c            |    2 +-
 net/netfilter/nf_conntrack_core.c          |    5 +--
 net/netfilter/nfnetlink_log.c              |    7 +--
 net/netfilter/xt_IDLETIMER.c               |    2 -
 net/netfilter/xt_hashlimit.c               |    5 +--
 30 files changed, 178 insertions(+), 189 deletions(-)
 create mode 100644 include/linux/netfilter_ipv4/nf_nat.h
