From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL v2 0/4] IPVS Fixes for v4.5
Date: Mon,  7 Mar 2016 12:03:30 +0900
Message-ID: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319820; bh=PUlB0j4jJrrr7TZn9hUm8xRGWYfl/NiuNbS5r5w7LLM=;
	h=From:To:Cc:Subject:Date:From;
	b=FQXAarKtET6Fy6fZJOp5nJrfIXcW1+78TTzbE/AXUJUrF0piCseX1newUp8ZZXH9P
	 1YsjjrO68iRGbcygfnAd/FolckPyNzfWRjKfKp9ZjtFiYOQIF2nlt9AHDe2WKOdXEK
	 R942rTSdLo/8hfR+QDZHQQsJPU/olhfF2A2iaNiA=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS fixes for v4.5 or
if it is too late please consider them for v4.6.

* Arnd Bergman has corrected an error whereby the SIP persistence engine
  may incorrectly access protocol fields
* Julian Anastasov has corrected a problem reported by Jiri Bohac with the
  connection rescheduling mechanism added in 3.10 when new SYNs in
  connection to dead real server can be redirected to another real server.
* Marco Angaroni resolved a problem in the SIP persistence engine
  whereby the Call-ID could not be found if it was at the beginning of a
  SIP message.

The following changes since commit 017b1b6d28c479f1ad9a7a41f775545a3e1cba35:

  netfilter: nfnetlink_acct: validate NFACCT_FILTER parameters (2016-02-29 13:27:21 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.5

for you to fetch changes up to 7617a24f83b5d67f4dab1844956be1cebc44aec8:

  ipvs: correct initial offset of Call-ID header search in SIP persistence engine (2016-03-07 11:53:35 +0900)

----------------------------------------------------------------
Arnd Bergmann (1):
      ipvs: handle ip_vs_fill_iph_skb_off failure

Julian Anastasov (2):
      ipvs: drop first packet to redirect conntrack
      ipvs: allow rescheduling after RST

Marco Angaroni (1):
      ipvs: correct initial offset of Call-ID header search in SIP persistence engine

 include/net/ip_vs.h               | 17 +++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c   | 38 +++++++++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_pe_sip.c |  6 +++---
 3 files changed, 49 insertions(+), 12 deletions(-)
