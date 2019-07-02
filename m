From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ANNOUNCE] ipvsadm release v1.30
Date: Tue, 2 Jul 2019 12:24:51 +0200
Message-ID: <20190702122451.556ceb8c@carbon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Julian Anastasov <ja@ssi.bg>
Cc: brouer@redhat.com, netdev@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>, Arthur Gautier <baloo@gandi.net>, Quentin Armitage <quentin@armitage.org.uk>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

We are happy to announce the release of ipvsadm v1.30.

 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer service

There have not been a ipvsadm release for far too long. This release is
focused on kernel release v4.18 and below, for adding the missing userspace
side for the schedulers MH, FO and OVF. There are upcoming change for GUE
and GRE, that are not part of this release.

There have been very little development on the tool, but this release still
contains userspace config to kernel side features that span many kernel
releases. Special thanks to Quentin Armitage for adding this userspace side
support, that was missing in ipvsadm.

This release contains userspace support and/or doc for 3 more schedulers:
 - mh:  Maglev Hashing: added in kernel v4.18
 - ovf (doc): Weighted Overflow: added in kernel v4.3
   - https://git.kernel.org/torvalds/c/eefa32d3f3c5
 - fo (doc): Weighted FailOver: added in kernel v3.18
   - https://git.kernel.org/torvalds/c/616a9be25cb9

This release is based on the kernel.org git tree:
  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

Git tree:
 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

Shortlog:

Arthur Gautier (1):
      libipvs: discrepancy with libnl genlmsg_put

Jesper Dangaard Brouer (2):
      Merge: ipvsadm: Document/add support for fo/ovf/mh schedulers
      Release: Version 1.30

Julian Anastasov (2):
      ipvsadm: catch the original errno from netlink answer
      libipvs: fix some buffer sizes

Quentin Armitage (3):
      Document support of fo scheduler
      Document support of ovf scheduler
      Add support for mh scheduler

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
