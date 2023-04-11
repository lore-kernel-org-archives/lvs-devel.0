From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next v2 0/4] ipvs: Cleanups for v6.4
Date: Tue, 11 Apr 2023 09:10:38 +0200
Message-ID: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681197047;
        bh=dWECYEnu3oSCzd3j0bJdz30hiF397lT4p1HM1cffhk4=;
        h=From:Subject:Date:To:Cc:From;
        b=mrLKW7G77IM1tlEKMJKXk5w4goTgr0LSR7dIQ1yCqF9Tqv9/E4InSF5W21Rla74DR
         7IppkMo6KqOOa+PDjx+sA6BxyODf2QZmzOlIrPaO+LK5Pkg9xdljjeGMe+yKf9Wpw5
         xHp0ivhjK7fMueiTcxAa15w+/Rhaksp6IRLE/r1XpyP/TrgY0qoIMa6/6bi5cFaYR1
         G9AN8EOpnRPM47JBqw32QmIH14SQhJOoq8bkba5VnjuTuJoYdv0gzLBxFZEIAz2odo
         COSE6I1hJeeqr2NcakWE4nr7/wJWjDcP56ijMzSr/3qgMpKHnRKmLLSvMXzTHgwkzI
         PMxTKawpm9W6w==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Hi Julian,

this series aims to clean up IPVS in several ways without
implementing any functional changes, aside from removing
some debugging output.

Patch 1/4: Update width of source for ip_vs_sync_conn_options
           The operation is safe, use an annotation to describe it properly.

Patch 2/4: Consistently use array_size() in ip_vs_conn_init()
           It seems better to use helpers consistently.

Patch 3/4: Remove {Enter,Leave}Function
           These seem to be well past their use-by date.

Patch 4/4: Correct spelling in comments
	   I can't spell. But codespell helps me these days.

All changes: compile tested only!

---
Changes in v2:
- Patch 1/4: Correct spelling of 'conn' in subject

---
Simon Horman (4):
      ipvs: Update width of source for ip_vs_sync_conn_options
      ipvs: Consistently use array_size() in ip_vs_conn_init()
      ipvs: Remove {Enter,Leave}Function
      ipvs: Correct spelling in comments

 include/net/ip_vs.h             | 32 +++++----------------
 net/netfilter/ipvs/ip_vs_conn.c | 12 ++++----
 net/netfilter/ipvs/ip_vs_core.c |  8 ------
 net/netfilter/ipvs/ip_vs_ctl.c  | 26 +----------------
 net/netfilter/ipvs/ip_vs_sync.c |  7 +----
 net/netfilter/ipvs/ip_vs_xmit.c | 62 ++++++-----------------------------------
 6 files changed, 23 insertions(+), 124 deletions(-)

base-commit: 9bc11460bea751b5c805ac793de35a55629adb9b

