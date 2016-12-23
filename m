From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ANNOUNCE] ipvsadm release v1.29
Date: Fri, 23 Dec 2016 12:03:07 +0100
Message-ID: <20161223120307.2eb533a5@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org
Cc: brouer@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Ryan O'Hara <rohara@redhat.com>, Quentin Armitage <quentin@armitage.org.uk>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Alex Gartrell <agartrell@fb.com>


We are happy to announce the release of ipvsadm v1.29.

 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer service

It has been far too long since the last ipvsadm release. Even-though
only two changes to the ipvsadm tool happened since last release, a
release must be made as these feature relates to kernel side features.

Support for reading 64-bit stats is avail since kernel v4.1.  The new
attributes for sync daemon got introduced in kernel v4.3, but got
fixed in kernel v4.7.

Merry Xmas and a Happy New year to all :-)


This release is based on the kernel.org git tree:
  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

Git tree:
 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

Shortlog:

Jesper Dangaard Brouer (1):
      Release: Version 1.29

Julian Anastasov (2):
      ipvsadm: support 64-bit stats and rates
      ipvsadm: new attributes for sync daemon

