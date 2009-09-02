From: Hannes Eder <heder@google.com>
Subject: [PATCH 0/3] IPVS full NAT support + netfilter 'ipvs' match support
Date: Wed,  2 Sep 2009 16:38:12 +0200 (CEST)
Message-ID: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251902303; bh=aIGi+OIdvMng+R2bCWr6C0nIlSY=;
	h=DomainKey-Signature:Subject:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:
	 Cc:From:Message-ID:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Date:X-System-Of-Record; b=kuHkM33gl7Mbo
	zVPoqxLG4pnFVhO6XBYJ7uzLMTCRheMkUPYLhQ8s9vJdJarb44A+ewRMPCPfyjWLxWv
	A+jTQg==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

The following series implements full NAT support for IPVS.  The
approach is via a minimal change to IPVS (make friends with
nf_conntrack) and adding a netfilter matcher, kernel- and user-space
part, i.e. xt_ipvs and libxt_ipvs.

Example usage:

% ipvsadm -A -t 192.168.100.30:8080 -s rr
% ipvsadm -a -t 192.168.100.30:8080 -r 192.168.10.20:8080 -m
# ...

# Source NAT for VIP 192.168.100.30:8080
% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 --vport 8080 \
> -j SNAT --to-source 192.168.10.10


Changes to the linux kernel (rebased to next-20090831):

Hannes Eder (2):
      netfilter: xt_ipvs (netfilter matcher for IPVS)
      IPVS: make friends with nf_conntrack


 include/linux/netfilter/xt_ipvs.h |   23 +++++
 net/netfilter/Kconfig             |    9 ++
 net/netfilter/Makefile            |    1 
 net/netfilter/ipvs/Kconfig        |    2 
 net/netfilter/ipvs/ip_vs_core.c   |   36 -------
 net/netfilter/ipvs/ip_vs_proto.c  |    1 
 net/netfilter/ipvs/ip_vs_xmit.c   |   27 +++++
 net/netfilter/xt_ipvs.c           |  183 +++++++++++++++++++++++++++++++++++++
 8 files changed, 245 insertions(+), 37 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c


Changs to iptables:

Hannes Eder (1):
      libxt_ipvs: user space lib for netfilter matcher xt_ipvs


 configure.ac                      |   11 +
 extensions/libxt_ipvs.c           |  349 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |   21 ++
 include/linux/netfilter/xt_ipvs.h |   23 ++
 4 files changed, 401 insertions(+), 3 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h

