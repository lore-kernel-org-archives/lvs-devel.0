From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 19:11:43 +0200
Message-ID: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204334; bh=onBfpUX+7N2p8s5x4P9iXpoqYVA=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer;
	b=GRLL0K3uC2Qy4EGfHJ6KCk/PFISJDCXtn0HlW8ZzizL6T5aygDhFRNnHthKJvJkCN
	DyE3RwcH6Q3k9UGVF4G1w==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Hi,

This patch series adds first experimental IPv6 support to IPVS. I have
already posted it to the LVS mailing list as one huge patch a while ago,
so here's the split-up version, although it is still very big. I don't see
an easy way of breaking up the series into truly independent chunks though,
since most of it seems very interdependent. I'm still a kernel newbie, so
any advice is welcome :)

- Full kernel patch in one file against davem's net-2.6:
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6.patch

- It depends on this patch that moves the "ipvs" directory to "net/netfilter":
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/move_ipvs_to_netfilter.patch
(this patch really only moves files from one directory to another, so
no real content changes in there)

While not all IPv6 features are working or tested, existing IPv4 features
should still work as before. However, as these changes break the
kernel<->userspace interface, you need a new version of ipvsadm to use
these patches, even for IPv4-only operation:

- ipvsadm patch and tar.gz (by Vince Busam):
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvsadm-1.25-ipv6-1.patch
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvsadm-1.25-ipv6-1.tar.gz

While I have mainly been working on the kernel part, Vince Busam has been
converting ipvsadm to support the new kernel features from userspace.

To enable IPv6 support in IPVS, set CONFIG_IP_VS_IPV6.

Short overview:

What works with IPv6:
- forwarding mechanisms: NAT, DR, maybe Tunnel (not fully tested yet)
- protocols: TCP, UDP, ESP, AH (last two not tested)
- manipulation and inspection of both IPv4 and IPv6 entries with ipvsadm
- 6 out of 10 schedulers

What is not supported with IPv6:
- handling fragmentation or other extension headers
- FTP application helper (can be loaded, but only operates on v4)
- sync daemon (can be started, but only operates on v4)
- probably some incorrect handling of ICMPv6 or other corner cases

Since fragmentation and extension headers should not occur very often,
things should "mostly" work. I tested HTTP and DNS over NAT and DR
with various supported schedulers without encountering any problems.
But we didn't test any exotic situations. Also, there are some TODOs
in the code for things that haven't been tested or implemented yet.

I copied and changed many IPv4 methods into corresponding IPv6
versions, so the duplication is quite high. I chose to go that way in
order to not break too much of the existing IPv4 code. The upside of
this is that v4 should hopefully still work exactly as before. All
relevant data structures have an added 'af' field for specifying the
address family and use a union of both a v4 and v6 address for specifying
IP addresses.

Feel free to comment, question, criticize, ridicule... this is our first
big kernel project though, so please don't be too hard on us! ;)

 include/net/ip_vs.h                  |  267 +++++++++--
 net/netfilter/ipvs/Kconfig           |    8 +
 net/netfilter/ipvs/ip_vs_conn.c      |  406 ++++++++++++++--
 net/netfilter/ipvs/ip_vs_core.c      |  865 +++++++++++++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_ctl.c       |  565 ++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_dh.c        |    3 +
 net/netfilter/ipvs/ip_vs_ftp.c       |   34 +-
 net/netfilter/ipvs/ip_vs_lblc.c      |    3 +
 net/netfilter/ipvs/ip_vs_lblcr.c     |    3 +
 net/netfilter/ipvs/ip_vs_lc.c        |   20 +-
 net/netfilter/ipvs/ip_vs_nq.c        |   15 +-
 net/netfilter/ipvs/ip_vs_proto.c     |   67 +++-
 net/netfilter/ipvs/ip_vs_proto_ah.c  |  122 +++++-
 net/netfilter/ipvs/ip_vs_proto_esp.c |  121 +++++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c |  320 ++++++++++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c |  294 +++++++++++-
 net/netfilter/ipvs/ip_vs_rr.c        |    3 +
 net/netfilter/ipvs/ip_vs_sed.c       |   22 +-
 net/netfilter/ipvs/ip_vs_sh.c        |    3 +
 net/netfilter/ipvs/ip_vs_sync.c      |    6 +-
 net/netfilter/ipvs/ip_vs_wlc.c       |   22 +-
 net/netfilter/ipvs/ip_vs_wrr.c       |   22 +-
 net/netfilter/ipvs/ip_vs_xmit.c      |  467 ++++++++++++++++++-
 23 files changed, 3401 insertions(+), 257 deletions(-)

Julius Volz
