From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/2] IPVS Updates for v4.6
Date: Thu, 18 Feb 2016 09:28:40 +0900
Message-ID: <1455755322-19972-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1455755340; bh=iovmS6gWWu/yf0JI+mj3NC0uBL2qAoBpJEJ1JdEGm7s=;
	h=From:To:Cc:Subject:Date:From;
	b=B4UIRGbAzv5kdptAlUAhU6wcPAzNt5abkZViS+16t8sA4/EwkrUW638pEatfe+R4r
	 NMfFxJ7wG07a+JiOXt6ZHVWuY+IMaVm2VkMlFpVVfcc8ZSwtvhbNxSTyRhH3wI6Tuy
	 /Nr6LyTh0l1RjNb9zBi0W2KBNuo9xb9/aPpfLRQU=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these cleanups for IPVS for v4.6.

* Arnd Bergmann has resolved a bunch of unused variable warnings and;
* Yannick Brosseau has removed a noisy debug message

The following changes since commit 667f00630ebefc4d73aa105c6ab254e4aec867f8:

  Merge branch 'local-checksum-offload' (2016-02-12 05:52:41 -0500)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.6

for you to fetch changes up to f6ca9f46f6615c3a87529550058d1b468c0cad89:

  netfilter: ipvs: avoid unused variable warnings (2016-02-18 09:17:58 +0900)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: ipvs: avoid unused variable warnings

Yannick Brosseau (1):
      netfilter: ipvs: Remove noisy debug print from ip_vs_del_service

 net/netfilter/ipvs/ip_vs_app.c |  8 ++------
 net/netfilter/ipvs/ip_vs_ctl.c | 17 ++++++-----------
 2 files changed, 8 insertions(+), 17 deletions(-)

Arnd Bergmann (1):
  netfilter: ipvs: avoid unused variable warnings

Yannick Brosseau (1):
  netfilter: ipvs: Remove noisy debug print from ip_vs_del_service

 net/netfilter/ipvs/ip_vs_app.c |  8 ++------
 net/netfilter/ipvs/ip_vs_ctl.c | 17 ++++++-----------
 2 files changed, 8 insertions(+), 17 deletions(-)

-- 
2.1.4

