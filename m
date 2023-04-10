From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next 0/4] ipvs: Cleanups for v6.4
Date: Mon, 10 Apr 2023 11:42:34 +0200
Message-ID: <20230409-ipvs-cleanup-v1-0-98cdc242feb0@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681119772;
        bh=8mrBnTnoB7t/AMZsj2+xBakPM4atwfooXq/n+Cg7RAQ=;
        h=From:Subject:Date:To:Cc:From;
        b=CoX2RYe8cQ2we16K9+P55yWV+r9uxBDPNf0hWTcGUACIfXRRqeDcN1VkZU+6mm+mv
         AoRfKYjoc2F4JbJ23/gZQ/9JjKsClQi3txlYZ6+/f0BrNv0wy5ckQjOe7Aqjcg/pul
         +jHotl140CMH4UQy+wOxj8t14N5Xp1S+zWGcM1mQvxCjqY40tzXn5od0JzuAgHb45A
         /VmOT16YeUmHikK6S1hgYbKnA9SsZDh72reIyMcIg8vloChzQqQE61jjc41sKYfLp2
         ntF0OeY+Fd7XCSlOYd6GeKg4wUydE/SxJHXSEmXcfYwfi4J/pYB4c+iTw79bHeHbTW
         rAvL5dTr6HAmQ==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Hi Pablo,

this series aims to clean up IPVS in several ways without
implementing any functional changes, aside from removing
some debugging output.

Patch 1/4: Update width of source for ip_vs_sync_con_options
           The operation is safe, use an annotation to describe it properly.

Patch 2/4: Consistently use array_size() in ip_vs_conn_init()
           It seems better to use helpers consistently.

Patch 3/4: Remove {Enter,Leave}Function
           These seem to be well past their use-by date.

Patch 4/4: Correct spelling in comments
	   I can't spell. But codespell helps me these days.

All changes: compile tested only!

---
Simon Horman (4):
      ipvs: Update width of source for ip_vs_sync_con_options
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

base-commit: 9b7c68b3911aef84afa4cbfc31bce20f10570d51

