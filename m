From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 0/3] ipv6: use rt6i_gateway as nexthop
Date: Sun, 20 Oct 2013 15:43:02 +0300
Message-ID: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

	The following patchset makes sure that rt6i_gateway
contains valid nexthop information in all cases, so that
we can use different nexthop for sending.

	The first patch is a simple fix that makes IPVS, TEE,
RAW(hdrincl) and RTF_DYNAMIC(without RTF_GATEWAY) work as
before 3.9. There is a single corner case not solved by
this patch: RAW(hdrincl) or TEE using local address for
nexthop, a silly feature, I guess. In this case we
see zeroes in rt6i_gateway because we get route that is not
cloned. This is solved only with patch 2.

	The second patch is an optimization that makes sure
all resulting routes have rt6i_gateway filled, so that we
can avoid the complex ipv6_addr_any() call added to rt6_nexthop()
by patch 1. And it sets rt6i_gateway for local routes, a case
not handled by patch 1.

	The third patch uses the new rt6_nexthop() function to fix
the matching of gateways in the same way as commit bbb5823cf742a7
("netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper")
fixes nf_conntrack_h323_main.c for IPv4. Currently, it depends on
the new definition of rt6_nexthop() in patch 2. Actually, if
patch 2 is applied, patch 3 becomes a cosmetic change.

	I see the following two alternatives for applying these
patches:

1. Linger patch 2 in net-next to avoid surprises in the upcoming
release. In this case patch 3 can be reworked not to depend on
the new rt6_nexthop() definition in patch 2. I guess this is a
better option, so that patch 2 can be reviewed and tested for
longer time.

2. Include all 3 patches in net tree - more risky because this
is my first attempt to change IPv6.

	Here is the situation as handled by patch 2:

	In IPv6 the resolved routes are always host routes (/128
with DST_HOST), mostly cloned ones. We allow routes in FIB
to contain rt6i_gateway with zeroes (eg. for local subnets) but
on cloning we can fill the rt6i_gateway field in result.
This works even without this patchset.

	There is a single special case where dst is provided as
skb_dst directly without a routing call: icmp6_dst_alloc(). It is a
private dst allocated just for the particular ICMP packet. Patch 2
fills rt6i_gateway in this case, needed for the new rt6_nexthop()
simplification.

	The last case is addrconf_dst_alloc(), it can put in
FIB local/anycast routes when addresses are added. Patch 2
needs to fill rt6i_gateway in this case because such routes
are returned without cloning.

Julian Anastasov (3):
  ipv6: always prefer rt6i_gateway if present
  ipv6: fill rt6i_gateway with nexthop address
  netfilter: nf_conntrack: fix rt6i_gateway checks for H.323 helper

 include/net/ip6_route.h                | 6 ++----
 net/ipv6/ip6_output.c                  | 4 ++--
 net/ipv6/route.c                       | 8 ++++++--
 net/netfilter/nf_conntrack_h323_main.c | 4 ++--
 4 files changed, 12 insertions(+), 10 deletions(-)

-- 
1.8.3.1
