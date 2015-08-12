From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 00/12] ipvs: Add icmp scheduling
Date: Wed, 12 Aug 2015 13:46:58 -0700
Message-ID: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=SoFgWGD/tTbCmdpMJNKjepUHjqMsO5Tk9n333GaOrag=;
 b=KPWQrhao/s+QyqEdk0OpJAKCCbx8qdZp+Qvupf+kxjy1JwB2D/+lPAM9Fiy9ba/7YQpb
 HtDH28BUv0k6SPTaCcPULsnXzMLxFjoi38aNA9xdphEk/d0TPV+m9Vpuoqd2oi9HK1pj
 Ny9mw4y13exYRtjX1fpM3OXlLuH148wm25U= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

The configuration of ipvs at Facebook is relatively straightforward.  All
ipvs instances bgp advertise a set of VIPs and the network prefers the
nearest one or uses ECMP in the event of a tie.  For the uninitiated, ECMP
deterministically and statelessly load balances by hashing the packet
(usually a 5-tuple of protocol, saddr, daddr, sport, and dport) and using
that number as an index (basic hash table type logic).

The problem is that ICMP packets (which contain really important
information like whether or not an MTU has been exceeded) will get a
different hash value and may end up at a different ipvs instance.  With no
information about where to route these packets, they are dropped, creating
ICMP black holes and breaking Path MTU discovery.  Suddenly, my mom's
pictures can't load and I'm fielding midday calls that I want nothing to do
with.

To address this, this patch set introduces the ability to schedule icmp
packets which is gated by a sysctl net.ipv4.vs.schedule_icmp.  If set to 0,
the old behavior is maintained -- otherwise ICMP packets are scheduled.

Alex Gartrell (12):
  ipvs: pull out ip_vs_try_to_schedule function
  ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
  ipvs: Add hdr_flags to iphdr
  ipvs: drop inverse argument to conn_{in,out}_get
  ipvs: Make ip_vs_schedule aware of inverse iph'es
  ipvs: add schedule_icmp sysctl
  ipvs: Use outer header in ip_vs_bypass_xmit_v6
  ipvs: attempt to schedule icmp packets
  ipvs: ensure that ICMP cannot be sent in reply to ICMP
  ipvs: support scheduling inverse and icmp TCP packets
  ipvs: support scheduling inverse and icmp UDP packets
  ipvs: support scheduling inverse and icmp SCTP packets

 include/net/ip_vs.h                     | 101 ++++++++++++-----
 net/netfilter/ipvs/ip_vs_conn.c         |  12 +-
 net/netfilter/ipvs/ip_vs_core.c         | 190 +++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_ctl.c          |   8 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  17 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  35 ++++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  37 +++++--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  26 ++++-
 net/netfilter/ipvs/ip_vs_xmit.c         |   9 +-
 9 files changed, 287 insertions(+), 148 deletions(-)

-- 
Alex Gartrell <agartrell@fb.com>

