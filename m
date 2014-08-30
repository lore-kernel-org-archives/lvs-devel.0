From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/2] More changes for different address family
Date: Sat, 30 Aug 2014 14:35:47 +0300
Message-ID: <1409398549-5386-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Alex Gartrell <agartrell@fb.com>, kernel-team@fb.com

Following are 2 patches that support different address family
for virtual and real server.

Alex, please test them too.

Julian Anastasov (2):
  ipvsadm: restrict different address family
  ipvsadm: allow different address family in connection listing

 ipvsadm.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

-- 
1.9.0

