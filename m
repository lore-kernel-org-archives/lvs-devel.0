From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH net v2 0/2] fix glitch in IPVS /proc handlers
Date: Tue, 31 Jul 2018 18:03:31 +0200
Message-ID: <20180731160333.12215-1-mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

Fix a bug which shows negative values in IPVS /proc handlers.
Also add an helper function to calculate a time delta

Matteo Croce (2):
  jiffies: add utility function to calculate delta in ms
  ipvs: don't show negative times in ip_vs_conn

 include/linux/jiffies.h         |  5 +++++
 net/netfilter/ipvs/ip_vs_conn.c | 22 ++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

-- 
2.17.1

