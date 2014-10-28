From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Updates for v3.19
Date: Tue, 28 Oct 2014 09:59:19 +0900
Message-ID: <1414457960-20864-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS updates for v3.19.

The single patch in this series fixes some minor fallout from adding
support IPv6 real servers in IPv4 virtual-services and vice versa.

It should not have any run-time affect other than perhaps saving a few cycles.


The following changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c381931:

  Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb (2014-10-19 12:58:22 -0700)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.19

for you to fetch changes up to d7701089118d23bfed03bad0a6b5cc5115990c9e:

  ipvs: remove unnecessary assignment in __ip_vs_get_out_rt (2014-10-28 09:50:06 +0900)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: remove unnecessary assignment in __ip_vs_get_out_rt

 net/netfilter/ipvs/ip_vs_xmit.c | 1 -
 1 file changed, 1 deletion(-)
