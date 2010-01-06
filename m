From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/8] Remove most uses of NIPQUAD and NIPQUAD_FMT
Date: Tue,  5 Jan 2010 17:20:12 -0800
Message-ID: <cover.1262726222.git.joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: "James E.J. Bottomley" <James.Bottomley@suse.de>, Greg Kroah-Hartman <gregkh@suse.de>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <joel.becker@oracle.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, "Pekka Savola (ipv6)" <pekkas@netcore.fi>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Andy Grover <andy.grover@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, ocfs2-devel@oss.oracle.com, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, rds

Convert them to the %pI4 format extension where possible
Only a couple uses are left in netfilter.

Joe Perches (8):
  drivers/scsi: Remove uses of NIPQUAD, use %pI4
  drivers/staging/pohmelfs/inode.c: Remove uses of NIPQUAD, use %pI4
  net/rds: Remove uses of NIPQUAD, use %pI4
  net/sunrpc: Remove uses of NIPQUAD, use %pI4
  net/ipv4/netfilter/nf_nat_ftp.c: Convert NIPQUAD to %pI4
  net/netfilter/ipvs/ip_vs_ftp.c: Use standardized format in sprintf
  fs/ocfs2/cluster/tcp.c: Remove use of NIPQUAD, use %pI4
  drivers/firmware/iscsi_ibft.c: Remove NIPQUAD_FMT, use %pI4

 drivers/firmware/iscsi_ibft.c        |    8 +++-----
 drivers/scsi/bnx2i/bnx2i_iscsi.c     |    4 ++--
 drivers/scsi/cxgb3i/cxgb3i_iscsi.c   |    5 ++---
 drivers/scsi/cxgb3i/cxgb3i_offload.c |    7 ++++---
 drivers/staging/pohmelfs/inode.c     |    3 +--
 fs/ocfs2/cluster/tcp.c               |    4 ++--
 net/ipv4/netfilter/nf_nat_ftp.c      |    2 +-
 net/netfilter/ipvs/ip_vs_ftp.c       |    2 +-
 net/rds/tcp_connect.c                |    7 +++----
 net/rds/tcp_listen.c                 |    6 +++---
 net/rds/tcp_send.c                   |    4 ++--
 net/sunrpc/xprtrdma/transport.c      |    3 +--
 net/sunrpc/xprtsock.c                |    5 ++---
 13 files changed, 27 insertions(+), 33 deletions(-)

