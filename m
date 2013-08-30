From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] Second round of IPVS updates for v3.12
Date: Fri, 30 Aug 2013 18:21:55 +0900
Message-ID: <1377854516-24383-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this small update to IPVS for v3.12.


The following changes since commit b7e092c05b308674c642ed7fb754d555f0ebba81:

  netfilter: ctnetlink: fix uninitialized variable (2013-08-28 00:28:19 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.12

for you to fetch changes up to 25a9707d3f4c1f6b7a6de8f6468d40356d6eb92c:

  ipvs: fix the IPVS_CMD_ATTR_MAX definition (2013-08-30 18:17:47 +0900)

----------------------------------------------------------------
Second round of IPVS updates for v3.12

* Correct value of IPVS_CMD_ATTR_MAX

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: fix the IPVS_CMD_ATTR_MAX definition

 include/uapi/linux/ip_vs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
