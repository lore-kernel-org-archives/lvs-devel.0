From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v4 00/14] ipvs: Add icmp scheduling
Date: Wed, 26 Aug 2015 10:47:52 -0700
Message-ID: <1440611272-437619-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=etcoegglmc44xz+I//C0bG8+ecSClHkNqT2LZ3Yejug=;
 b=UNvNCKySyRa1+4Qe5C62d3G6S0uTFyycSWL04d7Lb6/XRx7hKG4lk1VJtMW00nWClVYo
 zajGTO//EU6JQ/UtNcvv9jvpL+mcvWey2HRfhsSY0+yPp6+G6xezoKNTXSrlG3YIrPfm
 2dhDd4F2kivXqS2GADVYwr1kGeLYPCLbHg4= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

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

Updates:
  v2: Added ip_vs_sh change, IP_VS_DBG_PKT macro changes,
      reordered ip_vs_try_to_schedule, and other ja fixes.
  v3: Added ip_vs_leave change, ip_vs_sched_persist handling,
      and `offset = ciph.len` change.  Dropped unnecessary !cp check
  v4: Return NF_DROP from ip_vs_leave on icmp_case if not ftp special case.
      Fix LOG invocation with iph->off argument in ip_vs_try_to_schedule

Alex Gartrell (14):
  ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
  ipvs: Add hdr_flags to iphdr
  ipvs: Handle inverse and icmp headers in ip_vs_leave
  ipvs: pull out ip_vs_try_to_schedule function
  ipvs: drop inverse argument to conn_{in,out}_get
  ipvs: Make ip_vs_schedule aware of inverse iph'es
  ipvs: add schedule_icmp sysctl
  ipvs: Use outer header in ip_vs_bypass_xmit_v6
  ipvs: sh: support scheduling icmp/inverse packets consistently
  ipvs: attempt to schedule icmp packets
  ipvs: ensure that ICMP cannot be sent in reply to ICMP
  ipvs: support scheduling inverse and icmp TCP packets
  ipvs: support scheduling inverse and icmp UDP packets
  ipvs: support scheduling inverse and icmp SCTP packets

 include/net/ip_vs.h                     | 109 ++++++++----
 net/netfilter/ipvs/ip_vs_conn.c         |  12 +-
 net/netfilter/ipvs/ip_vs_core.c         | 289 +++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_ctl.c          |   8 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c       |   2 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  17 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  34 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  38 ++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  25 ++-
 net/netfilter/ipvs/ip_vs_sh.c           |  45 +++--
 net/netfilter/ipvs/ip_vs_xmit.c         |  24 +--
 net/netfilter/xt_ipvs.c                 |   4 +-
 12 files changed, 390 insertions(+), 217 deletions(-)

-- 
Alex Gartrell <agartrell@fb.com>

