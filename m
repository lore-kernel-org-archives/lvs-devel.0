From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.
Date: Fri, 21 Oct 2011 10:33:03 +0900
Message-ID: <1319160783-28422-3-git-send-email-horms@verge.net.au>
References: <1319160783-28422-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1319160783-28422-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>, Simon Horman <horms@verge.net.au>

=46rom: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

This is to address the following error during the compilation:

  In file included from kernel/sysctl_binary.c:6:
  include/net/ip_vs.h:1406: error: expected identifier or =E2=80=98(=E2=
=80=99 before =E2=80=98{=E2=80=99 token
  make[1]: *** [kernel/sysctl_binary.o] Error 1
  make[1]: *** Waiting for unfinished jobs....

That manifests itself when CONFIG_IP_VS_NFCT is undefined in .config fi=
le.

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 139784e..de527d1 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1395,7 +1395,7 @@ static inline void ip_vs_update_conntrack(struct =
sk_buff *skb,
 {
 }
=20
-static inline int ip_vs_confirm_conntrack(struct sk_buff *skb);
+static inline int ip_vs_confirm_conntrack(struct sk_buff *skb)
 {
 	return NF_ACCEPT;
 }
--=20
1.7.6.3

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
