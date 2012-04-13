From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/2] Changes for app registrations
Date: Fri, 13 Apr 2012 11:44:00 +0300
Message-ID: <1334306642-3765-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This changeset fixes problems with failed netns
initializations.

Julian Anastasov (2):
  ipvs: reset ipvs pointer in netns
  ipvs: fix app registration in netns

 include/net/ip_vs.h             |    5 +--
 net/netfilter/ipvs/ip_vs_app.c  |   57 ++++++++++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_core.c |    2 +
 net/netfilter/ipvs/ip_vs_ftp.c  |   22 ++++-----------
 4 files changed, 54 insertions(+), 32 deletions(-)

-- 
1.7.3.4

