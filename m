From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Tue, 24 Jul 2012 08:28:55 +0900
Message-ID: <1343086141-9086-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

please consider the following enhancements to IPVS for inclusion in 3.6.

----------------------------------------------------------------
The following changes since commit 9b70749e64132e17ab02239b82fcb4a2c55554d1:

  niu: Change niu_rbr_fill() to use unlikely() to check niu_rbr_add_page() return value (2012-07-22 23:31:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to a805cfbcaaf819ab71a052d8a9d5d4c88cf2aba0:

  ipvs: add pmtu_disc option to disable IP DF for TUN packets (2012-07-24 08:23:06 +0900)

----------------------------------------------------------------
Claudiu Ghioc (1):
      ipvs: fixed sparse warning

Julian Anastasov (4):
      ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
      ipvs: generalize app registration in netns
      ipvs: implement passive PMTUD for IPIP packets
      ipvs: add pmtu_disc option to disable IP DF for TUN packets

 include/net/ip_vs.h             | 16 ++++++--
 net/netfilter/ipvs/Kconfig      |  3 +-
 net/netfilter/ipvs/ip_vs_app.c  | 58 ++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_core.c | 76 +++++++++++++++++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 16 ++++++--
 net/netfilter/ipvs/ip_vs_ftp.c  | 21 +++--------
 net/netfilter/ipvs/ip_vs_xmit.c | 83 ++++++++++++++++++++++++++++-------------
 7 files changed, 204 insertions(+), 69 deletions(-)
