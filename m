From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Updates for v4.8
Date: Thu,  7 Jul 2016 20:40:39 +0200
Message-ID: <1467916840-17005-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1467916846; bh=VeiotfESO0AgEpFFqzweXdnZzImHDzbhSk5xeYeyYjA=;
	h=From:To:Cc:Subject:Date:From;
	b=cRYB8DUq6Vl+QsGJBwclJAGVo+31MVg1b9rZaTt74enI0jTIL+NkbrB0Jt2PJ283W
	 tLKrlbykoDAjgG1qdWQdTnyrlJCMj5A3/IGFJGQB4kcbm4ph6y6Gqcoz4i2NOGpruf
	 ZyPVg3a5ryfoP/YICtXDaqssFSBr/nZw9qXdViSI=
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these enhancements to the IPVS. This alters the behaviour
of the "least connection" schedulers such that pre-established connections
are included in the active connection count. This avoids overloading
servers when a large number of new connections arrive in a short space of
time - e.g. when clients reconnect after a node or network failure.


The following changes since commit c6ac37d8d8843fb1fdc34e4a2a41a4f027ab670c:

  netfilter: nf_log: fix error on write NONE to logger choice sysctl (2016-07-05 14:57:57 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.8

for you to fetch changes up to be2cef49904b34dd5f75d96bbc8cd8341bab1bc0:

  ipvs: count pre-established TCP states as active (2016-07-07 20:30:52 +0200)

----------------------------------------------------------------
Michal Kubecek (1):
      ipvs: count pre-established TCP states as active

 net/netfilter/ipvs/ip_vs_proto_tcp.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)
