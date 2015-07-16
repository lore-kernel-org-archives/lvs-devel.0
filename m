From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 0/6] IPVS Fixes for v4.2
Date: Thu, 16 Jul 2015 11:14:07 +0900
Message-ID: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v4.2.
For reasons that are not clear to me it is a bumper crop.

It seems to me that they are all relevant to stable.
Please let me know if you need my help to get the fixes into stable.

* ipvs: fix ipv6 route unreach panic

  This problem appears to be present since IPv6 support was added to
  IPVS in v2.6.28.

* ipvs: skb_orphan in case of forwarding

  This appears to resolve a problem resulting from a side effect of
  41063e9dd119 ("ipv4: Early TCP socket demux.") which was included in v3.6.

* ipvs: do not use random local source address for tunnels

  This appears to resolve a problem introduced by
  026ace060dfe ("ipvs: optimize dst usage for real server") in v3.10.

* ipvs: fix crash if scheduler is changed

  This appears to resolve a problem introduced by
  ceec4c381681 ("ipvs: convert services to rcu") in v3.10.

  Julian has provided backports of the fix:
  * [PATCHv2 3.10.81] ipvs: fix crash if scheduler is changed
    http://www.spinics.net/lists/lvs-devel/msg04008.html
  * [PATCHv2 3.12.44,3.14.45,3.18.16,4.0.6] ipvs: fix crash if scheduler is changed
    http://www.spinics.net/lists/lvs-devel/msg04007.html

  Please let me know how you would like to handle guiding these
  backports into stable.

* ipvs: fix crash with sync protocol v0 and FTP

  This appears to resolve a problem introduced by
  749c42b620a9 ("ipvs: reduce sync rate with time thresholds") in v3.5



The following changes since commit 484836ec2de24d9a7c6471f022b746d947698725:

  netfilter: IDLETIMER: fix lockdep warning (2015-07-13 17:23:25 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.2

for you to fetch changes up to e3895c0334d0ef46e80f22eaf2a52401ff6d5a67:

  ipvs: call skb_sender_cpu_clear (2015-07-14 16:41:27 +0900)

----------------------------------------------------------------
Alex Gartrell (2):
      ipvs: fix ipv6 route unreach panic
      ipvs: skb_orphan in case of forwarding

Julian Anastasov (4):
      ipvs: do not use random local source address for tunnels
      ipvs: fix crash if scheduler is changed
      ipvs: fix crash with sync protocol v0 and FTP
      ipvs: call skb_sender_cpu_clear

 net/netfilter/ipvs/ip_vs_core.c  | 16 +++++++--
 net/netfilter/ipvs/ip_vs_ctl.c   | 78 +++++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sched.c | 12 +++----
 net/netfilter/ipvs/ip_vs_sync.c  |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c  | 41 ++++++++++++++++++++-
 5 files changed, 110 insertions(+), 39 deletions(-)
