From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next v1] ipvs: fix multiplicative hashing in sh/dh/lblc/lblcr algorithms
Date: Sun,  1 Apr 2018 00:28:38 +0200
Message-ID: <20180331222838.32758-1-vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:date:message-id; s=postfix; bh=/v+vTZ28dWNedfxG5FD8yHU5
        mG4=; b=VbO58Lsot35IFXPljt8xXTxdN4ailbb/adzBUXBTWDDb7TDWf1f3hgKK
        FngZk2Es4GBBwY6nD2Ipe/cgoz/IV34q7F2oLX4TZr26Jsglf1Yc+4N++6+LJw5P
        ChMgsdwlE7SQ9ubrAOrQfugGdhDLFHaraU4vpz45aF9+bMvJaw4=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Vincent Bernat <vincent@bernat.im>

The sh/dh/lblc/lblcr algorithms are using Knuth's multiplicative
hashing incorrectly. This results in uneven distribution.

To fix this, the result has to be shifted by a constant. In "Lecture
21: Hash functions" [1], it is said:

   In the fixed-point version, The division by 2^q is crucial. The
   common mistake when doing multiplicative hashing is to forget to do
   it, and in fact you can find web pages highly ranked by Google that
   explain multiplicative hashing without this step. Without this
   division, there is little point to multiplying by a, because ka mod
   m = (k mod m) * (a mod m) mod m . This is no better than modular
   hashing with a modulus of m, and quite possibly worse.

Typing the 2654435761 constant in DuckDuckGo shows many other sources
to confirm this issue. Moreover, doing the multiplication in the 32bit
integer space is enough, hence the change from 2654435761UL to
2654435761U.

[1]: https://www.cs.cornell.edu/courses/cs3110/2008fa/lectures/lec21.html

The following Python program illustrates the bug and its fix:

    import netaddr
    import collections
    import socket
    import statistics

    def run(buggy=False):
        base = netaddr.IPAddress('203.0.113.0')
        count = collections.defaultdict(int)
        for offset in range(100):
            for port in range(10000, 11000):
                r = socket.ntohs(port) + socket.ntohl(int(base) + offset)
                r *= 2654435761
                if buggy:
                    r %= 1 << 64
                else:
                    r %= 1 << 32
                    r >>= 24
                r &= 255
                count[r] += 1

        print(buggy,
              statistics.mean(count.values()),
              statistics.stdev(count.values()))

    run(True)
    run(False)

Its output is:

    True 25000 765.9416862050705
    False 390.625 4.681209831891333

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/netfilter/ipvs/ip_vs_dh.c    | 4 +++-
 net/netfilter/ipvs/ip_vs_lblc.c  | 4 +++-
 net/netfilter/ipvs/ip_vs_lblcr.c | 4 +++-
 net/netfilter/ipvs/ip_vs_sh.c    | 3 ++-
 4 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f798f8e83b..5638e66dbdd1 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -81,7 +81,9 @@ static inline unsigned int ip_vs_dh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_DH_TAB_MASK;
+	return ((ntohl(addr_fold)*2654435761U) >>
+		(32 - IP_VS_DH_TAB_BITS)) &
+		IP_VS_DH_TAB_MASK;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 3057e453bf31..df32022a2bc4 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -160,7 +160,9 @@ ip_vs_lblc_hashkey(int af, const union nf_inet_addr *addr)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLC_TAB_MASK;
+	return ((ntohl(addr_fold)*2654435761U) >>
+		(32 - IP_VS_LBLC_TAB_BITS)) &
+		IP_VS_LBLC_TAB_MASK;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 92adc04557ed..3d0d278d4901 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -323,7 +323,9 @@ ip_vs_lblcr_hashkey(int af, const union nf_inet_addr *addr)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLCR_TAB_MASK;
+	return ((ntohl(addr_fold)*2654435761U) >>
+		(32 - IP_VS_LBLCR_TAB_BITS)) &
+		IP_VS_LBLCR_TAB_MASK;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 16aaac6eedc9..d2d6cdfae86e 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -96,7 +96,8 @@ ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr,
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+	return ((offset + (ntohs(port) + ntohl(addr_fold))*2654435761U) >>
+		(32 - IP_VS_SH_TAB_BITS)) &
 		IP_VS_SH_TAB_MASK;
 }
 
-- 
2.16.3

