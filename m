From: Simon Horman <horms@verge.net.au>
Subject: [GIT] Please pull updates for IPVS
Date: Wed, 17 Sep 2008 10:21:48 +1000
Message-ID: <20080917002146.GC15750@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Brian Haley <brian.haley@hp.com>, Sven Wegener <sven.wegener@stealer.net>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Dave,

the following are several cleanup patches, mainly resulting from
the IPv6 merge. The "ipvs: supply a valid 0 address to ip_vs_conn_new()"
change appears to be a fix for a regression caused by that merge,
though I don't believe that anyone has observed it causing a problem.


The following changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git lvs-next-2.6

They should apply cleanly to net-next-2.6, which I pulled and merged this
morning.

Brian Haley (1):
      ipvs: change some __constant_htons() to htons()

Simon Horman (4):
      Merge git://git.kernel.org/.../horms/lvs-2.6 into lvs-next-2.6
      ipvs: only unlock in ip_vs_edit_service() if already locked
      ipvs: supply a valid 0 address to ip_vs_conn_new()
      ipvs: add __aquire/__release annotations to ip_vs_info_seq_start/ip_vs_info_seq_stop

 net/ipv4/ipvs/ip_vs_core.c         |    3 ++-
 net/ipv4/ipvs/ip_vs_ctl.c          |    9 ++++++---
 net/ipv4/ipvs/ip_vs_proto.c        |    2 +-
 net/ipv4/ipvs/ip_vs_proto_ah_esp.c |    2 +-
 4 files changed, 10 insertions(+), 6 deletions(-)



-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

