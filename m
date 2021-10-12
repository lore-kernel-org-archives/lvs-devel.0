From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next v2 0/4] netfilter: ipvs: remove unneeded hook wrappers
Date: Tue, 12 Oct 2021 19:29:55 +0200
Message-ID: <20211012172959.745-1-fw@strlen.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au, Florian Westphal <fw@strlen.de>

V2: Patch 4/4 had a bug that would enter ipv6 branch for
ipv4 packets, fix that.

This series reduces the number of different hook function
implementations by merging the ipv4 and ipv6 hooks into
common code.

selftests/netfilter/ipvs.sh passes.

Florian Westphal (4):
  netfilter: ipvs: prepare for hook function reduction
  netfilter: ipvs: remove unneeded output wrappers
  netfilter: ipvs: remove unneeded input wrappers
  netfilter: ipvs: merge ipv4 + ipv6 icmp reply handlers

 net/netfilter/ipvs/ip_vs_core.c | 166 ++++++--------------------------
 1 file changed, 32 insertions(+), 134 deletions(-)

-- 
2.32.0

