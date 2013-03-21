From: Krzysztof Gajdemski <songo@debian.org.pl>
Subject: [PATCH 0/2] ipvsadm: fix one-packet scheduling listing
Date: Thu, 21 Mar 2013 11:39:39 +0100
Message-ID: <20130321103939.GA9563@debian.org.pl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>

Two simple patches fixing 'ops' option display for 'ipvsadm -S' and
'ipvsadm -L' commands. Patch 1/2 fixes bug which prevents OPS services
from save/restore. Patch 2/2 allows the 'ops' flag to be displayed in
any OPS-enabled VS.

Krzysztof Gajdemski (2):
  ipvsadm: Fix wrong format of -o option in FMT_RULE listing
  ipvsadm: Show 'ops' flag regardless of service persistence

 ipvsadm.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
1.7.10.4
