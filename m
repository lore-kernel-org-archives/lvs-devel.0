From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net-next 0/2] Future changes
Date: Thu, 12 Sep 2013 11:22:04 +0300
Message-ID: <1378974126-9427-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This patchset contains my pending patches when
net-next opens. While first patch does not depend on
recent commits, the second patch depends on some fixes
we will add after 3.12: "ipvs: make the service replacement more robust".
So, the second patch should wait some -rc releases.
I'll resend it later if needed.

Julian Anastasov (2):
  ipvs: fix the IPVS_CMD_ATTR_MAX definition
  ipvs: avoid rcu_barrier during netns cleanup

 include/net/ip_vs.h              |    6 ++++++
 include/uapi/linux/ip_vs.h       |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |    6 +-----
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 5 files changed, 10 insertions(+), 8 deletions(-)

-- 
1.7.3.4

