From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 0/2] Fixes for netns initializations
Date: Wed, 25 Apr 2012 00:29:57 +0300
Message-ID: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This changeset fixes problems with failed netns
initializations. Hans should provide similar fix for
LBLC and LBLCR. This is for the stable tree.

Julian Anastasov (2):
  ipvs: reset ipvs pointer in netns
  ipvs: add check in ftp for initialized core

 net/netfilter/ipvs/ip_vs_core.c |    2 ++
 net/netfilter/ipvs/ip_vs_ftp.c  |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

-- 
1.7.3.4

