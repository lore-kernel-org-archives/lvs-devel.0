From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] Second round of IPVS Updates for v3.19
Date: Wed, 10 Dec 2014 17:46:40 +0900
Message-ID: <1418201201-19257-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS updates for v3.19 or alternatively v3.20.

The single patch in this series fixes a long standing bug that
has not caused any trouble and thus is not being prioritised as a fix.


The following changes since commit d6b00fec5dbbe976904b4d77e7d4f9493df5c2ec:

  macvlan: play well with ipvlan device (2014-12-09 16:10:06 -0500)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.19

for you to fetch changes up to 3b05ac3824ed9648c0d9c02d51d9b54e4e7e874f:

  ipvs: uninitialized data with IP_VS_IPV6 (2014-12-10 17:36:47 +0900)

----------------------------------------------------------------
Dan Carpenter (1):
      ipvs: uninitialized data with IP_VS_IPV6

 net/netfilter/ipvs/ip_vs_ftp.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)
