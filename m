From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf 0/3] IPVS Fixes for v4.5
Date: Thu, 18 Feb 2016 09:40:58 +0900
Message-ID: <1455756061-21834-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1455756076; bh=/bADyGeZqQlc2QmwX+WP7Wrv6NRrZKFJLddgmQcptgk=;
	h=From:To:Cc:Subject:Date:From;
	b=I5xPfW+Etcokv5oN6X25CKLI8rzKGPj2gP2R0TD6QX1yEpv4pwtW/25obHwu5T/X7
	 AnmoehGnG66tHVjpLD30aB2OghqdGQcIWjHi3V8CcQE9PHryN1LKi09gPKMWOBF6dn
	 5NO/DH/Pebc160va+CisgXhDSm9sPvWC4q78zINU=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS fixes for v4.5.

* Arnd Bergman has corrected an error whereby the SIP persistence engine
  may incorrectly access protocol fields
* Julian Anastasov has corrected a problem reported by Jiri Bohac with the
  connection rescheduling mechanism added in 3.10 when new SYNs in
  connection to dead real server can be redirected to another real server.

The following changes since commit 5cc6ce9ff27565949a1001a2889a8dd9fd09e772:

  netfilter: nft_counter: fix erroneous return values (2016-02-08 13:05:02 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.5

for you to fetch changes up to 5acaf89f88b97849d550d6fbb10362e3d84b5082:

  netfilter: ipvs: handle ip_vs_fill_iph_skb_off failure (2016-02-18 09:31:48 +0900)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: ipvs: handle ip_vs_fill_iph_skb_off failure

Julian Anastasov (2):
      netfilter: ipvs: drop first packet to redirect conntrack
      netfilter: ipvs: allow rescheduling after RST

 include/net/ip_vs.h               | 17 +++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c   | 38 +++++++++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_pe_sip.c |  4 ++--
 3 files changed, 48 insertions(+), 11 deletions(-)
