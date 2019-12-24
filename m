From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ANNOUNCE] ipvsadm release v1.31
Date: Tue, 24 Dec 2019 14:37:45 +0100
Message-ID: <20191224143745.6bafce3f@carbon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1577194678;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=RllTSQBanYIj2a+FOREw/6tP9C+MekKkoK3DQ2qokOM=;
        b=Wz7NIdSvyoB0yKqr0eJtEiU7evuz/r0ssXbV/GAf642LRgY2IwEVgliLOTg6M0Dx/RpUDI
        e5jBG0W3630jWt1lg2NjliCTcIfBwzDp5U6QfHXb8f15LITM05g33ov4WYvUATYgCf2qbr
        CxWnoOsSlX1P64ws9c7JMP83DUGpNc0=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Julian Anastasov <ja@ssi.bg>, Jacky Hu <hengqing.hu@gmail.com>, Quentin Armitage <quentin@armitage.org.uk>
Cc: brouer@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Ryan O'Hara <rohara@redhat.com>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

Merry Xmas,

We are happy to announce the release of ipvsadm v1.31.

 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer service

This release add support for configuring tunneling with GRE or GUE
encapsulation. See manpage ipvsadm(8) for --tun-type and --tun-info,
plus more specific --tun-xxxx options for adjustments. Plus some
manpage adjustments.

The related kernel side commits:
- v5.3: 6aedd14b25db ("ipvs: strip gre tunnel headers from icmp errors")
- v5.3: 6f7b841bc939 ("ipvs: allow tunneling with gre encapsulation")
- v5.3: 29930e314da3 ("ipvs: add checksum support for gue encapsulation")
- v5.3: 508f744c0de3 ("ipvs: strip udp tunnel headers from icmp errors")
- v5.3: 2aa3c9f48bc2 ("ipvs: add function to find tunnels")
- v5.2: 84c0d5e96f3a ("ipvs: allow tunneling with gue encapsulation")

This release is based on the kernel.org git tree:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

Git tree:
 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

Shortlog:

Jacky Hu (2):
      ipvsadm: convert options to unsigned long long
      ipvsadm: allow tunneling with gue encapsulation

Jesper Dangaard Brouer (2):
      Merge branch 'GUE-encap'
      Release: Version 1.31

Julian Anastasov (1):
      ipvsadm: allow tunneling with gre encapsulation

Quentin Armitage (2):
      Add --pe sip option in ipvsadm(8) man page
      In ipvsadm(8) add using nft or an eBPF program to set a packet mark

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

