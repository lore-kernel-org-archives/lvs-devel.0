From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH ipvsadm 0/2] Changes for ipvsadm
Date: Fri, 13 Jul 2012 11:48:44 +0300
Message-ID: <1342169326-1911-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

	Do we have ipvsadm on git? I downloaded something
from svn to base these two patches.

Julian Anastasov (2):
  Fix the --pe option checks
  Fallback to libpopt on shared object

 Makefile  |   15 +++++++++++++++
 ipvsadm.c |   32 ++++++++++++++++----------------
 2 files changed, 31 insertions(+), 16 deletions(-)

-- 
1.7.3.4

