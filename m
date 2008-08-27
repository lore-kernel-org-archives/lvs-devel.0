From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Wed, 27 Aug 2008 15:33:06 +1000
Message-ID: <20080827053304.GN19066@verge.net.au>
References: <20080815001250.GC15825@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080815001250.GC15825@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Sven Wegener <sven.wegener@stealer.net>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Dave,

Please let me know if this is inappropriate or I am doing things wrong.
This should pull straight into net-next.2.6. The master branch is still
based on net-2.6 and also contains all of these changesets (less the la=
st
trivial merge).



The following changes since commit a4356b2920fd4861dd6c75f558749fa5c38a=
00e8:
  lpo J=E4rvinen (1):
      tcp: Add tcp_parse_aligned_timestamp

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git lvs-n=
ext-2.6

Julius Volz (4):
      IPVS: Add genetlink interface definitions to ip_vs.h
      IPVS: Add genetlink interface implementation
      IPVS: Integrate ESP protocol into ip_vs_proto_ah.c
      IPVS: Rename ip_vs_proto_ah.c to ip_vs_proto_ah_esp.c

Simon Horman (4):
      ipvs: rename __ip_vs_wlc_schedule in lblc and lblcr schedulers
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../horms/lvs-2.6 i=
nto lvs-next-2.6

Sven Wegener (4):
      ipvs: Only call init_service, update_service and done_service for=
 schedulers if defined
      ipvs: Create init functions for estimator code
      ipvs: Fix race conditions in lblc scheduler
      ipvs: Fix race conditions in lblcr scheduler

 include/linux/ip_vs.h       |  160 +++++++
 include/net/ip_vs.h         |    2=20
 net/ipv4/ipvs/ip_vs_core.c  |    8=20
 net/ipv4/ipvs/ip_vs_ctl.c   |  896 +++++++++++++++++++++++++++++++++++=
+++++++-
 net/ipv4/ipvs/ip_vs_est.c   |   18=20
 net/ipv4/ipvs/ip_vs_lblc.c  |  213 ++++------
 net/ipv4/ipvs/ip_vs_lblcr.c |  238 +++++------
 net/ipv4/ipvs/ip_vs_lc.c    |   21 -
 net/ipv4/ipvs/ip_vs_nq.c    |   24 -
 net/ipv4/ipvs/ip_vs_rr.c    |    7=20
 net/ipv4/ipvs/ip_vs_sed.c   |   24 -
 net/ipv4/ipvs/ip_vs_wlc.c   |   24 -
 12 files changed, 1278 insertions(+), 357 deletions(-)
