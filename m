From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] Second round of IPVS fixes for v3.17
Date: Thu, 28 Aug 2014 11:04:27 +0900
Message-ID: <1409191468-28013-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix IPVS fix for v3.17.

This pull request is based on the first round of fixes for IPVS for v3.17,
tagged as ipvs-fixes2-for-v3.17, which I sent yesterday.


This fix resolves a problem with conflicting hooks whereby DNAT support for
the local server would drop outgoing IPv4 packets if the kernel was
compiled CONFIG_IP_VS_IPV6=y.

This problem dates back to v3.6.37 when the feature in question was added.

I would like this fix considered for -stable.


The following changes since commit ea1d5d7755a3e556de78cc757d1895d5c7180548:

  ipvs: properly declare tunnel encapsulation (2014-08-27 14:31:56 +0900)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.17

for you to fetch changes up to eb90b0c734ad793d5f5bf230a9e9a4dcc48df8aa:

  ipvs: fix ipv6 hook registration for local replies (2014-08-28 10:52:37 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: fix ipv6 hook registration for local replies

 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
