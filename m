From: Simon Horman <horms@verge.net.au>
Subject: [GIT 0/1] IPVS Fixes for v4.11
Date: Fri, 28 Apr 2017 11:58:15 +0200
Message-ID: <20170428095816.6588-1-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493373520; bh=8La49DFEUxue/Wqy1hqJZZPbNOxGLX40VM2It42istM=;
        h=From:To:Cc:Subject:Date:From;
        b=JtHu/O/A57IbyZveKhQNnptsFsy6ypZQ6R4OHI7cuwQG/4HTeQu3STdKjK6JZ8lgp
         sTcyC3J0eTHAOqPU64lpEu/Jay1G85PejsKGyWkMYFJRRKnQdGPuZ1nGBbeap75FZr
         DOAdO6cWXAZi1L9uF+E9zOsExEINWVmgVoxAahUg=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix to IPVS for v4.11.
Or if it is too late for v4.11 please consider it for v4.12.
I would also like it considered for stable.

* Explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled
  to avoid oops caused by IPVS accesing IPv6 routing code in such
  circumstances.

The following changes since commit 1debdc8f9ebd07daf140e417b3841596911e0066:

  sh_eth: unmap DMA buffers when freeing rings (2017-04-18 22:04:32 -0400)

are available in the git repository at:

  http://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git ipvs-fixes-for-v4.11

for you to fetch changes up to 8f8688b0d483ff06236808ab5fc8bc83c5eaa8d9:

  ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled (2017-04-24 11:53:55 +0200)

----------------------------------------------------------------
Paolo Abeni (1):
      ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled

 net/netfilter/ipvs/ip_vs_ctl.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

-- 
2.12.2.816.g2cccc81164

