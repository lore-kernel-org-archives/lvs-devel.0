From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS
Date: Mon, 28 Jan 2013 10:18:33 +0900
Message-ID: <1359335914-27325-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Dan Carpenter <dan.carpenter@oracle.com>

Hi Pablo,

please consider the following fix for IPVS patch for 3.8.

I believe that the problem was introduced in 3.4 and thus
this fix is appropriate for 3.4, 3.5, 3.6 and 3.7 -stable.

----------------------------------------------------------------
The following changes since commit 5b76c4948fe6977bead2359c2054f3e6a2dcf3d0:

  netfilter: x_tables: print correct hook names for ARP (2013-01-13 12:54:12 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to b425df4cdd953a400d814b4474c9d3ec04481858:

  ipvs: freeing uninitialized pointer on error (2013-01-28 10:14:37 +0900)

----------------------------------------------------------------
Dan Carpenter (1):
      ipvs: freeing uninitialized pointer on error

 net/netfilter/ipvs/ip_vs_sync.c |    2 ++
 1 file changed, 2 insertions(+)
