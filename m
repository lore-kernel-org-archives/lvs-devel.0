From: Simon Horman <horms@verge.net.au>
Subject: ipvs: ipvs update for nf-next-2.6
Date: Tue, 16 Nov 2010 15:34:52 +0900
Message-ID: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, n

Hi Patrick,

the following patches contain updates to IPVS since 2.6.37-rc1
and are targeted at nf-next-2.6.

- Static and shadow variable clean-ups from Eric

- Preparation for persistence engine syncrhonisation

- Correctness fix for persistence engine match.
  I do not consider this a bug as it can only manifest in a problem
  if there is more than one persistence engine loaded and
  currently only one exists.

- Code cleanps for ip_vs_sync_conn(), ip_vs_process_message()
  and ip_vs_process_message()

- Handle GRO aggregated skbs
  The previous behaviour was to send a needs frag ICMP.
  This is probably stable material.

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick

I expect more activity before 2.6.37-rc1. In particular Hans is working
heavily with Julian and myself on the new synchronisation code.
