From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/5] IPVS Updates for v4.12
Date: Thu, 16 Mar 2017 13:43:10 +0100
Message-ID: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1489668205; bh=MWRPYDIK5MFPq5wDxKTSYc2P5bTx2AchVpMzaSIjDXs=;
        h=From:To:Cc:Subject:Date:From;
        b=SJE/TumBQVOzJJ0xXJGpK9Yo7w1nWNo6J76QGnQfkSu7EYNTPv3YG7e4GaTIdcH7w
         L96jGegABGC/XdKdMLNoyC7UELHKQjaN5SJicNKyulNAmF9ZULuGrB4J7RlO06cRfN
         99WgW68VDLnpQFeyaXfTM0vPQFtCh2xKlzXqA8co=
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these enhancements to the IPVS for v4.12.

* Update sysctl documentation
* Remove unnecessary printk in __ip_vs_init

The following changes since commit 03e5fd0e9bcc1f34b7a542786b34b8f771e7c260:

  netfilter: nft_set_rbtree: use per-set rwlock to improve the scalability (2017-03-13 19:30:43 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.12

for you to fetch changes up to 3c679cba588a46ba81a264673e192bbd3c92455b:

  ipvs: Document sysctl pmtu_disc (2017-03-16 13:33:39 +0100)

----------------------------------------------------------------
Cong Wang (1):
      ipvs: remove an annoying printk in netns init

Hangbin Liu (4):
      ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
      ipvs: Document sysctl sync_qlen_max and sync_sock_size
      ipvs: Document sysctl sync_ports
      ipvs: Document sysctl pmtu_disc

 Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
 net/netfilter/ipvs/ip_vs_core.c          |  2 -
 2 files changed, 60 insertions(+), 10 deletions(-)
