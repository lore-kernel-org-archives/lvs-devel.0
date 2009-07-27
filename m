From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 0/5] IPVS full NAT support + netfilter 'ipvs' match support
Date: Mon, 27 Jul 2009 15:46:11 +0200
Message-ID: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752667AbZG0Pb2@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248708680; bh=O4Blt+yC77RtYKzkmrCcS0SXyAQ=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:User-Agent:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:
	 X-System-Of-Record; b=a3xgzD48AtfHWJIMGdOVtUG1+d1OLX1xjdsFI6oUHRnv
	Y0xyrVr+wOWY4XpQmwCDAYvilykj4rr2ZYb1/5c75A==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

The following series is aiming at adding full NAT support to IPVS.  The
approach is via a minimal change to IPVS (make friends with nf_conntrack)
and adding a netfilter matcher (xt_ipvs + libxt_ipvs).

Example usage:

% ipvsadm -A -t 192.168.100.30:8080 -s rr
% ipvsadm -a -t 192.168.100.30:8080 -r 192.168.10.20:8080 -m
# ...

# SNAT for VIP 192.168.100.30:8080
% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 8080 \
> -j SNAT --to-source 192.168.10.10 

Comments?

Changes to the linux kernel:

Hannes Eder (4):
      IPVS: debugging output for ip_vs_update_conntrack
      IPVS: make friends with nf_conntrack
      netfilter: xt_ipvs (netfilter matcher for ipvs)
      IPVS: prefix EnterFunction and LeaveFunction msg with "IPVS:"

 include/linux/netfilter/xt_ipvs.h |   32 +++++++
 include/net/ip_vs.h               |   24 +++--
 net/netfilter/Kconfig             |    8 ++
 net/netfilter/Makefile            |    1 
 net/netfilter/ipvs/ip_vs_core.c   |   36 --------
 net/netfilter/ipvs/ip_vs_proto.c  |    1 
 net/netfilter/ipvs/ip_vs_xmit.c   |   54 ++++++++++++
 net/netfilter/xt_ipvs.c           |  171 +++++++++++++++++++++++++++++++++++++
 8 files changed, 279 insertions(+), 48 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c


Changes to iptables:

Hannes Eder (1):
      libxt_ipvs: user space lib for netfilter matcher xt_ipvs

 extensions/libxt_ipvs.c           |  350 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |    7 +
 include/linux/netfilter/xt_ipvs.h |   32 +++
 3 files changed, 389 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h


Cheers,
-Hannes
