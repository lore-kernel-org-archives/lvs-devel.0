From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 2/2] netfilter: ipvs: use GFP_KERNEL allocation where possible
Date: Sat, 14 Apr 2012 09:22:02 -0400
Message-ID: <1334409722-26315-2-git-send-email-levinsasha928@gmail.com>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer:in-reply-to:references;
        bh=yTZomEZK6kb8X78M8Bpg0AP50GWq3DSi+dRAbv/SW7o=;
        b=w/irNq5BcflT6qZCTNu+vabDxWxAH973dG8yM26paylBOrZf4icpaAIVJkcBFpOfM1
         z25z8U/fsoSaNZ98PdI9XfUc/XEL2vGKeJoDAto+xb8INPQFvCyuFYuz0IuduSQ57f5L
         qbmYLNLTZeKhwmctnr6L/zoG18FOr1XwCmhNLk/brytRBZqOiREE7FOdQ9u3HvB94XZU
         aiSYU7Mk+eVywW1719VN/cqlf2IxLI4ZXzxCB1rl/4wn2ywkhEMSYjBRXTC5IZrqZYqe
         WNaoPebmuEDNumhIkLHAb5JJ2EjW44Y6vDeMHH2O11exMvfWdd57JC3QHS0M83UjVXrB
         CEJA==
In-Reply-To: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, kaber@trash.net, davem@davemloft.net
Cc: davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Use GFP_KERNEL instead of GFP_ATOMIC when registering an ipvs protocol.

This is safe since it will always run from a process context.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 57a242d..73d06c6 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -71,7 +71,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
-			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_KERNEL);
 
 	if (!pd)
 		return -ENOMEM;
-- 
1.7.8.5
