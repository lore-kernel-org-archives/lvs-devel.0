Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794192897;
	b=Vsrm9z+cx0MAU9VgHSmNB/R3qGseHdFtSGVPiGA6Y50P9ogL+wRjRsIQ1HKlWe9/R0cU
	 3qfM15uPd/eKCoNxeIyzY1O+TK2j1GE07PWVedAvXTo5v5lTO6i2kXwsaSH1mdWPWetSQ
	 rUpfgDp02N/dZ9Z6v1fNgMGZdg2nF+PUyK1O72F/DH0Id2fQPZjalQMyZvhcbEEte2WIf
	 UySFGJO5opjdP8J9K/PVC2Lop3EnMKNCmQ2U1K4x8u7yYnEwD/vk6/ulEvGnKhlsMg3Ls
	 /ng4iKfPVJg/UAzM234jYYugQOnL/LBs3n6/yGpXmfhyyfUaic6bxjvuHJcdc6SQ6WQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794192897;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=hYrJTFeeaJTcrWxyWoGWMilmtuo78RKW5cGiyhOt/fM=;
	b=ISC62ggnYG8n11MXEpKkkKtqCwSmKAvr8gulzg194GHTBbd7LCDtaSneCvgqNu8+9Vdo
	 2QfCv0mQXMqhsR2MxdjFo+vwe8P4WCwFB9N4p0K1pTXuIqkx/3tldfjUwOPCejdpG7RkS
	 pxrPEErvKtfqaMR4LYxr9wbPBfNQJqBjDlYm+wdHi6D6JgrAUx258Ky450iOtYDuk2PsX
	 qWochQ4Uf8tUGgc/jF9fbC60vnPV/DTjedsfQ5l/aUKcadBUEze0JpHhqtK43WvUXzXK5
	 VMYqPww4PIaptTsXB7OjcTJademEDr1GnknLIan/ij0dvfoD/EGIJ1/Uk50DYU7Xf2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=o8byScok;
	arc=none smtp.remote-ip=95.215.58.159
Received: from mta1.migadu.com (out-159.mta1.migadu.com [95.215.58.159])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 903FC606A320
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 903FC606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=o8byScok
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=AklJRutHnCjXFhvSqdKi7qHVk0KLDVHRQgdOQp8cMPo=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794192894; v=1; x=1794797694;
 b=o8byScokjp+ULsxsEcyZI40PKGlyJqSpGRqP4vcSIwCXSrrhBoDONhExVlJxSlTTdikAeYQC
 xhln6Y4vnRwQLa49NRuuEVKNyJk2DmR/vJ6tJYRvyuPAOT298kMqpfrXh9/kkeOtD8X8m+nGLFc
 sabLDu4xDbC2LSZYG4cZKbsA=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 89474d14179b70cf;
	Mon, 09 Nov 2026 02:54:54 +0000
X-Mizu-Trace-ID: 89474d14179b70cf
X-Migadu-Flow: FLOW_OUT
From: Jiayuan Chen <jiayuan.chen@linux.dev>
To: netdev@vger.kernel.org
Cc: Jiayuan Chen <jiayuan.chen@linux.dev>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	bridge@lists.linux.dev,
	linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	linux-s390@vger.kernel.org
Subject: [PATCH net-next 00/14] net: annotate data-races around sysctl knobs
Date: Mon,  9 Nov 2026 10:51:59 +0800
Message-ID: <20261109025425.328445-1-jiayuan.chen@linux.dev>
X-Mailer: git-send-email 2.43.0
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While testing the recent sysctl range fixes I noticed that a lot of our
sysctl knobs are read with plain loads while the handlers update them
with WRITE_ONCE() and no lock, so KCSAN reports them as data races. I
then used an LLM to go through every ctl_table under net/ and list the
readers that were left behind. This series annotates them with
READ_ONCE(), and adds WRITE_ONCE() to a few custom handlers and netlink
paths that store to the same fields with plain writes. Most of it is a
plain READ_ONCE() at each read; where a function reads the same knob
twice to make one decision, it now reads it once into a local, so the
comparison and the value it acts on cannot come from two different
writes.

There are no Fixes tags. Done one knob per patch this would be well over
a hundred commits, so I grouped them by subsystem and feature instead to
keep the review manageable. If maintainers prefer, I can split it up
further with a Fixes tag on each one, as several smaller series.

No functional change. KCSAN does hit these, e.g. toggling
net.ipv6.icmp.echo_ignore_all while receiving ICMPv6 echo requests:

  BUG: KCSAN: data-race in icmpv6_rcv / proc_dou8vec_minmax

  write (marked) to 0xffffffff8ee2940d of 1 bytes by task 504 on cpu 0:
   proc_dou8vec_minmax+0x1ab/0x1f0
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffffffff8ee2940d of 1 bytes by interrupt on cpu 3:
   icmpv6_rcv+0x99d/0xd40
   ip6_protocol_deliver_rcu+0x787/0x9a0
   ip6_input_finish+0xb0/0x1b0
   ip6_input+0xa8/0x250
   ipv6_rcv+0x14b/0x1c0
   ...

  value changed: 0x01 -> 0x00

Jiayuan Chen (14):
  ipv4: annotate data-races around ip_rt_* sysctls
  inet: frags: annotate data-races around fqdir->timeout and
    fqdir->max_dist
  ipv6: annotate data-races around addrconf sysctls
  ipv6: annotate data-races around icmpv6 reply sysctls
  calipso: annotate data-races around cache sysctls
  sctp: annotate data-races around sctp sysctls
  mptcp: annotate data-races around pernet sysctls
  rds: annotate data-races around core rds sysctls
  netfilter: conntrack: annotate data-races around conntrack sysctls
  netfilter: bridge: annotate data-races around br_netfilter and nf_log
    sysctls
  ipvs: annotate data-races around lblc_expiration and lblcr_expiration
  net/smc: annotate data-races around smc sysctls
  netfilter: conntrack: annotate data-races around timeout and tcp
    sysctls
  netfilter: cttimeout: annotate data-races around the default timeouts

 include/net/ipv6.h                            |   2 +-
 include/net/netfilter/nf_conntrack_acct.h     |   6 +-
 .../net/netfilter/nf_conntrack_timestamp.h    |   2 +-
 net/bridge/br_netfilter_hooks.c               |  20 ++--
 net/bridge/netfilter/ebt_log.c                |   2 +-
 net/ipv4/inet_fragment.c                      |   2 +-
 net/ipv4/ip_fragment.c                        |   6 +-
 net/ipv4/route.c                              |  34 +++---
 net/ipv6/addrconf.c                           |  22 ++--
 net/ipv6/calipso.c                            |   6 +-
 net/ipv6/icmp.c                               |  10 +-
 net/ipv6/ndisc.c                              |   2 +-
 net/ipv6/route.c                              |   8 +-
 net/mptcp/ctrl.c                              |  18 +--
 net/netfilter/ipvs/ip_vs_lblc.c               |   2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c              |   2 +-
 net/netfilter/nf_conntrack_core.c             |   8 +-
 net/netfilter/nf_conntrack_ecache.c           |   2 +-
 net/netfilter/nf_conntrack_expect.c           |   2 +-
 net/netfilter/nf_conntrack_netlink.c          |   2 +-
 net/netfilter/nf_conntrack_proto.c            |   6 +-
 net/netfilter/nf_conntrack_proto_generic.c    |   8 +-
 net/netfilter/nf_conntrack_proto_gre.c        |  20 ++--
 net/netfilter/nf_conntrack_proto_icmp.c       |  12 +-
 net/netfilter/nf_conntrack_proto_icmpv6.c     |  12 +-
 net/netfilter/nf_conntrack_proto_sctp.c       |  13 ++-
 net/netfilter/nf_conntrack_proto_tcp.c        | 110 +++++++++---------
 net/netfilter/nf_conntrack_proto_udp.c        |  24 ++--
 net/netfilter/nf_flow_table_core.c            |   4 +-
 net/netfilter/nf_log_syslog.c                 |   2 +-
 net/rds/recv.c                                |   2 +-
 net/rds/send.c                                |   8 +-
 net/rds/threads.c                             |   4 +-
 net/sctp/associola.c                          |   2 +-
 net/sctp/bind_addr.c                          |   2 +-
 net/sctp/endpointola.c                        |  14 +--
 net/sctp/input.c                              |   2 +-
 net/sctp/sm_make_chunk.c                      |   6 +-
 net/sctp/sm_sideeffect.c                      |   2 +-
 net/sctp/sm_statefuns.c                       |   6 +-
 net/sctp/socket.c                             |  46 ++++----
 net/sctp/sysctl.c                             |  16 +--
 net/sctp/transport.c                          |   6 +-
 net/smc/af_smc.c                              |   8 +-
 net/smc/smc_clc.c                             |   8 +-
 net/smc/smc_core.c                            |   2 +-
 net/smc/smc_tx.c                              |   2 +-
 47 files changed, 259 insertions(+), 246 deletions(-)

-- 
2.43.0

