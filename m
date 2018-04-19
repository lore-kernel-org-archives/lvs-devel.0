From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/5] IPVS Updates for v4.18
Date: Thu, 19 Apr 2018 10:56:09 +0200
Message-ID: <20180419085614.7437-1-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128186; bh=c1jeE8c+lFfr6tDWvZXN7D8X3KUXzvsJqQ5UI5woVRs=;
        h=From:To:Cc:Subject:Date:From;
        b=k/vji2NZlIMyzDEfmAfzHiIs8xnbp9/ctOjf7UN6Wlv8kY4dP46JprsUOz62vVoY/
         LZCRtER9GH5oaXqBn38EzH8naWQZzd7Hm9Nlg75OcSvia6LQ5ZaVDsRa1SRsK4m2Kr
         xA9CSRwyh1oQEOUTssf0Z7gx39SRmFfZmsj+QduA=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS enhancements for v4.18.

* Whitepace cleanup

* Add Maglev hashing algorithm as a IPVS scheduler

  Inju Song says "Implements the Google's Maglev hashing algorithm as a
  IPVS scheduler.  Basically it provides consistent hashing but offers some
  special features about disruption and load balancing.

  1) minimal disruption: when the set of destinations changes,
     a connection will likely be sent to the same destination
     as it was before.

  2) load balancing: each destination will receive an almost
     equal number of connections.

 Seel also: [3.4 Consistent Hasing] in
 https://www.usenix.org/system/files/conference/nsdi16/nsdi16-paper-eisenbud.pdf
 "

* Fix to correct implementation of Knuth's multiplicative hashing
  which is used in sh/dh/lblc/lblcr algorithms. Instead the
  implementation provided by the hash_32() macro is used.

The following changes since commit 159f02977b2feb18a4bece5e586c838a6d26d44b:

  Merge branch 'net-mvneta-improve-suspend-resume' (2018-04-02 11:14:03 -0400)

are available in the git repository at:

  http://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.18

for you to fetch changes up to 9a17740e0ea1c9b1edd89836bb27c76272f54641:

  ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms (2018-04-09 10:15:27 +0300)

----------------------------------------------------------------
Arvind Yadav (1):
      netfilter: ipvs: Fix space before '[' error.

Inju Song (3):
      netfilter: ipvs: Keep latest weight of destination
      netfilter: ipvs: Add Maglev hashing scheduler
      netfilter: ipvs: Add configurations of Maglev hashing

Vincent Bernat (1):
      ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms

 include/net/ip_vs.h                  |   1 +
 net/netfilter/ipvs/Kconfig           |  37 +++
 net/netfilter/ipvs/Makefile          |   1 +
 net/netfilter/ipvs/ip_vs_ctl.c       |   4 +
 net/netfilter/ipvs/ip_vs_dh.c        |   3 +-
 net/netfilter/ipvs/ip_vs_lblc.c      |   3 +-
 net/netfilter/ipvs/ip_vs_lblcr.c     |   3 +-
 net/netfilter/ipvs/ip_vs_mh.c        | 540 +++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c |   4 +-
 net/netfilter/ipvs/ip_vs_sh.c        |   3 +-
 10 files changed, 593 insertions(+), 6 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_mh.c
