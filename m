From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 0/3] Patchset in preparation for ipvsadm release
 v1.27
Date: Thu, 05 Sep 2013 13:23:03 +0200
Message-ID: <20130905112303.5071.14612.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Ryan O'Hara <rohara@redhat.com>

Here are some patches in preparation for the upcomming ipvsadm release
v1.27.  No real coded changes to ipvsadm, just maintainer related
updates and changes.

If nobody objects and when Simon ACKs, I'm going to apply this
patchset myself to the ipvsadm git tree:

  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git

---

Jesper Dangaard Brouer (3):
      Make README more generic and reference new kernel.org location
      Add MAINTAINERS style file
      Maintainer script for releasing tarballs


 MAINTAINERS        |   33 ++++++++++++++
 README             |   26 ++++++++---
 release-tarball.sh |  123 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 174 insertions(+), 8 deletions(-)
 create mode 100644 MAINTAINERS
 create mode 100755 release-tarball.sh


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
