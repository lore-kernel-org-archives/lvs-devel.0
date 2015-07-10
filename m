From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS for v4.3
Date: Fri, 10 Jul 2015 15:42:48 +0900
Message-ID: <1436510569-10752-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

please consider this cleanup from Markus Elfring
which removes a redundant check before calling module_put().

Markus Elfring (1):
  net-ipvs: Delete an unnecessary check before the function call
    "module_put"

 net/netfilter/ipvs/ip_vs_sched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.1.4

