From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ANNOUNCE] ipvsadm release v1.28
Date: Mon, 9 Feb 2015 18:55:02 +1300
Message-ID: <20150209185502.693488a1@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org
Cc: brouer@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>, Julian Anastasov <ja@ssi.bg>, overcastsky.zhao@gmail.com, formorer@debian.org, mt@suse.de, logan@ubuntu.com, support@remsnet.de, Daniel Borkmann <dborkman@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Alex Gartrell <agartrell@fb.com>


We are happy to announce the release of ipvsadm v1.28.

 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer service

It has been quite a while since the previous release, v1.27. A number of
fixes and improvements have been made; most noticeably in the area of IPv6.

One big addition is the support for heterogeneous pools (v4 and v6
mixed pools in 3.18), by Alex Gartrell (facebook).

Feature wise the SCTP protocol has been added which is available via the
cmdline parameter "--sctp-service". The kernel has supported SCTP since
kernel 2.6.34 but up until now ipvsadm users have been restricted to using
fwmark-based virtual services for SCTP.

This release is based on the kernel.org git tree:
  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

Git tree:
 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

Shortlog:
 Alex Gartrell (2):
      ipvsadm: specify real server address family to netlink socket
      ipvsadm: do not truncate ipv6 members of v4 services

 Daniel Borkmann (2):
      ipvsadm: fix compile warning in print_largenum
      ipvsadm: fix compile warning in modprobe_ipvs

 Hibari Michiro (1):
      ipvsadm: enable displaying of IPv6 hostnames in listing

 Jesper Dangaard Brouer (1):
      Release: Version 1.28

 Julian Anastasov (3):
      ipvsadm: restrict different address family
      ipvsadm: allow different address family in connection listing
      ipvsadm: add SCTP support

 Ryan O'Hara (2):
      libipvs: Initialize ipvs_service_t variable
      ipvsadm: Fix list daemon to show backup daemon


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
