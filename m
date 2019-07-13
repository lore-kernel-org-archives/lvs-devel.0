From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [net-next 0/2] ipvs: speedup ipvs netns dismantle
Date: Sat, 13 Jul 2019 23:19:44 +0800
Message-ID: <1563031186-2101-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Implement exit_batch() method to dismantle more ipvs netns
per round.

Haishuang Yan (2):
  ipvs: batch __ip_vs_cleanup
  ipvs: batch __ip_vs_dev_cleanup

 include/net/ip_vs.h             |  2 +-
 net/netfilter/ipvs/ip_vs_core.c | 49 +++++++++++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 13 ++++++++---
 3 files changed, 41 insertions(+), 23 deletions(-)

-- 
1.8.3.1



