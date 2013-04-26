From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL ipvs] ipvs fixes for v3.9 #2
Date: Fri, 26 Apr 2013 10:53:09 +0900
Message-ID: <1366941190-12135-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

Hi Pablo,

I guess that it is too late in the cycle to get this fix into v3.9.
If so could you please consider it for v3.10.

I would also like the patch considered for stable. It seems to be applicable
to all kernel releases since the sip persistence engine was added
by my in v2.6.37. In particular I have checked that it applies cleanly to:

3.8.8 stable
3.4.41 longterm
3.2.43 longterm
3.0.74 longterm

The following changes since commit 60d509fa6a9c4653a86ad830e4c4b30360b23f0e:

  Linux 3.9-rc8 (2013-04-21 14:38:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.9

for you to fetch changes up to 75cbc7c25c3efdc325d71baa1cc0ce06940e0e65:

  ipvs: ip_vs_sip_fill_param() BUG: bad check of return value (2013-04-26 09:59:16 +0900)

----------------------------------------------------------------
Fix for crash-bug in SIP persistence engine by Hans Schillstrom

This bug appears to have been present since the sip persistence engine
was added by me in v2.6.37.

----------------------------------------------------------------
Hans Schillstrom (1):
      ipvs: ip_vs_sip_fill_param() BUG: bad check of return value

 net/netfilter/ipvs/ip_vs_pe_sip.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)
