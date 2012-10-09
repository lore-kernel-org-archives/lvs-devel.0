From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fix for 3.7
Date: Tue,  9 Oct 2012 13:47:16 +0900
Message-ID: <1349758037-25317-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Arnd Bergmann <arnd@arndb.de>

Hi Pablo,

please consider the following fix for IPVS from Arnd Bergmann for
inclusion in 3.7. I would also like it considered for 3.6, 3.5, 3.4, 3.3
and 3.0 stable.

----------------------------------------------------------------
The following changes since commit 6825a26c2dc21eb4f8df9c06d3786ddec97cf53b:

  ipv6: release reference of ip6_null_entry's dst entry in __ip6_del_rt (2012-10-04 16:00:07 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to b61a602ee6730150f4d0df730d9312ac4d820ceb:

  ipvs: initialize returned data in do_ip_vs_get_ctl (2012-10-09 13:04:34 +0900)

----------------------------------------------------------------
Arnd Bergmann (1):
      ipvs: initialize returned data in do_ip_vs_get_ctl

 net/netfilter/ipvs/ip_vs_ctl.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
