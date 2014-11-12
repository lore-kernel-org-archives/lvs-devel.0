From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] Second Round of IPVS Fixes for v3.18
Date: Wed, 12 Nov 2014 11:21:59 +0900
Message-ID: <1415758920-32578-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v3.18.

It fixes handling of skb->sk which may cause incorrect handling
of connections from a local process.

This problem was introduced in its current form by 8052ba292559f907e
("ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding") in
v3.18-rc1.

I believe it also exists in a different form in older kernels.
No fix for that is available at this time.


The following changes since commit 2196937e12b1b4ba139806d132647e1651d655df:

  netfilter: ipset: small potential read beyond the end of buffer (2014-11-11 13:46:37 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.18

for you to fetch changes up to 50656d9df63d69ce399c8be62d4473b039dac36a:

  ipvs: Keep skb->sk when allocating headroom on tunnel xmit (2014-11-12 11:03:04 +0900)

----------------------------------------------------------------
Calvin Owens (1):
      ipvs: Keep skb->sk when allocating headroom on tunnel xmit

 net/netfilter/ipvs/ip_vs_xmit.c | 2 ++
 1 file changed, 2 insertions(+)
