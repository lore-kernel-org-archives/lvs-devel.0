From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next v3 0/4] ipvs: Cleanups for v6.4
Date: Mon, 17 Apr 2023 17:10:44 +0200
Message-ID: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681744279;
        bh=P/QoeHAKZ55pby10GX/9bO6MW7hatN7F+qitfvgXnRE=;
        h=From:Subject:Date:To:Cc:From;
        b=FJPp7X4zdL6Va3+6pJ4YZPL7NSqwB631FyG24irKLeOIieUVWibRtdAGxhf4A+pF0
         IRTNFSXMp0qeEroftwH601Z7yOYJoqIutvYYZNi+Ou1wEEC+pQwC9jBGDj6r3meO1x
         JfqudXjZtQ5DKLmTnu6reDsGf2w3H1YpRniLFV6b+GE3kJzoNos1qbABVISUFYskNy
         XZTuysiPKUV5GfBC0Z448JmJe5xswnctbPLFenRMxJeGTgqvq74uO2gWEo+JHEOIA8
         ulq9i1clgvzfl+FEUfEPxP5AlO4F8Wo3NHWimpP+hBz30YZHz2LeBK4wf1d+But4UA
         gLhQzFWnHFUSA==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Horatiu Vultur <horatiu.vultur@microchip.com>

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
Changes in v3:
- Patch 2/4: Correct division by 1024.
             It was applied to the wrong variable in v2.
- Add Horatiu's Reviewed-by tag.

Changes in v2:
- Patch 1/4: Correct spelling of 'conn' in subject.
- Patch 2/4: Restore division by 1024. It was lost on v1.

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

base-commit: 99676a5766412f3936c55b9d18565d248e5463ee

